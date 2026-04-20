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

El servicio API controla la validacion de requests y el envio de transacciones. No es un proxy de blockchain porque aplica reglas de negocio y persiste estado off-chain antes de que el evento on-chain este confirmado.

El event listener representa integracion asincrona. Reacciona a `AssetTransferred` y actualiza la base de datos off-chain solo cuando la confirmacion blockchain ya es visible desde el nodo.

El dashboard hace visible la brecha de consistencia eventual entre el acuse REST y el estado confirmado en blockchain.

El contenedor blockchain tambien publica metadatos de despliegue por medio de un volumen compartido. Ese archivo es una dependencia para API y listener, por lo que el orden de arranque y la frescura del artefacto importan: si el archivo esta obsoleto o no disponible temporalmente, los consumidores pueden fallar o mostrar warnings transitorios durante el arranque.