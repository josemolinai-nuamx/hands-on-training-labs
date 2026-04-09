#!/bin/sh
set -eu

## Consenso QBFT

# Validadores actuales: Lista las direcciones de todos los validadores en el bloque más reciente
curl -s -X POST http://localhost:8545 -H "Content-Type: application/json"  --data '{ "jsonrpc": "2.0", "method": "qbft_getValidatorsByBlockNumber", "params": [ "latest" ], "id": 1 }'

# Validadores en bloque N : Validadores en un bloque específico (útil para auditar cambios históricos)
curl -s -X POST http://localhost:8545 -H "Content-Type: application/json" --data '{ "jsonrpc": "2.0", "method": "qbft_getValidatorsByBlockNumber", "params": [ "0x1" ], "id": 1 }'

