#!/bin/sh
set -eu

docker compose down -v --remove-orphans

sudo rm -fR ../network/generated
sudo rm -f ../network/shared/genesis.json
sudo rm -f ../network/shared/static-nodes.json
sudo rm -fR ../network/validator1/data
sudo rm -fR ../network/validator2/data
sudo rm -fR ../network/validator3/data
sudo rm -fR ../network/validator4/data