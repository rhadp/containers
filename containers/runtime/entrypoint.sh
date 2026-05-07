#!/bin/bash
set -e

swtpm socket \
  --tpmstate dir=/tmp/swtpm \
  --tpm2 \
  --ctrl type=tcp,port=2322 \
  --server type=tcp,port=2321 \
  --flags not-need-init &

export TPM2TOOLS_TCTI="swtpm:host=127.0.0.1,port=2321"

timeout=10
while ! nc -z 127.0.0.1 2321 2>/dev/null; do
  sleep 0.1
  timeout=$((timeout - 1))
  if [ "$timeout" -le 0 ]; then
    echo "ERROR: swtpm failed to start" >&2
    exit 1
  fi
done

tpm2_startup -c

exec "$@"
