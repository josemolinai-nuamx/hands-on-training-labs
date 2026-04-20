# Smart Contract

`AssetRegistry.sol` emite el evento `AssetTransferred` y evita almacenar estado on-chain de forma intencional. El laboratorio se enfoca en registrar el hecho inmutable de la transferencia mientras el estado de negocio enriquecido vive off-chain en PostgreSQL.

Este es el trade-off principal que se demuestra: guardar todos los campos de negocio on-chain suele ser un antipatron, mientras que usar eventos entrega un disparador auditable para integracion aguas abajo.

Puedes inspeccionar el nodo blockchain directamente via JSON-RPC:

```bash
curl -X POST http://localhost:8545 \
  -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
```

Para verificar que la direccion publicada en `contract-address.json` existe de verdad en el nodo actualmente activo, consulta `eth_getCode`:

```bash
curl -X POST http://localhost:8545 \
  -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","method":"eth_getCode","params":["0x5FbDB2315678afecb367f032d93F642f64180aa3","latest"],"id":1}'
```

Si el resultado es `0x`, el deployment artifact y el nodo Hardhat activo estan desalineados. En ese estado la API puede seguir devolviendo un hash de transaccion, pero el listener nunca confirmara la transferencia porque no hay codigo de contrato en la direccion publicada.