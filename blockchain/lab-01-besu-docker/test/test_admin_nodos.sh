#!/bin/sh
set -eu

## Administración del nodo

# Info del nodo (enode): Devuelve el enode URL, puertos y peers del nodo
curl -s -X POST http://localhost:8545 -H "Content-Type: application/json" --data '{ "jsonrpc": "2.0", "method": "admin_nodeInfo", "params": [], "id": 1 }'

# Lista de peers : Información detallada de cada peer conectado
curl -s -X POST http://localhost:8545 -H "Content-Type: application/json" --data '{ "jsonrpc": "2.0", "method": "admin_peers", "params": [],  "id": 1 }'

# Agregar peer dinámicamente: Conecta el nodo a un peer sin reiniciar (reemplaza el enode)
curl -s -X POST http://localhost:8545 -H "Content-Type: application/json" --data '{ "jsonrpc": "2.0", "method": "admin_addPeer", "params": [ "enode://CLAVE_PUBLICA@IP:30303"  ],  "id": 1 }'
