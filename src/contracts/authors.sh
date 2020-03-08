# Test: List Authors
# Author 1n -> Approved
# Author 2n -> Approved w/ tip to COI
# Author 3n -> Unapproved
ligo dry-run authors.ligo --syntax pascaligo main 'Show(unit)' 'map [
    "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz" -> record [
        author = map ["tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz" -> 1000000mutez];
        approved = True
    ];
    "tz1UAtabHR2whB3PWAuEQcKiHzkbHsPzcmHH" -> record [
        author = map ["tz1UAtabHR2whB3PWAuEQcKiHzkbHsPzcmHH" -> 1200000mutez];
        approved = True
    ];
    "tz1VwmmesDxud2BJEyDKUTV5T5VEP8tGBKGD" -> record [
        author = map ["tz1VwmmesDxud2BJEyDKUTV5T5VEP8tGBKGD" -> 0mutez];
        approved = False
    ];
]'





# Test: Add add unapproved / unstaked Author
ligo dry-run authors.ligo --syntax pascaligo --sender=tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz main 'Create(("tz1MXjdb684ByEP5qUn5J7EMub7Sr8eBziDe" : address))' 'map [
    "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz" -> record [
        author = map ["tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz" -> 1000000mutez];
        approved = True
    ];
    "tz1UAtabHR2whB3PWAuEQcKiHzkbHsPzcmHH" -> record [
        author = map ["tz1UAtabHR2whB3PWAuEQcKiHzkbHsPzcmHH" -> 1200000mutez];
        approved = True
    ];
    "tz1VwmmesDxud2BJEyDKUTV5T5VEP8tGBKGD" -> record [
        author = map ["tz1VwmmesDxud2BJEyDKUTV5T5VEP8tGBKGD" -> 0mutez];
        approved = False
    ];
]'
####
# Returns...
#
# ( 
#     list[] , 
#     map[
#         @"tz1MXjdb684ByEP5qUn5J7EMub7Sr8eBziDe" -> record[approved -> false , stake -> map[@"tz1MXjdb684ByEP5qUn5J7EMub7Sr8eBziDe" -> 0mutez]] , 
#         @"tz1UAtabHR2whB3PWAuEQcKiHzkbHsPzcmHH" -> record[approved -> true , stake -> map[@"tz1UAtabHR2whB3PWAuEQcKiHzkbHsPzcmHH" -> 1200000mutez]] , 
#         @"tz1VwmmesDxud2BJEyDKUTV5T5VEP8tGBKGD" -> record[approved -> false , stake -> map[@"tz1VwmmesDxud2BJEyDKUTV5T5VEP8tGBKGD" -> 0mutez]] , 
#         @"tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz" -> record[approved -> true , stake -> map[@"tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz" -> 1000000mutez]]
#     ] 
# )



# Test: Approve Author
# Author 1n (Should fail)
ligo dry-run authors.ligo --syntax pascaligo main --sender=tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz 'Stake(unit)' 'map [
    "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz" -> record [
        author = map ["tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz" -> 1000000mutez];
        approved = True
    ];
    "tz1UAtabHR2whB3PWAuEQcKiHzkbHsPzcmHH" -> record [
        author = map ["tz1UAtabHR2whB3PWAuEQcKiHzkbHsPzcmHH" -> 1200000mutez];
        approved = True
    ];
    "tz1VwmmesDxud2BJEyDKUTV5T5VEP8tGBKGD" -> record [
        author = map ["tz1VwmmesDxud2BJEyDKUTV5T5VEP8tGBKGD" -> 0mutez];
        approved = False
    ];
]'
# Returns -> failwith("Permissions failed")
# Author 3n - Inadaquate stake amount (Should fail):
ligo dry-run authors.ligo --syntax pascaligo main --sender=tz1VwmmesDxud2BJEyDKUTV5T5VEP8tGBKGD --amount=0.5 'Stake(unit)' 'map [
    "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz" -> record [
        author = map ["tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz" -> 1000000mutez];
        approved = True
    ];
    "tz1UAtabHR2whB3PWAuEQcKiHzkbHsPzcmHH" -> record [
        author = map ["tz1UAtabHR2whB3PWAuEQcKiHzkbHsPzcmHH" -> 1200000mutez];
        approved = True
    ];
    "tz1VwmmesDxud2BJEyDKUTV5T5VEP8tGBKGD" -> record [
        author = map ["tz1VwmmesDxud2BJEyDKUTV5T5VEP8tGBKGD" -> 0mutez];
        approved = False
    ];
]'
# Returns -> failwith("Staking amount rejected")
# Author 3n - Passing:
ligo dry-run authors.ligo --syntax pascaligo main --sender=tz1VwmmesDxud2BJEyDKUTV5T5VEP8tGBKGD --amount=1 'Stake(unit)' 'map [
    "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz" -> record [
        author = map ["tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz" -> 1000000mutez];
        approved = True
    ];
    "tz1UAtabHR2whB3PWAuEQcKiHzkbHsPzcmHH" -> record [
        author = map ["tz1UAtabHR2whB3PWAuEQcKiHzkbHsPzcmHH" -> 1200000mutez];
        approved = True
    ];
    "tz1VwmmesDxud2BJEyDKUTV5T5VEP8tGBKGD" -> record [
        author = map ["tz1VwmmesDxud2BJEyDKUTV5T5VEP8tGBKGD" -> 0mutez];
        approved = False
    ];
]'



# Test: Withdraw stake
# Author 1n:
ligo dry-run authors.ligo --syntax pascaligo main --sender=tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz 'Withdraw(unit)' 'map [
    "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz" -> record [
        author = map ["tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz" -> 1000000mutez];
        approved = True
    ];
    "tz1UAtabHR2whB3PWAuEQcKiHzkbHsPzcmHH" -> record [
        author = map ["tz1UAtabHR2whB3PWAuEQcKiHzkbHsPzcmHH" -> 1200000mutez];
        approved = True
    ];
    "tz1VwmmesDxud2BJEyDKUTV5T5VEP8tGBKGD" -> record [
        author = map ["tz1VwmmesDxud2BJEyDKUTV5T5VEP8tGBKGD" -> 0mutez];
        approved = False
    ];
]'
# Author 2n:
ligo dry-run authors.ligo --syntax pascaligo main --sender=tz1UAtabHR2whB3PWAuEQcKiHzkbHsPzcmHH 'Withdraw(unit)' 'map [
    "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz" -> record [
        author = map ["tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz" -> 1000000mutez];
        approved = True
    ];
    "tz1UAtabHR2whB3PWAuEQcKiHzkbHsPzcmHH" -> record [
        author = map ["tz1UAtabHR2whB3PWAuEQcKiHzkbHsPzcmHH" -> 1200000mutez];
        approved = True
    ];
    "tz1VwmmesDxud2BJEyDKUTV5T5VEP8tGBKGD" -> record [
        author = map ["tz1VwmmesDxud2BJEyDKUTV5T5VEP8tGBKGD" -> 0mutez];
        approved = False
    ];
]'
# Author 3n:
ligo dry-run authors.ligo --syntax pascaligo main --sender=tz1VwmmesDxud2BJEyDKUTV5T5VEP8tGBKGD 'Withdraw(unit)' 'map [
    "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz" -> record [
        author = map ["tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz" -> 1000000mutez];
        approved = True
    ];
    "tz1UAtabHR2whB3PWAuEQcKiHzkbHsPzcmHH" -> record [
        author = map ["tz1UAtabHR2whB3PWAuEQcKiHzkbHsPzcmHH" -> 1200000mutez];
        approved = True
    ];
    "tz1VwmmesDxud2BJEyDKUTV5T5VEP8tGBKGD" -> record [
        author = map ["tz1VwmmesDxud2BJEyDKUTV5T5VEP8tGBKGD" -> 0mutez];
        approved = False
    ];
]'
####
# Returns...
#
# Author -> 1n:
# ( 
#     list[Operation(...bytes)] , 
#     map[
#         @"tz1UAtabHR2whB3PWAuEQcKiHzkbHsPzcmHH" -> record[approved -> true , stake -> map[@"tz1UAtabHR2whB3PWAuEQcKiHzkbHsPzcmHH" -> 1200000mutez]] , 
#         @"tz1VwmmesDxud2BJEyDKUTV5T5VEP8tGBKGD" -> record[approved -> false , stake -> map[@"tz1VwmmesDxud2BJEyDKUTV5T5VEP8tGBKGD" -> 0mutez]] , 
#         @"tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz" -> record[approved -> false , stake -> map[@"tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz" -> 0mutez]]
# ] )
# Author -> 2n:
# ( list[Operation(...bytes)] , 
# map[
#     @"tz1UAtabHR2whB3PWAuEQcKiHzkbHsPzcmHH" -> record[approved -> false , stake -> map[@"tz1UAtabHR2whB3PWAuEQcKiHzkbHsPzcmHH" -> 0mutez]], 
#     @"tz1VwmmesDxud2BJEyDKUTV5T5VEP8tGBKGD" -> record[approved -> false , stake -> map[@"tz1VwmmesDxud2BJEyDKUTV5T5VEP8tGBKGD" -> 0mutez]] , 
#     @"tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz" -> record[approved -> true , stake -> map[@"tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz" -> 1000000mutez]]
# ] )
# Author -> 3n (Should fail):
# failwith("Author already removed from the registry")

# Compile contract
ligo compile-contract authors.ligo --syntax pascaligo main