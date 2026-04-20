# Incidentes

## Divergencia off-chain/on-chain

1. Ejecuta `docker compose stop event-listener`.
2. Envia una transferencia nueva.
3. Verifica que el dashboard queda en `PENDING` indefinidamente.
4. Reinicia el listener y observa que no hay backfill automatico del estado.

## Nodo RPC no disponible

1. Ejecuta `docker compose stop blockchain`.
2. Intenta enviar una transferencia.
3. Observa que la API responde un error aguas arriba porque el signer no puede enviar la transaccion.

## Arranque parcial y artefacto de despliegue

1. Recrea `blockchain` y `event-listener` al mismo tiempo.
2. Observa `docker compose logs -f event-listener` durante los primeros segundos.
3. Veras warnings temporales `Deployment file not ready yet` hasta que `blockchain` termine de escribir `/shared/contract-address.json`.
4. Si la direccion publicada no coincide con el nodo activo, las transferencias pueden quedar en `PENDING` aunque la API ya tenga `txHash`.

Mitigaciones demostradas en este laboratorio:

- `blockchain/scripts/start.sh` elimina metadatos de despliegue obsoletos antes de desplegar.
- El deploy se ejecuta contra el nodo local de larga vida.
- `event-listener` reintenta dependencias de arranque en vez de fallar de inmediato ante una carrera transitoria de base de datos.

## Direccion invalida

Envia una transferencia con un `to` invalido y compara el error de validacion de API con un fallo de nivel blockchain.