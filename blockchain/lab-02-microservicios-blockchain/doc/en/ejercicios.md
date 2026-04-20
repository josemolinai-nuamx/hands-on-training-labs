# Ejercicios

## Ejercicio 1 - Flujo basico

1. Send one transfer from the dashboard or with `curl`.
2. Confirm the API returns a `transferId` and `txHash` immediately.
3. Observe the dashboard moving from `PENDING` to `CONFIRMED`.
4. Compare that transition with `docker compose logs -f event-listener`.

## Ejercicio 2 - Observar asincronia

1. Keep three windows open: dashboard, API logs, and listener logs.
2. Send multiple transfers in quick succession.
3. Correlate API acceptance with later listener processing.
4. Note that the REST response arrives before the off-chain state is confirmed.

## Ejercicio 3 - Divergencia off-chain/on-chain

1. Run `docker compose stop event-listener`.
2. Send a new transfer.
3. Observe that PostgreSQL and the dashboard remain in `PENDING` even though the blockchain already emitted the event.
4. Restart the listener with `docker compose start event-listener`.
5. Confirm that the missed event is not replayed automatically in this lab.

## Ejercicio 4 - Explorar RPC

1. Query `eth_blockNumber` directly against Hardhat.
2. Query `eth_getTransactionByHash` or `eth_getTransactionReceipt` for a transfer produced by the lab.
3. Query `eth_getCode` for the deployed contract address.
4. Verify that a healthy deployment returns contract bytecode instead of `0x`.

## Ejercicio 5 - Verificar artefacto de despliegue

1. Inspect the contract address published in `/shared/contract-address.json` through the running containers.
2. Compare that address with the one reported in `docker compose logs blockchain`.
3. Validate the address with `eth_getCode`.
4. Discuss why a stale deployment artifact can leave transfers in `PENDING` even when a `txHash` exists.
