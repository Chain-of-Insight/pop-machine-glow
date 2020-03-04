ligo dry-run authors.ligo --syntax pascaligo main unit 'map [
    "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz" -> record [
        author = map ["tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz" -> 0mutez];
        approved = true
    ];
]'

ligo compile-contract authors.ligo --syntax pascaligo main