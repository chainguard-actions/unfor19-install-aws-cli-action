#!/bin/sh
# Fake AWS CLI v2 installer - mimics ./aws/install
# Usage: ./aws/install --bin-dir BINDIR --install-dir INSTALLDIR [--update]
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

# Create a fake aws binary
cat > "$INSTALL_DIR/aws" << 'AWSEOF'
#!/bin/sh
echo "aws-cli/2.13.0 Python/3.11.6 Linux/5.15.0-91-generic exe/x86_64.ubuntu.22 prompt/off"
AWSEOF
chmod +x "$INSTALL_DIR/aws"

# Create symlink in bin dir
ln -sf "$INSTALL_DIR/aws" "$BIN_DIR/aws"

echo "You can now run: $BIN_DIR/aws --version"
