#!/bin/bash

# The trap/wait logic ensures that killing the scripts also kills the node.
# cf. https://stackoverflow.com/a/1645157 for details

trap : SIGTERM SIGINT

mkdir -p logs
LOGFILE=logs/rollup-node.log

nohup ./rollupnode run \
  --l1=ws://localhost:8546,ws://localhost:8546,ws://localhost:8546,ws://localhost:8546 \
  --l2=ws://localhost:9001 \
  --log.level=debug \
  --genesis.l1-hash=$(cat l1_genesis_hash.txt) \
  --genesis.l1-num=0 \
  --genesis.l2-hash=$(cat l2_genesis_hash.txt) \
  > $LOGFILE 2>&1 &
PID=$!

echo "running rollup in background, PID: $PID, logging to $LOGFILE"

wait $PID
EXIT=$?

if [[ $EXIT -gt 128 ]]; then
    kill $PID
fi
