#!/bin/bash

# The trap/wait logic ensures that killing this script also kills the node.
# cf. https://stackoverflow.com/a/1645157 for details

trap : SIGTERM SIGINT

mkdir -p logs
LOGFILE=logs/l2-geth.log
PORT=9000

nohup ./refl2geth --datadir data_l2 \
    --networkid 901 --catalyst \
    --http --http.api "net,eth,consensus,engine" \
    --http.port $PORT \
    --http.addr 127.0.0.1 \
    --http.corsdomain "*" \
    --ws --ws.api "net,eth,consensus,engine" \
    --ws.port=9001 \
    --ws.addr 0.0.0.0 \
    --port=30304 \
    --nat=none \
    --maxpeers=0 \
    --vmodule=rpc=5 \
    > $LOGFILE 2>&1 &
PID=$!

echo "running L2 geth in background, port: $PORT, PID: $PID, logging to $LOGFILE"

wait $PID
EXIT=$?

if [[ $EXIT -gt 128 ]]; then
    kill $PID
fi
