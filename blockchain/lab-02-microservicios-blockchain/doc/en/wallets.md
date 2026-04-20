# Available Wallet Addresses

You can discover the available wallet addresses in several ways:

## 1. **Deployment File** (easiest)

After the lab is running, query the file containing the contract deployment metadata.
The file lives inside a Docker named volume, not on the host filesystem, so you must access it through a container:

```bash
docker compose exec api-service cat /shared/contract-address.json
```

With formatting (requires `jq`):

```bash
docker compose exec api-service cat /shared/contract-address.json | jq '.accounts, .deployerAddress'
```

This file is generated during deployment and contains:
- `accounts`: array with the first 5 available wallet addresses
- `deployerAddress`: the address that deployed the smart contract

## 2. **Hardhat Logs**

When the blockchain container starts, Hardhat automatically prints all 20 available test accounts. To view them:

```bash
docker compose logs blockchain | grep "Account #"
```

## 3. **From the blockchain container**

Alternatively, access the file directly from the blockchain container (same volume, different mount path):

```bash
docker compose exec blockchain cat /app/deployments/contract-address.json
```

## Structure of `contract-address.json`

```json
{
  "address": "0x...",
  "abi": [...],
  "deployerAddress": "0x8ba1f109551bD432803012645Ac136ddd64DBA72",
  "accounts": [
    "0x8ba1f109551bD432803012645Ac136ddd64DBA72",
    "0x0Ee128e8373f356Ce63f0AEe298e267768140D30",
    "0x6e71edae12b1b97f1d1a1c0d1fc8a5e3d12b1b9f",
    "0x f39fd6e51aad88f6f4ce6ab8827279cfffb92266",
    "0x70997970c51812e339d9b73b0245ad59e1c08af0"
  ]
}
```

## Using Wallet Addresses

The addresses in the `accounts` array are the wallets you can use to perform transfers through the API endpoint at `POST /api/transfer`.

### Example Transfer Request

```bash
curl -X POST http://localhost:3000/api/transfer \
  -H 'Content-Type: application/json' \
  -d '{
    "from": "0x8ba1f109551bD432803012645Ac136ddd64DBA72",
    "to": "0x0Ee128e8373f356Ce63f0AEe298e267768140D30",
    "assetId": "ASSET-123",
    "assetName": "Gold Bullion",
    "quantity": 50
  }'
```

All wallet addresses in the test environment are pre-funded by Hardhat and ready to use for testing transfer flows.
