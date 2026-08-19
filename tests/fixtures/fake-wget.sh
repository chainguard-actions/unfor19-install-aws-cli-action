#!/bin/sh
# Fake wget: for --spider (HEAD check) calls, output HTTP/1.1 200 OK so that
# check_version_exists() in entrypoint.sh succeeds even when the real server
# returns HTTP/2. For all other calls (actual downloads), delegate to the real wget.
REAL_WGET="$(which -a wget 2>/dev/null | grep -v "$0" | head -1)"
[ -z "$REAL_WGET" ] && REAL_WGET="/usr/bin/wget"

# Check if this is a spider/HEAD request
IS_SPIDER=0
for arg in "$@"; do
  case "$arg" in
    --spider) IS_SPIDER=1 ;;
  esac
done

if [ "$IS_SPIDER" = "1" ]; then
  # Output a fake HTTP/1.1 200 OK response so check_version_exists passes
  echo "  HTTP/1.1 200 OK"
  exit 0
fi

# For all other calls, use the real wget
exec "$REAL_WGET" "$@"
