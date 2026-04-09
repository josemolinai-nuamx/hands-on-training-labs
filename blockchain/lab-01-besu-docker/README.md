# Red Hyperledger Besu QBFT para capacitación

Este laboratorio levanta una red privada de **Hyperledger Besu** con **4 nodos validadores**, más **Prometheus** y **Grafana**.

## Requisitos

- Ubuntu 24
- Docker Engine
- Docker Compose Plugin

## Estructura

- `docker-compose.yml`: servicios de la red.
- `config/qbftConfigFile.json`: configuración base usada para generar el `genesis.json` y las claves.
- `scripts/init-network.sh`: genera el material de red la primera vez.
- `monitoring/prometheus.yml`: scrape de métricas Besu.

## Levantar la red

```bash
cd lab-01-besu-docker
docker compose up -d init
docker compose up -d
```

## Ver logs

```bash
docker compose logs -f validator1
docker compose logs -f validator2
docker compose logs -f validator3
docker compose logs -f validator4
```

## Probar RPC

Bloque actual:

```bash
curl -s -X POST http://localhost:8545 \
  -H 'Content-Type: application/json' \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' | jq
```

Cantidad de peers en el validador 1:

```bash
curl -s -X POST http://localhost:8545 \
  -H 'Content-Type: application/json' \
  --data '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":1}' | jq
```

Validadores actuales:

```bash
curl -s -X POST http://localhost:8545 \
  -H 'Content-Type: application/json' \
  --data '{"jsonrpc":"2.0","method":"qbft_getValidatorsByBlockNumber","params":["latest"],"id":1}' | jq
```

## Puertos publicados

- Validador 1 RPC HTTP: `8545`
- Validador 2 RPC HTTP: `8547`
- Validador 3 RPC HTTP: `8549`
- Validador 4 RPC HTTP: `8551`
- Prometheus: `9090`
- Grafana: `3000`

## Credenciales iniciales de Grafana

- usuario: `admin`
- contraseña: `admin`

## Limpiar datos de la red

```bash
docker compose down -v --remove-orphans

sudo rm -fR network/generated
sudo rm  network/shared/genesis.json
sudo rm  network/shared/static-nodes.json
sudo rm -fR network/validator1/data/
sudo rm -fR network/validator2/data/
sudo rm -fR network/validator3/data/
sudo rm -fR network/validator4/data/
```

## Nota importante

Este laboratorio está pensado para **capacitación y demostración**. Antes de usar algo similar fuera de laboratorio, endurece seguridad, restringe puertos, cambia credenciales, evalúa TLS y evita exponer RPC sin controles.
