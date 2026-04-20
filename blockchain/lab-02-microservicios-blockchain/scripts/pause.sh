#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
docker compose pause
echo "All lab containers are paused."
