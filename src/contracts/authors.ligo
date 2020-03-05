type author_stake is map (address, tez)

type author is
  record [ 
    stake    : author_stake; // e.g. (Author, Stake)
    approved : bool
  ]

type author_storage is map (address, author)

type staking_price is tez
const staking_price : staking_price = 1000000mutez // e.g. 1 XTZ

type return is list (operation) * author_storage

function main (const p : unit; const author_storage : author_storage) : return is
  ((nil : list (operation)), author_storage)

function getSender(const mock: bool): address is
  block {
    var sender_address: address := Tezos.sender;  
    if mock 
      then sender_address := ("tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz" : address);
      else skip
  } with (sender_address)

function getInitialStakeValue(const mock: bool): tez is
  block {
    var senderAmount: tez := Tezos.amount;  
    if mock 
      then senderAmount := staking_price;
      else skip
  } with (senderAmount)

function add (const index : nat; const author_address : address; var author_storage : author_storage) : author_storage is
  block {
    // Verify sender is approved to add another author to the registry
    const sender_address : address = getSender(False);
    const author_instance : author =
      case author_storage[sender_address] of
        Some (instance) -> instance
      | None -> (failwith ("Permissions failed") : author)
      end;

    // Verify approval
    const is_approved : bool = author_instance.approved;

    if is_approved =/= True then
      failwith ("Permissions failed")
    else skip;

    // Adds unstaked / unapproved author entry
    const zero_stake : author_stake = map[(author_address : address) -> (0mutez)];
    
    const author_entry : author = 
      record [
        stake = zero_stake;
        approved = False
      ];
    author_storage[(author_address)] := (author_entry)
  } with (author_storage)

  function approve (const index : nat; var author_storage : author_storage) : author_storage is
  block {
    // Verify sender has been added
    const sender_address: address = getSender(False);
    const author_instance : author =
      case author_storage[sender_address] of
        Some (instance) -> instance
      | None -> (failwith ("Permissions failed") : author)
      end;

    // Verify approval
    const is_approved : bool = author_instance.approved;

    if is_approved =/= True then
      failwith ("Permissions failed")
    else skip;

    // Verify stake
    const stake_value : tez = getInitialStakeValue(False);
    if stake_value < staking_price then
      failwith ("Staking amount rejected");
    else skip;

    // Add author stake
    const a_stake : author_stake = map[(sender_address) -> (stake_value)];
    
    const author_entry : author = 
      record [
        stake = a_stake;
        approved = True
      ];
    
    author_storage[(sender_address)] := (author_entry)
  } with (author_storage)

  function leave_registry (const index : nat; var author_storage : author_storage) : return is
  block {
    // Verify sender record
    const sender_address: address = getSender(False);
    const author_instance : author =
      case author_storage[sender_address] of
        Some (instance) -> instance
      | None -> (failwith ("Author not in the registry") : author)
      end;

    // Verify stake exists
    const staking_instance : tez =
      case author_instance.stake[sender_address] of
        Some (instance) -> instance
      | None -> (failwith ("Inadequate stake") : tez)
      end;

    // Verify approval
    const is_approved : bool = author_instance.approved;

    if is_approved =/= True then
      failwith ("Author not in the registry")
    else skip;

    // Withdraw stake
    const staking_price : tez = staking_instance;
    const destination : contract(unit) = get_contract(sender_address);
    const payout_operation : operation = transaction (unit, staking_price, destination);
    const op : list(operation) = list [payout_operation];

    // Reset stake storage
    const zero_stake : author_stake = map[(sender_address : address) -> (0mutez)];
    
    // Reset approval status
    const author_entry : author = 
      record [
        stake = zero_stake;
        approved = False
      ];
    author_storage[(sender_address)] := (author_entry)
  } with (op, author_storage)