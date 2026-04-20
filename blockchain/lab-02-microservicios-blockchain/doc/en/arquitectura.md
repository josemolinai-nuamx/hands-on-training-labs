# Arquitectura

```text
Dashboard (Nginx + HTML/JS) --> API Service (Express)
            |                         |
            |                         v
            +------------------> PostgreSQL
                                      ^
                                      |
                           Event Listener (ethers)
                                      ^
                                      |
                            Hardhat Local Blockchain
```

The API service owns request validation and transaction submission. It is not a blockchain proxy because it applies business rules and persists the off-chain state before the on-chain event is confirmed.

The event listener represents asynchronous integration. It reacts to `AssetTransferred` and updates the off-chain database only after blockchain confirmation is visible from the node.

The dashboard visualizes the eventual consistency gap that exists between the REST acknowledgement and the blockchain-confirmed state.

The blockchain container also publishes deployment metadata through a shared volume. That file is a dependency for both the API and the listener, which means startup order and artifact freshness matter: if the file is stale or briefly unavailable, consumers can fail or observe temporary warnings during startup.
