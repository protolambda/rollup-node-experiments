#!/bin/sh

# install upstream geth:
echo "Install upstream geth"
go install github.com/ethereum/go-ethereum/cmd/geth@v1.10.15

echo "Create L1 data dir"
geth init --datadir data_l1 l1_genesis.json

echo "import clique signer"
echo "foobar\c" > signer_password.txt
geth --datadir data_l1 account import --password=signer_password.txt signer_0x30eC912c5b1D14aa6d1cb9AA7A6682415C4F7Eb0
