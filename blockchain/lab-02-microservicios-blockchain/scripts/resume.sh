#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
docker compose unpause
echo "All lab containers are running again."
