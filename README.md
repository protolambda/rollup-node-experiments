# rollup node experiments

Test scripts etc. for experimental rollup testing.

*untested, work in progress*

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

# generate a `l1_genesis.json` and `l2_genesis.json` for local L1 and L2 geth instances
python gen_confs.py
```

## Node setup

### L1 setup

```shell
# install upstream geth:
go install github.com/ethereum/go-ethereum/cmd/geth@v1.10.15

# Create L1 data dir
geth init --datadir data_l1 l1_genesis.json

# Run L1 geth
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
    --vmodule=rpc=5

# Get the genesis block hash
curl -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["0x0", false],"id":1}' http://localhost:8545 | jq -r ".result.hash" | tee l1_genesis_hash.txt

# Import the clique signer secret key into geth
echo -n "foobar" > signer_password.txt
geth --datadir data_l1 account import --password=signer_password.txt signer_0x30eC912c5b1D14aa6d1cb9AA7A6682415C4F7Eb0

# Then, restart with block production enabled:
# Add flag: --allow-insecure-unlock --unlock 0x30eC912c5b1D14aa6d1cb9AA7A6682415C4F7Eb0 --password=signer_password.txt --mine
```

### L2 exec-engine setup

With  `optimism-prototype` branch:

```shell
# Prepare L2 binary (or `go run` directly from source instead)
git clone --branch optimism-prototype https://github.com/ethereum-optimism/reference-optimistic-geth
cd reference-optimistic-geth
go mod download
go build -o refl2geth ./cmd/geth
mv refl2geth ../rollup-node-experiments

# Create L2 data dir
./refl2geth init --datadir data_l2 l2_genesis.json

# Run L2 geth
./refl2geth --datadir data_l2 --networkid 901
```

### Rollup-node setup

TODO:
- optimism specs
- run opnode/cmd
- use genesis hash flags for L1 and L2 block hashes (need script to retrieve from initialized geth nodes)

### General geth setup tips

```
# If public, add:
--nat extip:YOUR_IP_HERE

# If private (you only need a single node for testing local L2 deployment):
--maxpeers=0
```

Then:
- setup L1 node with L1 chain config (`geth init --todo`), with upstream geth
- setup L2 engine with L2 chain config (`geth init --todo`), but with 
- setup L2 rollup node (https://github.com/ethereum-optimism/optimistic-specs/)

## License

MIT, see [`LICENSE`](./LICENSE) file.

