#!/bin/sh

echo "Start L2 geth"
./refl2geth --datadir data_l2 \
    --networkid 901 --catalyst \
    --http --http.api "net,eth,consensus,engine" \
    --http.port 9000 \
    --http.addr 127.0.0.1 \
    --http.corsdomain "*" \
    --ws --ws.api "net,eth,consensus,engine" \
    --ws.port=9001 \
    --ws.addr 0.0.0.0 \
    --port=30304 \
    --nat=none \
    --maxpeers=0 \
    --vmodule=rpc=5
