type author_stake is map (address, tez)

type author is
  record [ 
    stake    : author_stake; // e.g. (Author, Stake)
    approved : bool
  ]

type author_storage is map (address, author)

type staking_price is tez

type return is list (operation) * author_storage

function main (const p : unit; const author_storage : author_storage) : return is
  ((nil : list (operation)), author_storage)

function getSender(const mock: bool): address is
  block {
    var senderAddress: address := Tezos.sender;  
    if mock 
      then senderAddress := ("tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz" : address);
      else skip
  } with(senderAddress)

function getStakeValue(const mock: bool): tez is
  block {
    var senderAmount: tez := Tezos.amount;  
    if mock 
      then senderAmount := 1mutez;
      else skip
  } with(senderAmount)

function add (const index : nat; const author_address : address; var author_storage : author_storage) : author_storage is
  block {
    // Verify sender is approved to add another author to the registry
    const senderAddress : address = getSender(False);
    const author_instance : author =
      case author_storage[senderAddress] of
        Some (instance) -> instance
      | None -> (failwith ("Permissions failed") : author)
      end;

    // if author_instance.approved =/= False then
    //     failwith ("Permissions failed")

    // Adds unstaked / unapproved author entry
    const zero_stake : author_stake = map[(author_address : address) -> (0mutez)];
    
    const author_entry : author = 
      record [
        stake = zero_stake;
        approved = False
      ];
    author_storage[(author_address)] := (author_entry)
  } with author_storage

  function approve (const index : nat; var author_storage : author_storage) : author_storage is
  block {
    // Verify sender has been added
    const senderAddress: address = getSender(False);
    const author_instance : author =
      case author_storage[senderAddress] of
        Some (instance) -> instance
      | None -> (failwith ("Permissions failed") : author)
      end;

    // Verify stake
    const stakeValue : tez = getStakeValue(False);
    // if stakeValue <= staking_price then
    //   failwith ("Staking amount rejected");

    // Add author stake
    const a_stake : author_stake = map[(senderAddress) -> (stakeValue)];
    
    const author_entry : author = 
      record [
        stake = a_stake;
        approved = True
      ];
    
    author_storage[(senderAddress)] := (author_entry)
  } with author_storage

  function leave_registry (const index : nat; var author_storage : author_storage) : author_storage is
  block {
    // Verify sender is approved
    const senderAddress: address = getSender(False);
    const author_instance : author =
      case author_storage[senderAddress] of
        Some (instance) -> instance
      | None -> (failwith ("Permissions failed") : author)
      end;

    // Verify stake / approval
    // if author_storage[senderAddress].approved =/= true
    //     failwith ("Permissions failed")
    // if author_storage[senderAddress].stake < staking_price
    //     failwith ("Permissions failed")

    // Withdraw stake
    // TODO: This

    // Reset stake storage
    const zero_stake : author_stake = map[(senderAddress : address) -> (0mutez)];
    
    // Reset approval status
    const author_entry : author = 
      record [
        stake = zero_stake;
        approved = False
      ];
    author_storage[(senderAddress)] := (author_entry)
  } with author_storage