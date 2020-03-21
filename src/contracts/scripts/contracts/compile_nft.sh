#!/bin/bash

echo "Compiling NFT contract..."
ligo compile-contract src/nft.ligo main > build/nft.tz

echo "Compiling NFT contract's initial storage..."
ligo compile-storage src/nft.ligo main 'record [
  nfts = (map [] : map(nat, record [ owner : address; data : bytes ]));
  contractOwner = ("KT1DfXasH5xziaqfmhyzi3cJyP8UmMjtShWQ" : address)
]' > build/nft.init.tz
