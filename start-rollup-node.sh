.#!/bin/sh

echo "Running rollupnode"
./rollupnode run \
  --l1=ws://localhost:8546,ws://localhost:8546,ws://localhost:8546,ws://localhost:8546 \
  --l2=ws://localhost:9001 \
  --log.level=debug \
  --genesis.l1-hash=$(cat l1_genesis_hash.txt) \
  --genesis.l1-num=0 \
  --genesis.l2-hash=$(cat l2_genesis_hash.txt)
