# Laboratorio: Microservicios + Blockchain

Idioma: Espanol | [English](README.md)

Este laboratorio muestra como un microservicio delega una accion de negocio a una blockchain local, persiste un registro off-chain en estado pendiente y usa un listener orientado a eventos para reconciliar el estado final de forma asincrona.

## Arquitectura

```text
Dashboard en navegador --> API Service --> Blockchain Hardhat
        |                     |                 |
        |                     v                 v
        +-----------------> PostgreSQL <--- Event Listener
```

## Prerrequisitos

- Docker Engine con soporte de Compose
- Git
- curl o Postman
- Navegador moderno

## Inicio rapido

1. Inicia el laboratorio:

```bash
./scripts/start.sh
```

`./scripts/start.sh` espera hasta que `GET /api/health` responda antes de indicar que el laboratorio esta listo.

1. Verifica salud:

```bash
curl http://localhost:3000/api/health
```

1. Abre el dashboard:

```text
http://localhost:8080
```

1. Envia una transferencia desde CLI:

```bash
curl -X POST http://localhost:3000/api/transfer \
  -H 'Content-Type: application/json' \
  -d '{"assetId":"TEST-001","to":"0x70997970C51812dc3A010C7d01b50e0d17dc79C8"}'
```

## Flujo del laboratorio

1. La API valida el input e inserta una transferencia `PENDING` en PostgreSQL.
2. La API firma y envia una transaccion al nodo local de Hardhat.
3. El contrato inteligente emite `AssetTransferred` on-chain.
4. El listener recibe el evento y actualiza la fila off-chain a `CONFIRMED`.
5. El dashboard consulta periodicamente la API y muestra el cambio de estado sin recargar.

## Comandos utiles

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

## Documentacion

Docs en espanol:

- [Arquitectura](doc/es/arquitectura.md)
- [Flujo Tecnico](doc/es/flujo-tecnico.md)
- [Smart Contract](doc/es/smart-contract.md)
- [Direcciones de Wallet Disponibles](doc/es/wallets.md)
- [Incidentes](doc/es/incidentes.md)
- [Ejercicios](doc/es/ejercicios.md)
- [Glosario](doc/es/glosario.md)

Docs en ingles:

- [Architecture](doc/en/arquitectura.md)
- [Technical Flow](doc/en/flujo-tecnico.md)
- [Smart Contract](doc/en/smart-contract.md)
- [Incidents](doc/en/incidentes.md)
- [Exercises](doc/en/ejercicios.md)
- [Glossary](doc/en/glosario.md)

## Troubleshooting

- Si una transferencia queda en `PENDING`, revisa los logs del listener con `docker compose logs -f event-listener`.
- Si la API falla al iniciar, revisa `docker compose logs -f blockchain` y confirma que `/shared/contract-address.json` se genero desde el arranque actual de Hardhat.
- Si el listener registra `Deployment file not ready yet` durante los primeros segundos de arranque, es esperado mientras el contenedor de blockchain termina de compilar y desplegar el contrato.
- Si una transferencia queda en `PENDING` aunque la transaccion fue minada, verifica que la direccion del contrato desplegado tenga bytecode en el nodo activo con `eth_getCode`.
- Si los puertos `3000`, `5432`, `8080` o `8545` estan ocupados, ajusta los puertos en `docker-compose.yml`.

Ejemplo de validacion con `eth_getCode`:

```bash
curl -s -X POST http://localhost:8545 \
  -H 'Content-Type: application/json' \
  --data '{"jsonrpc":"2.0","method":"eth_getCode","params":["0x5FbDB2315678afecb367f032d93F642f64180aa3","latest"],"id":1}'
```

## Notas

- La clave privada en este repositorio es publica y solo valida para desarrollo local con Hardhat.
- Este laboratorio intencionalmente no implementa replay o backfill de eventos perdidos de blockchain. Esa limitacion forma parte del objetivo de aprendizaje.