# Ejercicios

## Ejercicio 1 - Flujo basico

1. Envia una transferencia desde el dashboard o con `curl`.
2. Confirma que la API responde de inmediato con `transferId` y `txHash`.
3. Observa en dashboard la transicion de `PENDING` a `CONFIRMED`.
4. Compara esa transicion con `docker compose logs -f event-listener`.

## Ejercicio 2 - Observar asincronia

1. Manten tres ventanas abiertas: dashboard, logs de API y logs de listener.
2. Envia varias transferencias en secuencia rapida.
3. Correlaciona la aceptacion en API con el procesamiento posterior del listener.
4. Nota que la respuesta REST llega antes de la confirmacion off-chain.

## Ejercicio 3 - Divergencia off-chain/on-chain

1. Ejecuta `docker compose stop event-listener`.
2. Envia una nueva transferencia.
3. Observa que PostgreSQL y dashboard quedan en `PENDING` aunque blockchain ya emitio el evento.
4. Reinicia el listener con `docker compose start event-listener`.
5. Confirma que en este laboratorio no hay reprocesamiento automatico de eventos perdidos.

## Ejercicio 4 - Explorar RPC

1. Consulta `eth_blockNumber` directamente en Hardhat.
2. Consulta `eth_getTransactionByHash` o `eth_getTransactionReceipt` para una transferencia generada por el laboratorio.
3. Consulta `eth_getCode` para la direccion del contrato desplegado.
4. Verifica que un despliegue sano devuelve bytecode y no `0x`.

## Ejercicio 5 - Verificar artefacto de despliegue

1. Inspecciona la direccion del contrato publicada en `/shared/contract-address.json` desde los contenedores en ejecucion.
2. Compara esa direccion con la que aparece en `docker compose logs blockchain`.
3. Valida la direccion con `eth_getCode`.
4. Discute por que un deployment artifact obsoleto puede dejar transferencias en `PENDING` incluso cuando existe `txHash`.