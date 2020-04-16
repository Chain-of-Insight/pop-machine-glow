#!/bin/bash

export network="$1"
export contract="$2"
export owner="$3"
export approved="$4"

if [ "$network" == "" ] || [ "$contract" == "" ] || [ "$owner" == "" ] || [ "$approved" == "" ]; then
  echo "Usage: $0 <network> <proxy-contract> <contract-owner> <approved-contract>"
  exit 0
fi

if [[ ! " sandbox babylon carthage " =~ " $network " ]]; then
  echo "Must specify network (sandbox|babylon|carthage)"
  exit 1
fi

export tezos_client_connection=""
if [ "$network" == "babylon" ]; then
  tezos_client_connection="-A babylonnet.smartpy.io -S -P 443"
fi

if [ "$network" == "carthage" ]; then
  tezos_client_connection="-A carthagenet.smartpy.io -S -P 443"
fi

params=$(ligo compile-parameter src/reward_proxy.ligo main "ApproveContract((\"$approved\": address))")
cmd="tezos-client $tezos_client_connection transfer 0 from $owner to $contract --arg '$params' --dry-run"

echo "Run the dry-run command to get the burn-cap; then re-run without --dry-run:"
echo ""
echo "  $cmd"
echo ""
