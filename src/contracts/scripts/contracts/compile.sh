#!/bin/bash

mkdir -p ./build
./scripts/contracts/compile_nft.sh
./scripts/contracts/compile_oracle.sh
./scripts/contracts/compile_reward_proxy.sh
