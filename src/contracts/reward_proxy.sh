ligo compile-contract reward_proxy.ligo main > build/reward_proxy.tz

ligo compile-storage reward_proxy.ligo main 'record [
  trustedContracts = (set [] : set(address));
  contractOwner = ("tz1UAtabHR2whB3PWAuEQcKiHzkbHsPzcmHH" : address);
  contractOracle = ("tz1UAtabHR2whB3PWAuEQcKiHzkbHsPzcmHH" : address);
  deposits = (map [] : map(nat, map(nat, tez)));
  callbacks = (map [] : map(nat, map(nat, set(address))))
]' > build/reward_proxy.init.tz