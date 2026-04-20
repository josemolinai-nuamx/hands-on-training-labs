#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

read -r -p "Delete containers, volumes and local build artifacts? (y/N): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "Cancelled."
  exit 0
fi

docker compose down --volumes --rmi local
rm -f blockchain/deployments/contract-address.json
rm -rf blockchain/artifacts blockchain/cache
echo "Environment cleaned."
