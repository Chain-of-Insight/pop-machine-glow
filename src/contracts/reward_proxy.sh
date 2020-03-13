ligo compile-storage reward_proxy.ligo main 'record [
  trustedContracts = (set [] : set(address));
  contractOwner = ("tz1codeYURj5z49HKX9zmLHms2vJN2qDjrtt" : address);
  contractOracle = ("tz1codeYURj5z49HKX9zmLHms2vJN2qDjrtt" : address);
  deposits = (map [] : map(nat, map(nat, tez)));
  callbacks = (map [] : map(nat, map(nat, set(address))))
]'
