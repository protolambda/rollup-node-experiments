#!/bin/sh

echo "building rollup node binary to ./rollupnode"
cd ./optimistic-specs
go mod download
go build -o rollupnode ./opnode/cmd
mv rollupnode ..
cd ..
