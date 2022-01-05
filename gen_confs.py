from web3.auto import w3
import json
import ruamel.yaml as yaml
import sys
import time

# software hierarchical derivation, use a hardware wallet for production instead!
w3.eth.account.enable_unaudited_hdwallet_features()

rollup_config_path = "rollup.yaml"
if len(sys.argv) > 1:
    rollup_config_path = sys.argv[1]

with open(rollup_config_path) as stream:
    data = yaml.safe_load(stream)

common_forks = {
    "homesteadBlock": 0,
    "eip150Block": 0,
    "eip155Block": 0,
    "eip158Block": 0,
    "byzantiumBlock": 0,
    "constantinopleBlock": 0,
    "petersburgBlock": 0,
    "istanbulBlock": 0,
    "berlinBlock": 0,
}

l1_genesis_time = time.time()

# Allocate 1 wei to all possible pre-compiles.
# See https://github.com/ethereum/EIPs/issues/716 "SpuriousDragon RIPEMD bug"
# E.g. Rinkeby allocates it like this.
# See https://github.com/ethereum/go-ethereum/blob/092856267067dd78b527a773f5b240d5c9f5693a/core/genesis.go#L370
precompile_alloc = {
    "0x" + i.to_bytes(length=20, byteorder='big').hex(): {
        "balance": "1",
    } for i in range(256)
}

premine_alloc = {}
for key, value in data['premine'].items():
    acct = w3.eth.account.from_mnemonic(data['mnemonic'], account_path=key, passphrase='')
    weival = value.replace('ETH', '0' * 18)
    premine_alloc[acct.address] = {"balance": weival}


clique_extra_data = b'\x00' * 32
for signer_path in data['clique_signers']:
    clique_signer_acct = w3.eth.account.from_mnemonic(data['mnemonic'], account_path=signer_path, passphrase='')
    clique_extra_data += bytes.fromhex(clique_signer_acct.address[2:])
clique_extra_data += b'\x00' * 65

with open('bytecode_l2_l1block.txt', 'rt') as f:
    bytecode_l2_l1block = f.read()

with open('bytecode_l1_depositfeed.txt', 'rt') as f:
    bytecode_l1_depositfeed = f.read()

l1_out = {
    "config": {
        "chainId": int(data['l1_chain_id']),
        **common_forks,
        "clique": {
            "period": 6,  # block time
            "epoch": 30000
        }
    },
    "alloc": {
        **precompile_alloc,
        **premine_alloc,
        data['deposit_contract_address']: {
            "balance": "0",
            "code": bytecode_l1_depositfeed,
            "storage": {}
        }
    },
    "coinbase": "0x0000000000000000000000000000000000000000",
    "difficulty": "0x01",
    "extraData": "0x" + clique_extra_data.hex(),
    "gasLimit": "0x400000",
    "nonce": "0x1234",
    "mixhash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "timestamp": str(l1_genesis_time),
    "baseFeePerGas": "0x7"
}

l2_out = {
    "config": {
        "chainId": int(data['l2_chain_id']),
        **common_forks,
        # activate merge features from genesis
        "mergeForkBlock": 0,
        "terminalTotalDifficulty": 0,
    },
    "alloc": {
        **precompile_alloc,
        **premine_alloc,
        data['l1_info_predeploy_address']: {
            "balance": "0",
            "code": bytecode_l2_l1block,
            "storage": {}
        },
    },
    "coinbase": "0x0000000000000000000000000000000000000000",
    "difficulty": "0x01",
    "extraData": "",
    "gasLimit": "0x400000",
    "nonce": "0x1234",
    "mixhash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "timestamp": str(l1_genesis_time),
    "baseFeePerGas": "0x7"
}

with open("l1_genesis.json", "wt") as f:
    json.dump(l1_out, f, indent='  ')

with open("l2_genesis.json", "wt") as f:
    json.dump(l2_out, f, indent='  ')
