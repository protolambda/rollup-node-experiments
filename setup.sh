#!/bin/sh

echo "Running initial setup"

echo "creating .mnemonic file from rollup.yaml"
echo $(grep "mnemonic:" rollup.yaml | cut -c12- | rev | cut -c2- | rev ) > .mnemonic

echo "Fetching submodules"
git submodule init
git submodule update

./build-contracts.sh

echo "Build the L1 and L2 chain genesis configurations"

mkdir -p logs
python -m venv venv
. venv/bin/activate
echo "logging pip install results to logs/pip.log"
pip install -r requirements.txt > logs/pip.log 2>&1
if [[ $? != 0 ]]; then
    "PIP INSTALL FAILED -- check logs/pip.log for details"
fi
python gen_confs.py
