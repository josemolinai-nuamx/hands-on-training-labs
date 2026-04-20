# Lab: Microservices + Blockchain

Language: English | [Espanol](README.es.md)

This lab demonstrates how a microservice hands off a business action to a local blockchain, persists an off-chain pending record, and relies on an event-driven listener to reconcile the final state asynchronously.

## Architecture

```text
Browser Dashboard --> API Service --> Hardhat Blockchain
        |                 |                |
        |                 v                v
        +------------> PostgreSQL <--- Event Listener
```

## Prerequisites

- Docker Engine with Compose support
- Git
- curl or Postman
- A modern browser

## Quick Start

1. Start the lab:

```bash
./scripts/start.sh
```

`./scripts/start.sh` waits until `GET /api/health` responds before declaring the lab ready.

1. Verify health:

```bash
curl http://localhost:3000/api/health
```

1. Open the dashboard:

```text
http://localhost:8080
```

1. Send a transfer from the CLI:

```bash
curl -X POST http://localhost:3000/api/transfer \
  -H 'Content-Type: application/json' \
  -d '{"assetId":"TEST-001","to":"0x70997970C51812dc3A010C7d01b50e0d17dc79C8"}'
```

## Lab Flow

1. The API validates the input and inserts a `PENDING` transfer in PostgreSQL.
2. The API signs and sends a transaction to the local Hardhat node.
3. The smart contract emits `AssetTransferred` on-chain.
4. The event listener receives the event and updates the off-chain row to `CONFIRMED`.
5. The dashboard polls the API and shows the state transition without reloading.

## Useful Commands

```bash
docker compose ps
docker compose logs -f api-service
docker compose logs -f event-listener
docker compose stop event-listener
./scripts/pause.sh
./scripts/resume.sh
./scripts/stop.sh
./scripts/clean.sh
```

## Documentation

English docs:

- [Architecture](doc/en/arquitectura.md)
- [Technical Flow](doc/en/flujo-tecnico.md)
- [Smart Contract](doc/en/smart-contract.md)
- [Available Wallet Addresses](doc/en/wallets.md)
- [Incidents](doc/en/incidentes.md)
- [Exercises](doc/en/ejercicios.md)
- [Glossary](doc/en/glosario.md)

Spanish docs:

- [Arquitectura](doc/es/arquitectura.md)
- [Flujo Tecnico](doc/es/flujo-tecnico.md)
- [Smart Contract](doc/es/smart-contract.md)
- [Incidentes](doc/es/incidentes.md)
- [Ejercicios](doc/es/ejercicios.md)
- [Glosario](doc/es/glosario.md)

## Troubleshooting

- If a transfer stays in `PENDING`, inspect listener logs with `docker compose logs -f event-listener`.
- If the API fails on startup, inspect `docker compose logs -f blockchain` and ensure `/shared/contract-address.json` was produced from the current Hardhat node startup.
- If the listener logs `Deployment file not ready yet` during the first few seconds of startup, that is expected while the blockchain container finishes compiling and deploying the contract.
- If a transfer stays in `PENDING` even though the transaction was mined, verify that the deployed contract address actually has bytecode on the active node with `eth_getCode`.
- If ports `3000`, `5432`, `8080`, or `8545` are already in use, update the port bindings in `docker-compose.yml`.

Example `eth_getCode` check:

```bash
curl -s -X POST http://localhost:8545 \
  -H 'Content-Type: application/json' \
  --data '{"jsonrpc":"2.0","method":"eth_getCode","params":["0x5FbDB2315678afecb367f032d93F642f64180aa3","latest"],"id":1}'
```

## Notes

- The private key in this repository is public and only valid for local Hardhat development.
- This lab intentionally does not implement replay or backfill of missed blockchain events. That limitation is part of the teaching goal.
