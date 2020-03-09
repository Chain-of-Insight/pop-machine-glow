# Mint NFT
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
####
# e.g.
# ( 
#     list[] , 
#     record[
#         contractOwner -> @"tz1WtSgQKTpHUNfXwGFKQtXfphZWkLE2FPCs" , 
#         nfts -> 
#         map[
#             +1 -> record[
#                 data -> 0x9690bbd545bd192eb56edd1d8849f7c78ed3b238ee79b749418d20ed1aa6f5b4 , 
#                 owner -> @"tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz"
#             ] , 
#             +2 -> record[
#                 data -> 0x9690bbd545bd192eb56edd1d8849f7c78ed3b238ee79b749418d20ed1aa6f5b4 , 
#                 owner -> @"tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz"
#             ]
#         ]
#     ] 
# )





# Transfer NFT
ligo dry-run nft.ligo --syntax pascaligo --source=tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz main \
'Transfer(
  record [
    nftToTransfer = 1n;
    destination = ("tz1VwmmesDxud2BJEyDKUTV5T5VEP8tGBKGD" : address)
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
####
# e.g.
# ( 
#     list[] , 
#     record[
#         contractOwner -> @"tz1WtSgQKTpHUNfXwGFKQtXfphZWkLE2FPCs" , 
#         nfts -> map[
#             +1 -> record[
#                 data -> 0x9690bbd545bd192eb56edd1d8849f7c78ed3b238ee79b749418d20ed1aa6f5b4 , 
#                 owner -> @"tz1VwmmesDxud2BJEyDKUTV5T5VEP8tGBKGD"
#             ]
#         ]
#     ] 
# )





# Burn NFT
# type actionBurn is record [
#   nftToBurnId : nftId;
# ]
ligo dry-run nft.ligo --syntax pascaligo --source=tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz main \
'Burn(
  record [
    nftToBurnId = 1n
  ]
)' \
'record [
  nfts = map [
    1n -> record [
      owner = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
      data = 0x9690bbd545bd192eb56edd1d8849f7c78ed3b238ee79b749418d20ed1aa6f5b4
    ];
    2n -> record [
      owner = "tz1VwmmesDxud2BJEyDKUTV5T5VEP8tGBKGD";
      data = 0x9690bbd545bd192eb56edd1d8849f7c78ed3b238ee79b749418d20ed1aa6f5b4
    ]
  ];
  contractOwner = "tz1WtSgQKTpHUNfXwGFKQtXfphZWkLE2FPCs"
]'
####
# e.g.
# ( 
#     list[] , 
#     record[
#         contractOwner -> @"tz1WtSgQKTpHUNfXwGFKQtXfphZWkLE2FPCs" , 
#         nfts -> map[
#             +2 -> record[
#                 data -> 0x9690bbd545bd192eb56edd1d8849f7c78ed3b238ee79b749418d20ed1aa6f5b4 , 
#                 owner -> @"tz1VwmmesDxud2BJEyDKUTV5T5VEP8tGBKGD"
#             ]
#         ]
#     ] 
# )





# List NFTs
# type actionExtension is record [
#   nftId : nftId;
# ]
# type nftId is nat;
ligo dry-run nft.ligo --syntax pascaligo --source=tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz main \
'List(
  record [
    nftId = 1n
  ]
)' \
'record [
  nfts = map [
    1n -> record [
      owner = "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz";
      data = 0x9690bbd545bd192eb56edd1d8849f7c78ed3b238ee79b749418d20ed1aa6f5b4
    ];
    2n -> record [
      owner = "tz1VwmmesDxud2BJEyDKUTV5T5VEP8tGBKGD";
      data = 0x9690bbd545bd192eb56edd1d8849f7c78ed3b238ee79b749418d20ed1aa6f5b4
    ]
  ];
  contractOwner = "tz1WtSgQKTpHUNfXwGFKQtXfphZWkLE2FPCs"
]'
####
# e.g.
# ( 
#     list[] , 
#     record[
#         contractOwner -> @"tz1WtSgQKTpHUNfXwGFKQtXfphZWkLE2FPCs" , 
#         nfts -> map[
#             +1 -> record[
#                 data -> 0x9690bbd545bd192eb56edd1d8849f7c78ed3b238ee79b749418d20ed1aa6f5b4 , 
#                 owner -> @"tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz"
#             ] , 
#             +2 -> record[
#                 data -> 0x9690bbd545bd192eb56edd1d8849f7c78ed3b238ee79b749418d20ed1aa6f5b4 , 
#                 owner -> @"tz1VwmmesDxud2BJEyDKUTV5T5VEP8tGBKGD"
#             ]
#         ]
#     ] 
# )





# Compile contract
ligo compile-contract nft.ligo --syntax pascaligo main