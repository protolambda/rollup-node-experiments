#!/bin/sh

echo "building and getting contract bytecode"
cd ./optimistic-specs/packages/contracts
yarn
yarn build
cat artifacts/contracts/L2/L1Block.sol/L1Block.json | jq -r .deployedBytecode > ../../../bytecode_l2_l1block.txt
cat artifacts/contracts/L1/DepositFeed.sol/DepositFeed.json | jq -r .deployedBytecode > ../../../bytecode_l1_depositfeed.txt

