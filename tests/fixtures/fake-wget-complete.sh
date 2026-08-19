#!/bin/sh
# Comprehensive fake wget for testing install-aws-cli-action
# Handles:
#   --spider: returns HTTP/1.1 200 OK (for check_version_exists)
#   -O FILE URL: creates a fake AWS CLI zip (for download_aws_cli)

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
  # Create a fake AWS CLI zip using the Python helper (copied to /tmp during test setup)
  python3 /tmp/make-fake-awscli-zip.py "$OUTPUT_FILE"
  exit $?
fi

# Fall through to real wget for anything else
if [ -f /usr/bin/wget ]; then
  exec /usr/bin/wget "$@"
else
  echo "Error: no real wget found" >&2
  exit 1
fi
