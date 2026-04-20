# Direcciones de Wallet Disponibles

Puedes conocer las direcciones de wallet disponibles de varias formas:

## 1. **Archivo de despliegue** (mas facil)

Despues de que el laboratorio este en marcha, consulta el archivo que contiene el metadata del contrato.
El archivo vive dentro de un volumen Docker nombrado, no en el filesystem del host, por lo que debes acceder a traves de un contenedor:

```bash
docker compose exec api-service cat /shared/contract-address.json
```

Con formato (requiere `jq`):

```bash
docker compose exec api-service cat /shared/contract-address.json | jq '.accounts, .deployerAddress'
```

Este archivo se genera durante el deploy y contiene:
- `accounts`: array con las primeras 5 direcciones de wallet disponibles
- `deployerAddress`: la direccion que desplego el contrato inteligente

## 2. **Logs de Hardhat**

Cuando el contenedor blockchain inicia, Hardhat imprime automaticamente todas las 20 cuentas de prueba disponibles. Para verlas:

```bash
docker compose logs blockchain | grep "Account #"
```

## 3. **Desde el contenedor blockchain**

Alternativamente, accede al archivo directamente desde el contenedor blockchain (mismo volumen, ruta de montaje diferente):

```bash
docker compose exec blockchain cat /app/deployments/contract-address.json
```

## Estructura del archivo `contract-address.json`

```json
{
  "address": "0x...",
  "abi": [...],
  "deployerAddress": "0x8ba1f109551bD432803012645Ac136ddd64DBA72",
  "accounts": [
    "0x8ba1f109551bD432803012645Ac136ddd64DBA72",
    "0x0Ee128e8373f356Ce63f0AEe298e267768140D30",
    "0x6e71edae12b1b97f1d1a1c0d1fc8a5e3d12b1b9f",
    "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
    "0x70997970c51812e339d9b73b0245ad59e1c08af0"
  ]
}
```

## Usar Direcciones de Wallet

Las direcciones en el array `accounts` son las wallets que puedes usar para realizar transferencias mediante el endpoint de la API en `POST /api/transfer`.

### Ejemplo de Solicitud de Transferencia

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

Todas las direcciones de wallet en el entorno de prueba estan pre-financiadas por Hardhat y listas para usar en pruebas de flujos de transferencia.
