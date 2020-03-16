type nftId is nat;

type nft is record [
    owner : address;
    data : bytes
]

type nfts is map(nftId, nft);

type storageType is record [
  nfts : nfts;
  contractOwner : address;
];

type actionMint is record [
  nftToMintId : nftId;
  nftToMint : nft;
]

type actionTransfer is record [
  nftToTransfer : nftId;
  destination : address;
]

type actionBurn is record [
  nftToBurnId : nftId;
]

type actionExtension is record [
  nftId : nftId;
]

type action is
| Mint of actionMint
| Transfer of actionTransfer
| Burn of actionBurn
| List of actionExtension


// Mints a new NFT by creating a new entry in the contract.
// @param nftToMintId - ID of the NFT
// @param nftToMint - The NFT data structure
function mint(const action : actionMint ; const s : storageType) : (list(operation) * storageType) is
  block { 
    // check permission
    if Tezos.sender =/= s.contractOwner then
      failwith("You do not have permission to mint assets");
    else skip;
    // create NFT for new ID
    const nfts : nfts = s.nfts;
    nfts[action.nftToMintId] := action.nftToMint;
    s.nfts := nfts;
   } with ((nil: list(operation)) , s)

// Transfers the ownership of an NFT by replacing the owner address.
// @param nftToTransfer - ID of the NFT
// @param destination - Address of the recipient
function transfer(const action : actionTransfer ; const s : storageType) : (list(operation) * storageType) is
  block { 
    const nft : nft = get_force(action.nftToTransfer, s.nfts);
    const owner: address = nft.owner;
    // check for permission
    if source =/= owner then failwith("You do not have permission to transfer this asset.")
    else skip;
    // change owner's address
    const nfts : nfts = s.nfts;
    nft.owner := action.destination; 
    nfts[action.nftToTransfer] := nft;
    s.nfts := nfts;
   } with ((nil: list(operation)) , s)

// Burns an NFT by removing its entry from the contract.
// @param nftToBurnId - ID of the NFT
function burn(const action : actionBurn ; const s : storageType) : (list(operation) * storageType) is
  block { 
    const nft : nft = get_force(action.nftToBurnId, s.nfts);
    // check for permission
    if source =/= nft.owner then failwith("You do not have permission to burn this asset")
    else skip;
    // remove NFT
    const nfts : nfts = s.nfts;
    remove action.nftToBurnId from map nfts;
    s.nfts := nfts;
   } with ((nil: list(operation)) , s)

function extension(const action : actionExtension ; const s : storageType) : (list(operation) * storageType) is
  block { skip } with ((nil : list(operation)) , s)

// @remarks In v004 Athens, Michelson does not support multiple entrypoints. This is solved 
// in Ligo through variants and pattern matching.
// @param Any of the action types defined above.
function main(const action : action; const s : storageType) : (list(operation) * storageType) is 
 block {skip} with 
 case action of
 | Mint (mt) -> mint (mt, s)
 | Transfer (tx) -> transfer (tx, s)
 | Burn (bn) -> burn (bn, s)
 | List (en) -> extension (en, s)
end