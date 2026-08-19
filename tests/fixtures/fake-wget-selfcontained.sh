#!/bin/sh
# Self-contained fake wget for testing install-aws-cli-action.
# Does NOT depend on python3 or any external helper files.
# Handles:
#   --spider (HEAD check): returns HTTP/1.1 200 OK
#   -O FILE URL (download): creates a fake AWS CLI v2 zip using the zip command

IS_SPIDER=0
OUTPUT_FILE=""
prev=""

for arg in "$@"; do
  case "$prev" in
    -O|--output-document) OUTPUT_FILE="$arg" ;;
  esac
  case "$arg" in
    --spider) IS_SPIDER=1 ;;
  esac
  prev="$arg"
done

if [ "$IS_SPIDER" = "1" ]; then
  # Return a fake HTTP/1.1 200 OK response so check_version_exists() passes
  echo "  HTTP/1.1 200 OK"
  exit 0
fi

if [ -n "$OUTPUT_FILE" ]; then
  # Convert OUTPUT_FILE to absolute path (zip runs from a temp dir)
  case "$OUTPUT_FILE" in
    /*) ABS_OUTPUT="$OUTPUT_FILE" ;;
    *)  ABS_OUTPUT="$(pwd)/$OUTPUT_FILE" ;;
  esac

  # Create a fake AWS CLI v2 zip using the zip command
  FAKE_TMP=$(mktemp -d)
  mkdir -p "$FAKE_TMP/aws"

  # Write the fake install script
  cat > "$FAKE_TMP/aws/install" << 'INSTALLEOF'
#!/bin/sh
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
printf '#!/bin/sh\necho "aws-cli/2.13.0 Python/3.11.6 Linux/5.15.0-91-generic exe/x86_64.ubuntu.22 prompt/off"\n' > "$INSTALL_DIR/aws-bin"
chmod +x "$INSTALL_DIR/aws-bin"

# Create symlink in bin dir
ln -sf "$INSTALL_DIR/aws-bin" "$BIN_DIR/aws"
echo "Fake AWS CLI installed at $BIN_DIR/aws"
INSTALLEOF

  chmod +x "$FAKE_TMP/aws/install"

  # Create the zip from the temp dir (zip preserves executable permissions)
  (cd "$FAKE_TMP" && zip -q "$ABS_OUTPUT" aws/install)
  RC=$?
  rm -rf "$FAKE_TMP"
  exit $RC
fi

# Fall through to real wget for anything else
if [ -f /usr/bin/wget ]; then
  exec /usr/bin/wget "$@"
else
  echo "Error: no real wget found" >&2
  exit 1
fi
