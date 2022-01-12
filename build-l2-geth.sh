#!/bin/sh

echo "building refl2geth to current directory"
cd ./reference-optimistic-geth
go mod download
go build -o refl2geth ./cmd/geth
mv refl2geth ..
cd ..


# Create L2 data dir
echo "initializing refl2geth with l2_genesis.json"
./refl2geth init --datadir data_l2 l2_genesis.json
