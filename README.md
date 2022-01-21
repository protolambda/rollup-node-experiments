# rollup node experiments

Test scripts etc. for *experimental* optimistic rollup testing of the new [Optimism 1.0 specs](https://github.com/ethereum-optimism/optimistic-specs).

## Config preparation

Change `rollup.yaml` for custom premine / testnet ID / L1 clique signers.

### Optional: recompile system contracts bytecode.

Compile and fetch deployed bytecode, to embed in local testnet genesis states.
```shell
cd ../optimistic-specs/packages/contracts
yarn build
cat artifacts/contracts/L2/L1Block.sol/L1Block.json | jq -r .deployedBytecode > ../../../rollup-node-experiments/bytecode_l2_l1block.txt
cat artifacts/contracts/L1/DepositFeed.sol/DepositFeed.json | jq -r .deployedBytecode > ../../../rollup-node-experiments/bytecode_l1_depositfeed.txt
```

### generate configs

Build the L1 and L2 chain genesis configurations:
```shell
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# generate a `l1_genesis.json` and `l2_genesis.json` for local L1 and L2 geth instances
python gen_confs.py
```

## Node setup

### L1 setup

Run `./build-l1-geth.sh` or,

```shell
# install upstream geth:
go install github.com/ethereum/go-ethereum/cmd/geth@v1.10.15

# Create L1 data dir
geth init --datadir data_l1 l1_genesis.json

# Import the clique signer secret key into geth
echo -n "foobar" > signer_password.txt
geth --datadir data_l1 account import --password=signer_password.txt signer_0x30eC912c5b1D14aa6d1cb9AA7A6682415C4F7Eb0
```

Run `./start-l1-geth.sh` or...

```
# Start L1 Geth with block production enabled:
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
    --password=signer_password.txt --mine
    --dev --dev.period=0
```

### L2 exec-engine setup

Run `./build-l2-geth.sh` or...

Clone and build the `optimism-prototype` branch into the parent directory containing this repo:

```shell
# Prepare L2 binary (or `go run` directly from source instead)
git clone --branch optimism-prototype https://github.com/ethereum-optimism/reference-optimistic-geth
cd reference-optimistic-geth
go mod download
go build -o refl2geth ./cmd/geth
mv refl2geth ../rollup-node-experiments/
cd ../rollup-node-experiments/

# Create L2 data dir
./refl2geth init --datadir data_l2 l2_genesis.json
```

Then run `./start-l2-geth.sh` or...

```
# Run L2 geth
# Important: expose engine RPC namespace and activate the merge functionality.

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
# TODO: remove maxpeers=0 and --nat=none if testing with more local nodes


```

### Rollup-node setup

Run `./get-genesis-hashes.sh` or,

```
# Get the L1 genesis block hash
curl -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["0x0", false],"id":1}' http://localhost:8545 | jq -r ".result.hash" | tee l1_genesis_hash.txt

# Get the L2 genesis block hash
curl -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["0x0", false],"id":1}' http://localhost:9000 | jq -r ".result.hash" | tee l2_genesis_hash.txt
```

Run `./build-rollup-node.sh` or,

```shell
# Prepare rollup-node binary (or `go run` directly from source instead)
git clone https://github.com/ethereum-optimism/optimistic-specs
cd optimistic-specs
go mod download
go build -o rollupnode ./opnode/cmd
mv rollupnode ../rollup-node-experiments/
cd ../rollup-node-experiments/
```


Then run `./start-rollup-node.sh` or,

```
./rollupnode run \
 --l1=ws://localhost:8546 \
 --l2=ws://localhost:9001 \
 --log.level=debug \
 --genesis.l1-hash=$(cat l1_genesis_hash.txt) \
 --genesis.l1-num=0 \
 --genesis.l2-hash=$(cat l2_genesis_hash.txt)
```

### Resetting

In order to restart the test with a new build, you will likely want to wipe the chainstate, which
will also require rebuilding the l1 and l2 nodes. This can be accomplished by running the following
scripts:

```
# deletes both data_l1 and data_l2 dirs
./clean.sh

# rebuild and start l1-geth
./build-l1-geth.sh && ./start-l1-geth.sh

# rebuild and start l2-geth
./build-l2-geth.sh && ./start-l2-geth.sh

# rebuild and start rollup-node
./get-genesis-hashes.sh && ./build-rollup-node.sh && ./start-rollup-node.sh
```


## License

MIT, see [`LICENSE`](./LICENSE) file.

