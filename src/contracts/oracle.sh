# Create new record
ligo dry-run oracle.ligo --syntax pascaligo main 'Create(record [ id = 100n; rewards = 10n; rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e ])' 'map [
    1583093350498n -> record [
            id = 1583093350498n;
            author = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
            rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e;
            rewards = 3n;
            claimed = 3n
          ];
    1583258505553n -> record [
            id = 1583258505553n;
            author = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
            rewards = 10n;
            rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e;
            claimed = 0n
          ];
]'

# Try to create existing record
ligo dry-run oracle.ligo --syntax pascaligo main 'Create(record [ id = 1583093350498n; rewards = 10n; rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e ])' 'map [
    1583093350498n -> record [
            id = 1583093350498n;
            author = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
            rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e;
            rewards = 3n;
            claimed = 3n
          ];
    1583258505553n -> record [
            id = 1583258505553n;
            author = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
            rewards = 10n;
            rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e;
            claimed = 0n
          ];
]'

# Create new record
ligo dry-run oracle.ligo --syntax pascaligo main 'Create(record [ id = 100n; rewards = 10n; rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e ])' 'map [
    1583093350498n -> record [
            id = 1583093350498n;
            author = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
            rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e;
            rewards = 3n;
            claimed = 3n
          ];
    1583258505553n -> record [
            id = 1583258505553n;
            author = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
            rewards = 10n;
            rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e;
            claimed = 0n
          ];
]'

# Update record
ligo dry-run oracle.ligo --syntax pascaligo --sender=tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz main \
'Update(record [ id = 1583093350498n; rewards = 10n; rewards_h = 0x9690bbd545bd192eb56edd1d8849f7c78ed3b238ee79b749418d20ed1aa6f5b4 ])' \
'map [
    1583093350498n -> record [
            id = 1583093350498n;
            author = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
            rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e;
            rewards = 3n;
            claimed = 0n
          ];
    1583258505553n -> record [
            id = 1583258505553n;
            author = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
            rewards = 10n;
            rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e;
            claimed = 0n
          ];
]'

# Update record; wrong sender
ligo dry-run oracle.ligo --syntax pascaligo --sender=tz1WtSgQKTpHUNfXwGFKQtXfphZWkLE2FPCs main \
'Update(record [ id = 1583093350498n; rewards = 10n; rewards_h = 0x9690bbd545bd192eb56edd1d8849f7c78ed3b238ee79b749418d20ed1aa6f5b4 ])' \
'map [
    1583093350498n -> record [
            id = 1583093350498n;
            author = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
            rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e;
            rewards = 3n;
            claimed = 0n
          ];
    1583258505553n -> record [
            id = 1583258505553n;
            author = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
            rewards = 10n;
            rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e;
            claimed = 0n
          ];
]'

# Update record; already claimed
ligo dry-run oracle.ligo --syntax pascaligo --sender=tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz main \
'Update(record [ id = 1583093350498n; rewards = 10n; rewards_h = 0x9690bbd545bd192eb56edd1d8849f7c78ed3b238ee79b749418d20ed1aa6f5b4 ])' \
'map [
    1583093350498n -> record [
            id = 1583093350498n;
            author = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
            rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e;
            rewards = 3n;
            claimed = 1n
          ];
    1583258505553n -> record [
            id = 1583258505553n;
            author = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
            rewards = 10n;
            rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e;
            claimed = 0n
          ];
]'

# Proof fails
ligo dry-run oracle.ligo --syntax pascaligo main 'Solve(record [ id = 1583258505553n; proof = 0x9690bbd545bd192eb56edd1d8849f7c78ed3b238ee79b749418d20ed1aa6f5b4 ])' 'map [
    1583093350498n -> record [
            id = 1583093350498n;
            author = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
            rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e;
            rewards = 3n;
            claimed = 3n
          ];
    1583258505553n -> record [
            id = 1583258505553n;
            author = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
            rewards = 10n;
            rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e;
            claimed = 0n
          ];
]'

# Proof passes
ligo dry-run oracle.ligo --syntax pascaligo main 'Solve(record [ id = 1583258505553n; proof = 0x9690bbd545bd192eb56edd1d8849f7c78ed3b238ee79b749418d20ed1aa6f5b4 ])' 'map [
    1583093350498n -> record [
            id = 1583093350498n;
            author = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
            rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e;
            rewards = 3n;
            claimed = 3n
          ];
    1583258505553n -> record [
            id = 1583258505553n;
            author = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
            rewards = 10n;
            rewards_h = 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e;
            claimed = 1n
          ];
]'