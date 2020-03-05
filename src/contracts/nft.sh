ligo dry-run oracle.ligo --syntax pascaligo --sender=tz1WtSgQKTpHUNfXwGFKQtXfphZWkLE2FPCs main 'Mint(
  record [
    nftToMintId = 2n;
    nftToMint = record [
      owner = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
      data = 0x9690bbd545bd192eb56edd1d8849f7c78ed3b238ee79b749418d20ed1aa6f5b4
    ];
  ]
)' \
'record [
  owner = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
  data= 0x7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e
]'

ligo compile-contract nft.ligo --syntax pascaligo main