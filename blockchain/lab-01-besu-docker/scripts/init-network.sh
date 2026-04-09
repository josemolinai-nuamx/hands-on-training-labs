#!/bin/sh
set -eu

CONFIG_FILE=/config/qbftConfigFile.json
OUT_DIR=/network/generated
SHARED_DIR=/network/shared

rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR" "$SHARED_DIR"

besu operator generate-blockchain-config \
  --config-file="$CONFIG_FILE" \
  --to="$OUT_DIR" \
  --private-key-file-name=key

cp "$OUT_DIR/genesis.json" "$SHARED_DIR/genesis.json"

# Asignar validadores
index=1
for keydir in $(find "$OUT_DIR/keys" -mindepth 1 -maxdepth 1 -type d | sort); do
  node_dir="/network/validator${index}/data"
  mkdir -p "$node_dir"
  cp "$OUT_DIR/genesis.json" "$node_dir/genesis.json"
  cp "$keydir/key" "$node_dir/key"
  cp "$keydir/key.pub" "$node_dir/key.pub"
  index=$((index + 1))
done

if [ "$index" -ne 5 ]; then
  echo "Expected 4 validator directories, found $((index - 1))" >&2
  exit 1
fi

# Función para limpiar pubkey (remueve 0x + saltos de línea)
get_pubkey() {
  sed 's/^0x//' "$1" | tr -d '\n'
}

# Crear static-nodes.json
cat > "$SHARED_DIR/static-nodes.json" <<JSON
[
  "enode://$(get_pubkey /network/validator1/data/key.pub)@172.28.1.11:30303",
  "enode://$(get_pubkey /network/validator2/data/key.pub)@172.28.1.12:30303",
  "enode://$(get_pubkey /network/validator3/data/key.pub)@172.28.1.13:30303",
  "enode://$(get_pubkey /network/validator4/data/key.pub)@172.28.1.14:30303"
]
JSON

# Copiar a cada nodo
for i in 1 2 3 4; do
  cp "$SHARED_DIR/static-nodes.json" "/network/validator${i}/data/static-nodes.json"
done

echo "QBFT network material generated successfully."
ls -R /network