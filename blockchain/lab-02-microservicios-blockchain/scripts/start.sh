#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "Starting lab environment..."
docker compose up --build -d

echo "Waiting for API health check..."
for attempt in {1..30}; do
  if curl -fsS http://localhost:3000/api/health >/dev/null 2>&1; then
    echo "Lab is ready."
    echo "Dashboard:  http://localhost:8080"
    echo "API:        http://localhost:3000/api/health"
    echo "Blockchain: http://localhost:8545"
    exit 0
  fi
  sleep 2
done

echo "API did not become ready in time. Check logs with: docker compose logs -f"
exit 1
