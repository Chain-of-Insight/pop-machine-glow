#!/bin/bash

echo "Compiling RewardProxy contract..."
ligo compile-contract src/reward_proxy.ligo main > build/reward_proxy.tz

echo "Compiling RewardProxy contract's initial storage..."
ligo compile-storage src/reward_proxy.ligo main 'record [
  trustedContracts = (set [] : set(address));
  contractOwner = ("tz1codeYURj5z49HKX9zmLHms2vJN2qDjrtt" : address);
  contractOracle = ("tz1codeYURj5z49HKX9zmLHms2vJN2qDjrtt" : address);
  contractNft = ("tz1codeYURj5z49HKX9zmLHms2vJN2qDjrtt" : address);
  deposits = (map [] : map(nat, map(nat, tez)))
]' > build/reward_proxy.init.tz
