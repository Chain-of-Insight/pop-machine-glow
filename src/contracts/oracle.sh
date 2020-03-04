ligo dry-run oracle.ligo --syntax pascaligo main unit 'map [
    1n -> record [
            id = 1583093350498n;
            author = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
            rewards = 3n
          ];
    2n -> record [
            id = 1583258505553n;
            author = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
            rewards = 10n
          ];
]'

ligo compile-contract oracle.ligo --syntax pascaligo main