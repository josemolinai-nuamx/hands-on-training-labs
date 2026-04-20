# Flujo Tecnico

1. Un cliente envia `assetId` y `to` a `POST /api/transfer`.
2. La API valida ambos campos y rechaza direcciones Ethereum mal formadas.
3. La API guarda una transferencia en estado `PENDING` en PostgreSQL.
4. La API firma una transaccion con la clave local de Hardhat configurada.
5. La API ejecuta `AssetRegistry.transfer(to, assetId)`.
6. Hardhat mina la transaccion y emite `AssetTransferred`.
7. El listener recibe el evento por el proveedor RPC.
8. El listener actualiza la fila asociada por `tx_hash` a `CONFIRMED`.
9. El dashboard consulta `GET /api/transfers` cada 2 segundos.
10. La UI refleja el cambio de `PENDING` a `CONFIRMED` sin recargar.

En modo local de Hardhat la confirmacion suele verse en 1 a 2 segundos porque cada transaccion se mina automaticamente.

## Puntos de observabilidad

Usa estos checkpoints durante el laboratorio para demostrar cada etapa del flujo:

1. `POST /api/transfer` responde `transferId`, `txHash` y estado inicial `PENDING`.
2. `eth_getTransactionReceipt` muestra la transaccion minada y el log `AssetTransferred`.
3. `docker compose logs event-listener` muestra `AssetTransferred event processed`.
4. `GET /api/transfers/:id` finalmente responde `CONFIRMED` con `block_number`.

## Modo de falla para explicar

Si el deployment artifact no corresponde al nodo Hardhat que esta corriendo, la API puede seguir obteniendo un `txHash`, pero la direccion publicada para los otros servicios puede no tener bytecode de contrato. En ese estado el listener no confirma la fila y la transferencia queda atascada en `PENDING` hasta realinear metadatos de despliegue con el nodo activo.