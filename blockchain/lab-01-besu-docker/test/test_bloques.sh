#!/bin/sh
set -eu


## Información de bloques

# Último bloque (completo): Detalle completo del bloque más reciente con transacciones
curl -s -X POST http://localhost:8545  -H "Content-Type: application/json" --data '{ "jsonrpc": "2.0", "method": "eth_getBlockByNumber", "params": [ "latest",  "true"   ],   "id": 1 }'

# Genesis block : Información del bloque 0 (genesis)
curl -s -X POST http://localhost:8545 -H "Content-Type: application/json" --data '{ "jsonrpc": "2.0", "method": "eth_getBlockByNumber", "params": [ "0x0", "false" ], "id": 1 }'

# Chain ID: Identificador de cadena para firma de transacciones (EIP-155)
curl -s -X POST http://localhost:8545 -H "Content-Type: application/json" --data '{ "jsonrpc": "2.0", "method": "eth_chainId", "params": [],  "id": 1 }'

# Gas price: Precio de gas estimado en wei
curl -s -X POST http://localhost:8545  -H "Content-Type: application/json" --data '{ "jsonrpc": "2.0", "method": "eth_gasPrice", "params": [],  "id": 1 }'

# loop de shell para ver el avance de bloques en tiempo real
watch -n 5 'curl -s -X POST http://localhost:8547    -H "Content-Type: application/json"  --data '"'"'{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'"'"' | python3 -m json.tool'