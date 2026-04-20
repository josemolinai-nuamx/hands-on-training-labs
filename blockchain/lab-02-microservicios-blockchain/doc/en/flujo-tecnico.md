# Flujo Tecnico

1. A client submits `assetId` and `to` to `POST /api/transfer`.
2. The API validates both fields and rejects malformed Ethereum addresses early.
3. The API stores a `PENDING` transfer in PostgreSQL.
4. The API signs a transaction with the configured local Hardhat private key.
5. The API calls `AssetRegistry.transfer(to, assetId)`.
6. Hardhat mines the transaction and emits `AssetTransferred`.
7. The listener receives the event through the RPC provider.
8. The listener updates the matching row by `tx_hash` to `CONFIRMED`.
9. The dashboard polls `GET /api/transfers` every 2 seconds.
10. The UI reflects the transition from `PENDING` to `CONFIRMED` without reloading.

In local Hardhat mode the confirmation is usually visible in about 1 to 2 seconds because each transaction is mined automatically.

## Observability checkpoints

Use these checkpoints during the lab to prove each stage of the flow:

1. `POST /api/transfer` returns `transferId`, `txHash`, and initial `PENDING` status.
2. `eth_getTransactionReceipt` shows the transaction was mined and contains the `AssetTransferred` log.
3. `docker compose logs event-listener` shows `AssetTransferred event processed`.
4. `GET /api/transfers/:id` eventually returns `CONFIRMED` with `block_number`.

## Failure mode to explain

If the deployment artifact does not correspond to the currently running Hardhat node, the API can still obtain a `txHash`, but the address published to the other services may not contain contract code. In that state the listener never confirms the row, and the transfer remains stuck in `PENDING` until the deployment metadata is realigned with the active node.
