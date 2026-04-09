#!/bin/sh
set -eu

## Transaction Pool

# Estado del mempool: Cantidad de transacciones pendientes y en cola
curl -s -X POST http://localhost:8545 -H "Content-Type: application/json" --data '{ "jsonrpc": "2.0", "method": "txpool_besuStatistics", "params": [], "id": 1 }'


# Transacciones pendientes: Lista todas las txs en estado pending (listas para minar)
curl -s -X POST http://localhost:8545 -H "Content-Type: application/json" --data '{ "jsonrpc": "2.0", "method": "txpool_besuTransactions", "params": [],  "id": 1 }'
