# Glosario

- RPC: remote procedure call endpoint exposed by the blockchain node.
- ABI: contract interface used by ethers to encode function calls and decode events.
- txHash: unique identifier of a blockchain transaction.
- blockNumber: the mined block height where the event was included.
- event: log emitted by the smart contract.
- PENDING: off-chain record created before blockchain confirmation.
- CONFIRMED: off-chain record updated after the event listener processes the blockchain event.
- FAILED: off-chain record marked as failed because the transaction could not be submitted.
- signer: wallet that signs the transaction sent by the API.
- provider: JSON-RPC connection to the blockchain node.
- deployment artifact: shared JSON file containing the deployed contract address and ABI consumed by the API and listener.
- off-chain: mutable application state stored outside the blockchain.
- on-chain: immutable event recorded in the blockchain node.
