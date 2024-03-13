#!/bin/bash

geth --datadir ./ --networkid 66 --http --http.corsdomain "*" --allow-insecure-unlock --http.api "eth,web3,net,personal" &

sleep 5

geth attach /Users/user/PycharmProjects/BlockchainApp/geth/geth.ipc --exec "miner.start(1)"

python3 /Users/user/PycharmProjects/BlockchainApp/app.py
