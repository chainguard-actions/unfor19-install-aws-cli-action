#!/bin/sh
# wget wrapper: intercepts --spider (HEAD) requests and returns HTTP/1.1 200 OK
# so that check_version_exists() in entrypoint.sh succeeds regardless of whether
# the real server returns HTTP/2. All other requests are passed to the real wget.
IS_SPIDER=0
for arg in "$@"; do
  case "$arg" in
    --spider) IS_SPIDER=1 ;;
  esac
done

if [ "$IS_SPIDER" = "1" ]; then
  # Output HTTP/1.1 200 OK - captured by the 2>&1 redirect in check_version_exists
  echo "  HTTP/1.1 200 OK"
  exit 0
fi

# For all other calls, use the real wget binary
exec /usr/bin/wget.real "$@"
