ligo dry-run authors.ligo --syntax pascaligo main unit 'map [
    1n -> record [
            author = map("tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz", 0tez);
            approved = true
          ]
]'

ligo compile-contract authors.ligo --syntax pascaligo main