#!/bin/sh
set -eu

## Estado del nodo

# Versión del cliente: Devuelve la versión de Besu y del cliente Ethereum
curl -s -X POST http://localhost:8545  -H "Content-Type: application/json"  --data '{ "jsonrpc": "2.0", "method": "web3_clientVersion", "params": [], "id": 1 }' 

# Network ID: Retorna el identificador numérico de la red
curl -s -X POST http://localhost:8545 -H "Content-Type: application/json" --data '{ "jsonrpc": "2.0", "method": "net_version", "params": [], "id": 1 }'

# ¿Está escuchando?: Verifica si el nodo acepta conexiones P2P
curl -s -X POST http://localhost:8545  -H "Content-Type: application/json" --data '{ "jsonrpc": "2.0", "method": "net_listening", "params": [], "id": 1 }'

# Peers conectados: Cantidad de peers actualmente conectados
curl -s -X POST http://localhost:8545 -H "Content-Type: application/json" --data '{ "jsonrpc": "2.0", "method": "net_peerCount", "params": [], "id": 1 }'


# Bloque actual: Número del último bloque sincronizado (en hex)
curl -s -X POST http://localhost:8545  -H "Content-Type: application/json" --data '{ "jsonrpc": "2.0", "method": "eth_blockNumber",  "params": [], "id": 1 }'

# ¿En sincronización?: Muestra el progreso de sync o false si ya está sincronizado
curl -s -X POST http://localhost:8545  -H "Content-Type: application/json" --data '{ "jsonrpc": "2.0", "method": "eth_syncing", "params": [], "id": 1 }'
