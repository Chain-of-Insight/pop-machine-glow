# Author 1n -> Approved
# Author 2n -> Approved w/ tip
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
    "tz1UAtabHR2whB3PWAuEQcKiHzkbHsPzcmHH" -> record [
        author = map ["tz1UAtabHR2whB3PWAuEQcKiHzkbHsPzcmHH" -> 0mutez];
        approved = False
    ];
]'

ligo compile-contract authors.ligo --syntax pascaligo main