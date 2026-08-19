#!/usr/bin/env python3
"""Creates a fake AWS CLI v2 zip for testing install-aws-cli-action."""
import sys
import zipfile

output_file = sys.argv[1] if len(sys.argv) > 1 else "/tmp/fake-awscli.zip"

# The fake install script that mimics ./aws/install
install_script = r"""#!/bin/sh
BIN_DIR="/usr/local/bin"
INSTALL_DIR="/usr/local/aws-cli"

while [ $# -gt 0 ]; do
  case "$1" in
    --bin-dir)
      BIN_DIR="$2"
      shift 2
      ;;
    --install-dir)
      INSTALL_DIR="$2"
      shift 2
      ;;
    --update)
      shift
      ;;
    *)
      shift
      ;;
  esac
done

mkdir -p "$BIN_DIR"
mkdir -p "$INSTALL_DIR"

# Write the fake aws binary
printf '#!/bin/sh\necho "aws-cli/2.13.0 Python/3.11.6 Linux/5.15.0-91-generic exe/x86_64.ubuntu.22 prompt/off"\n' > "$INSTALL_DIR/aws-fake"
chmod +x "$INSTALL_DIR/aws-fake"
ln -sf "$INSTALL_DIR/aws-fake" "$BIN_DIR/aws"
echo "Fake AWS CLI installed at $BIN_DIR/aws"
"""

with zipfile.ZipFile(output_file, 'w', zipfile.ZIP_DEFLATED) as zf:
    info = zipfile.ZipInfo('aws/install')
    info.external_attr = 0o755 << 16  # make executable
    zf.writestr(info, install_script.encode('utf-8'))

print(f"Created fake zip: {output_file}", file=sys.stderr)
