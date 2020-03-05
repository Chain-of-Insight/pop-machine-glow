ligo dry-run nft.ligo --syntax pascaligo --source=tz1WtSgQKTpHUNfXwGFKQtXfphZWkLE2FPCs main \
'Mint(
  record [
    nftToMintId = 2n;
    nftToMint = record [
      owner = ("tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz" : address);
      data = 0x9690bbd545bd192eb56edd1d8849f7c78ed3b238ee79b749418d20ed1aa6f5b4
    ];
  ]
)' \
'record [
  nfts = map [
    1n -> record [
      owner = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
      data = 0x9690bbd545bd192eb56edd1d8849f7c78ed3b238ee79b749418d20ed1aa6f5b4
    ]
  ];
  contractOwner = "tz1WtSgQKTpHUNfXwGFKQtXfphZWkLE2FPCs"
]'

ligo compile-contract nft.ligo --syntax pascaligo main