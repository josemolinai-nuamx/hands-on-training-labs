# Incidentes

## Divergencia off-chain/on-chain

1. Run `docker compose stop event-listener`.
2. Submit a new transfer.
3. Verify the dashboard shows `PENDING` indefinitely.
4. Restart the listener and note that the status does not backfill automatically.

## Nodo RPC no disponible

1. Run `docker compose stop blockchain`.
2. Try to submit a transfer.
3. Observe the API returning an upstream failure because the signer cannot send the transaction.

## Arranque parcial y artefacto de despliegue

1. Recreate `blockchain` and `event-listener` at the same time.
2. Watch `docker compose logs -f event-listener` during the first few seconds.
3. Notice that temporary `Deployment file not ready yet` warnings can appear until `blockchain` finishes writing `/shared/contract-address.json`.
4. If the published contract address does not match the active node, transfers can remain `PENDING` even when the API already has a `txHash`.

Mitigations demonstrated in this lab:

- `blockchain/scripts/start.sh` removes stale deployment metadata before deploy.
- The deploy step runs against the long-lived local node.
- `event-listener` retries startup dependencies instead of failing immediately on a transient database race.

## Direccion invalida

Submit a transfer with an invalid `to` value and compare the API validation error with a blockchain-level failure.
