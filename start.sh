#!/bin/sh
# Railway start wrapper for Outline: sensible defaults, volume ownership,
# then the upstream server as the unprivileged nodejs user.
set -e

# Railway's private network for Postgres needs no TLS.
export PGSSLMODE="${PGSSLMODE:-disable}"
# Uploads and attachments go to the Railway volume.
export FILE_STORAGE="${FILE_STORAGE:-local}"
export FILE_STORAGE_LOCAL_ROOT_DIR="${FILE_STORAGE_LOCAL_ROOT_DIR:-/var/lib/outline/data}"
# Railway terminates HTTPS at its edge; an in-app redirect would also
# redirect Railway's plain-HTTP health check.
export FORCE_HTTPS="${FORCE_HTTPS:-false}"
export PORT="${PORT:-3000}"
export WEB_CONCURRENCY="${WEB_CONCURRENCY:-1}"
if [ -z "$URL" ] && [ -n "$RAILWAY_PUBLIC_DOMAIN" ]; then
  export URL="https://$RAILWAY_PUBLIC_DOMAIN"
fi

for v in URL SECRET_KEY UTILS_SECRET DATABASE_URL REDIS_URL; do
  eval "val=\${$v:-}"
  if [ -z "$val" ]; then
    echo "outline-railway: $v is not set; see the template overview." >&2
    exit 1
  fi
done

mkdir -p "$FILE_STORAGE_LOCAL_ROOT_DIR"
cd /opt/outline
if [ "$(id -u)" = "0" ]; then
  if [ "$(stat -c %u "$FILE_STORAGE_LOCAL_ROOT_DIR")" != "1001" ]; then
    chown -R 1001:1001 "$FILE_STORAGE_LOCAL_ROOT_DIR"
  fi
  export HOME=/home/nodejs
  exec setpriv --reuid=1001 --regid=1001 --init-groups node build/server/index.js "$@"
fi
exec node build/server/index.js "$@"
