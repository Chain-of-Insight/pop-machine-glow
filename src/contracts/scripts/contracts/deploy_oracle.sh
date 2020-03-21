#!/bin/bash

export network="$1"
export cname="$2"
export owner="$3"
export proxy="$4"

if [ "$network" == "" ] || [ "$cname" == "" ] || [ "$owner" == "" ] || [ "$proxy" == "" ]; then
  echo "Usage: $0 <network> <contract-name> <contract-owner> <reward-proxy>"
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
  tezos_client_connection="-A carthage.smartpy.io -S -P 443"
fi

# replace KT1DfXasH5xziaqfmhyzi3cJyP8UmMjtShWQ with rewardProxyAddress
sed -i'.bak' "s/KT1DfXasH5xziaqfmhyzi3cJyP8UmMjtShWQ/$proxy/g" build/oracle.tz

cmd="tezos-client $tezos_client_connection originate contract $cname transferring 0 from $owner running build/oracle.tz --init '$(< build/oracle.init.tz)' --dry-run"

echo "Run the dry-run command to get the burn-cap to originate the contract; then re-run without --dry-run:"
echo ""
echo "  $cmd"
echo ""
