#!/usr/bin/env sh
set -eu

npx hardhat node --hostname 0.0.0.0 > /tmp/hardhat.log 2>&1 &
NODE_PID=$!

cleanup() {
  if kill -0 "$NODE_PID" 2>/dev/null; then
    kill "$NODE_PID"
  fi
}

trap cleanup INT TERM EXIT

echo "[BOOT] Waiting for Hardhat node on 8545..."
TRIES=0
until curl -sf -X POST -H 'Content-Type: application/json' \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  http://127.0.0.1:8545 >/dev/null; do
  TRIES=$((TRIES + 1))
  if [ "$TRIES" -ge 30 ]; then
    echo "[BOOT] Hardhat node did not become ready in time"
    cat /tmp/hardhat.log
    exit 1
  fi
  sleep 1
done

echo "[BOOT] Hardhat node is ready, compiling and deploying contract"
rm -f /app/deployments/contract-address.json
npx hardhat compile
npx hardhat run --network localhost ./scripts/deploy.js

echo "[BOOT] Blockchain service is ready"
wait "$NODE_PID"
