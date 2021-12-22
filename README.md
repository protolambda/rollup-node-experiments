# rollup node experiments

Test scripts etc. for experimental rollup testing.

*untested, work in progress*

```
python -m venv venv
source venv/bin/activate

# generate a `l1_genesis.json` and `l2_genesis.json` for local L1 and L2 geth instances
python gen_confs.py
```

TODO:
- configure PoA in L1 local testnet:
  - configure PoA signers in chain config
  - set genesis extra-data to PoA signer pub

Then:
- setup L1 node with L1 chain config (`geth init --todo`), with upstream geth
- setup L2 engine with L2 chain config (`geth init --todo`), but with https://github.com/ethereum-optimism/reference-optimistic-geth `optimism-prototype` branch
- setup L2 rollup node (https://github.com/ethereum-optimism/optimistic-specs/)

## License

MIT, see [`LICENSE`](./LICENSE) file.

