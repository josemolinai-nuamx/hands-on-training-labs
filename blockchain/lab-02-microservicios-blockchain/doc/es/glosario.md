# Glosario

- RPC: endpoint de llamada remota expuesto por el nodo blockchain.
- ABI: interfaz del contrato usada por ethers para codificar llamadas y decodificar eventos.
- txHash: identificador unico de una transaccion blockchain.
- blockNumber: altura del bloque minado donde se incluyo el evento.
- event: log emitido por el smart contract.
- PENDING: registro off-chain creado antes de la confirmacion blockchain.
- CONFIRMED: registro off-chain actualizado despues de que el listener procesa el evento blockchain.
- FAILED: registro off-chain marcado como fallido porque no se pudo enviar la transaccion.
- signer: wallet que firma la transaccion enviada por la API.
- provider: conexion JSON-RPC al nodo blockchain.
- deployment artifact: archivo JSON compartido con direccion y ABI del contrato desplegado, consumido por API y listener.
- off-chain: estado mutable de aplicacion almacenado fuera de blockchain.
- on-chain: hecho inmutable registrado en el nodo blockchain.