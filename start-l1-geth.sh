#!/bin/sh

echo "import clique signer"
geth --datadir data_l1 account import --password=signer_password.txt signer_0x30eC912c5b1D14aa6d1cb9AA7A6682415C4F7Eb0

echo "start L1 geth with block production enabled"
geth --datadir data_l1 \
    --networkid 900 \
    --http --http.api "net,eth,consensus" \
    --http.port 8545 \
    --http.addr 127.0.0.1 \
    --http.corsdomain "*" \
    --ws --ws.api "net,eth,consensus" \
    --ws.port=8546 \
    --ws.addr 0.0.0.0 \
    --maxpeers=0 \
    --vmodule=rpc=5 \
    --allow-insecure-unlock --unlock 0x30eC912c5b1D14aa6d1cb9AA7A6682415C4F7Eb0 \
    --password=signer_password.txt --mine \
    --dev --dev.period=0
