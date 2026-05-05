#!/usr/bin/env bash
set -euo pipefail

NS="${1:-lab-seguridad}"
SECRET_NAME="${2:-demo-tls}"
CERT_DIR="${3:-/tmp/lab-tls}"

mkdir -p "$CERT_DIR"

openssl req -x509 -nodes -days 1 -newkey rsa:2048 \
  -keyout "$CERT_DIR/tls.key" \
  -out "$CERT_DIR/tls.crt" \
  -subj "/CN=demo.local/O=lab-seguridad"

kubectl -n "$NS" create secret tls "$SECRET_NAME" \
  --cert="$CERT_DIR/tls.crt" \
  --key="$CERT_DIR/tls.key" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Secret TLS '$SECRET_NAME' aplicado en namespace '$NS'."
