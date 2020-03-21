#!/bin/bash

echo "Compiling Oracle contract..."
ligo compile-contract src/oracle.ligo main > build/oracle.tz

echo "Compiling Oracle contract's initial storage..."
ligo compile-storage src/oracle.ligo main '(big_map [] : big_map(nat, record [
  id : nat;
  author : address;
  rewards_h : bytes;
  rewards : nat;
  claimed : map (address, nat);
  questions : nat
]))' > build/oracle.init.tz
