# Smart Contract

`AssetRegistry.sol` emits an `AssetTransferred` event and intentionally avoids on-chain storage. The lab focuses on recording the immutable fact of the transfer while leaving the rich state off-chain in PostgreSQL.

This is the important trade-off being demonstrated: storing every business field on-chain is often an antipattern, while using events gives an auditable trigger for downstream integration.

You can inspect the blockchain node directly with JSON-RPC:

```bash
curl -X POST http://localhost:8545 \
  -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
```

To verify that the contract address published in `contract-address.json` really exists on the currently running node, query `eth_getCode`:

```bash
curl -X POST http://localhost:8545 \
  -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","method":"eth_getCode","params":["0x5FbDB2315678afecb367f032d93F642f64180aa3","latest"],"id":1}'
```

If the result is `0x`, the deployment artifact and the active Hardhat node are out of sync. In that state the API can still submit a transaction hash, but the listener will never confirm the transfer because there is no contract code at the published address.
