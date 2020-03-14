# Create new record
ligo dry-run oracle.ligo --syntax pascaligo main 'Create(
record [ 
  id = 2n; 
  rewards = 10n; 
  rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e;
  questions = 3n
])' \
'map [
  0n -> record [
    id = 0n;
    author = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
    rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e;
    rewards = 3n;
    claimed = 3n;
    questions = 1n
  ];
  1n -> record [
    id = 1n;
    author = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
    rewards = 10n;
    rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e;
    claimed = 0n;
    questions = 10n
  ];
]'

# Try to create existing record
ligo dry-run oracle.ligo --syntax pascaligo main 'Create(
record [ 
  id = 1n; 
  rewards = 10n; 
  rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e;
  questions = 3n
])' \
'map [
  0n -> record [
    id = 0n;
    author = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
    rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e;
    rewards = 3n;
    claimed = 3n;
    questions = 1n
  ];
  1n -> record [
    id = 1n;
    author = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
    rewards = 10n;
    rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e;
    claimed = 0n;
    questions = 10n
  ];
]'

# Update record
ligo dry-run oracle.ligo --syntax pascaligo --sender=tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz main 'Update(
record [ 
  id = 1n; 
  rewards = 10n; 
  rewards_h = 0x9690bbd545bd192eb56edd1d8849f7c78ed3b238ee79b749418d20ed1aa6f5b4;
  questions = 10n
])' \
'map [
  0n -> record [
    id = 0n;
    author = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
    rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e;
    rewards = 3n;
    claimed = 3n;
    questions = 1n
  ];
  1n -> record [
    id = 1n;
    author = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
    rewards = 10n;
    rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e;
    claimed = 0n;
    questions = 10n
  ];
]'

# Update record; wrong sender
ligo dry-run oracle.ligo --syntax pascaligo --sender=tz1bMZ8HJgQqSwHdQnAaJmy7kLWmkgDxP1hX main 'Update(
record [ 
  id = 1n; 
  rewards = 10n; 
  rewards_h = 0x9690bbd545bd192eb56edd1d8849f7c78ed3b238ee79b749418d20ed1aa6f5b4;
  questions = 10n
])' \
'map [
  0n -> record [
    id = 0n;
    author = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
    rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e;
    rewards = 3n;
    claimed = 3n;
    questions = 1n
  ];
  1n -> record [
    id = 1n;
    author = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
    rewards = 10n;
    rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e;
    claimed = 0n;
    questions = 10n
  ];
]'

# Update record; already claimed
ligo dry-run oracle.ligo --syntax pascaligo --sender=tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz main 'Update(
record [ 
  id = 0n; 
  rewards = 10n; 
  rewards_h = 0x9690bbd545bd192eb56edd1d8849f7c78ed3b238ee79b749418d20ed1aa6f5b4;
  questions = 10n
])' \
'map [
  0n -> record [
    id = 0n;
    author = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
    rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e;
    rewards = 3n;
    claimed = 3n;
    questions = 1n
  ];
  1n -> record [
    id = 1n;
    author = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
    rewards = 10n;
    rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e;
    claimed = 0n;
    questions = 10n
  ];
]'

# Solve puzzle - No rewards are claimable
ligo dry-run oracle.ligo --syntax pascaligo main 'Solve(
record [ 
  id = 0n; 
  proof = 0x9690bbd545bd192eb56edd1d8849f7c78ed3b238ee79b749418d20ed1aa6f5b4 
])' \
'map [
  0n -> record [
    id = 0n;
    author = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
    rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e;
    rewards = 3n;
    claimed = 3n;
    questions = 1n
  ];
  1n -> record [
    id = 1n;
    author = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
    rewards = 10n;
    rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e;
    claimed = 0n;
    questions = 10n
  ];
]'

# Solve puzzle - proof fails
ligo dry-run oracle.ligo --syntax pascaligo main 'Solve(
record [ 
  id = 0n; 
  proof = 0x9690bbd545bd192eb56edd1d8849f7c78ed3b238ee79b749418d20ed1aa6f5b4 
])' \
'map [
  0n -> record [
    id = 0n;
    author = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
    rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e;
    rewards = 3n;
    claimed = 0n;
    questions = 1n
  ];
  1n -> record [
    id = 1n;
    author = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
    rewards = 10n;
    rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e;
    claimed = 0n;
    questions = 10n
  ];
]'

# Proof passes
ligo dry-run oracle.ligo --syntax pascaligo main 'Solve(
record [ 
  id = 1n; 
  proof = 0x9690bbd545bd192eb56edd1d8849f7c78ed3b238ee79b749418d20ed1aa6f5b4 
])' \
'map [
  0n -> record [
    id = 0n;
    author = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
    rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e;
    rewards = 3n;
    claimed = 3n;
    questions = 1n
  ];
  1n -> record [
    id = 1n;
    author = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
    rewards = 10n;
    rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e;
    claimed = 1n;
    questions = 10n
  ];
]'

ligo compile-contract oracle.ligo --syntax pascaligo main > build/oracle.tz

ligo compile-storage oracle.ligo main 'big_map [
    1583093350498n -> record [
      id = 1583093350498n;
      author = ("tz1UAtabHR2whB3PWAuEQcKiHzkbHsPzcmHH" : address );
      rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e;
      rewards = 5n;
      claimed = 0n
    ];
]' > build/oracle.init.tz