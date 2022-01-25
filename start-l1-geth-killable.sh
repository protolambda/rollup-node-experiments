#!/bin/bash

# The trap/wait logic ensures that killing this script also kills the node.
# cf. https://stackoverflow.com/a/1645157 for details

trap : SIGTERM SIGINT

mkdir -p logs
LOGFILE=logs/l1-geth.log
PORT=8545

nohup geth --datadir data_l1 \
    --networkid 900 \
    --http --http.api "net,eth,consensus" \
    --http.port $PORT \
    --http.addr 127.0.0.1 \
    --http.corsdomain "*" \
    --ws --ws.api "net,eth,consensus" \
    --ws.port=8546 \
    --ws.addr 0.0.0.0 \
    --maxpeers=0 \
    --vmodule=rpc=5 \
    --allow-insecure-unlock --unlock 0x30eC912c5b1D14aa6d1cb9AA7A6682415C4F7Eb0 \
    --password=signer_password.txt --mine \
    --dev --dev.period=0 \
    > $LOGFILE 2>&1 &
PID=$!

echo "running L1 geth in background, port: $PORT, PID: $PID, logging to $LOGFILE"

wait $PID
EXIT=$?

if [[ $EXIT -gt 128 ]]; then
    kill $PID
fi
