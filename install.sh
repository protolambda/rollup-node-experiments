#!/bin/bash

echo "Fully automated installation"

if [[ -d data_l1 || -d data_l2 ]] ; then
    read -p "This will wipe data L1 & L2 data directories. Are you sure? (y/n) " -n 1 -r
    echo
    echo $REPLY
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ./clean.sh
    else
        echo "aborting"
        exit 1
    fi
fi

./setup.sh
./build-l1-geth.sh
./build-l2-geth.sh

./start-l1-geth-killable.sh &
L1PID=$!
./start-l2-geth-killable.sh &
L2PID=$!
echo "sleep 10 sec while L1 and L2 nodes boot up"

sleep 10
./get-genesis-hashes.sh

echo "killing L1 and L2 nodes"
kill $L1PID
kill $L2PID

./build-rollup-node.sh
