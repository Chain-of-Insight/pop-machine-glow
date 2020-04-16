#!/bin/bash

export network="$1"
export cname="$2"
export owner="$3"

if [ "$network" == "" ] || [ "$cname" == "" ] || [ "$owner" == "" ]; then
  echo "Usage: $0 <network> <contract-name> <contract-owner>"
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

# replace tz1codeYURj5z49HKX9zmLHms2vJN2qDjrtt with owner
sed -i'.bak' "s/tz1codeYURj5z49HKX9zmLHms2vJN2qDjrtt/$owner/g" build/reward_proxy.init.tz

cmd="tezos-client $tezos_client_connection originate contract $cname transferring 0 from $owner running build/reward_proxy.tz --init '$(< build/reward_proxy.init.tz)' --dry-run"

echo "Run the dry-run command to get the burn-cap to originate the contract; then re-run without --dry-run:"
echo ""
echo "  $cmd"
echo ""
