type author_stake is map (address, tez)

type author is
  record [ 
    stake    : author_stake; // e.g. (Author, Stake)
    approved : bool
  ]

type author_storage is map (address, author)

type staking_price is nat

type return is list (operation) * author_storage

function main (const p : unit; const author_storage : author_storage) : return is
  ((nil : list (operation)), author_storage)

function getSender(const mock: bool): address is
  block {
    var senderAddress: address := sender;  
    if mock 
      then senderAddress := ("tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz" : address);
      else skip
  } with(senderAddress)

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

    // Adds unstaked author entry
    const zero_stake : author_stake = map[(author_address : address) -> (0mutez)];
    
    const author_entry : author = 
      record [
        stake = zero_stake;
        approved = False
      ];
    // m [("tz1gjaF81ZRRvdzjobyfVNsAeSC6PScjfQwN": address)] := (4,9)
    author_storage[(author_address)] := (author_entry)
  } with author_storage

  // function approve (const index : nat; var authors : author_storage) : author_storage is
  // block {
  //   // Verify sender has been added
  //   const senderAddress: address = getSender(False);
  //   const author_instance : author =
  //     case author_storage[senderAddress] of
  //       Some (instance) -> instance
  //     | None -> (failwith ("Permissions failed") : author)
  //     end;

  //   // Verify stake
  //   if Tezos.amount >= staking_price then
  //     failwith ("Staking amount rejected");

  //   // Add author stake
  //   authors[senderAddress] := record [
  //       stake = map[
  //         (senderAddress : address) -> (Tezos.amount)
  //       ];
  //       approved = true
  //   ];
  // } with authors

  // function leave_registry (const index : nat; var authors : author_storage) : author_storage is
  // block {
  //   // Verify sender is approved
  //   const author_instance : author =
  //     case author_storage[Tezos.sender] of
  //       Some (instance) -> instance
  //     | None -> (failwith ("Permissions failed") : author)
  //     end;

  //   // Verify stake / approval
  //   if author_storage[Tezos.sender].approved =/= true
  //       failwith ("Permissions failed")
  //   if author_storage[Tezos.sender].stake < staking_price
  //       failwith ("Permissions failed")

  //   // Withdraw stake
  //   // TODO: This

  //   // Add author
  //   authors[Tezos.sender] := record [
  //       stake = map(Tezos.sender, 0tez)
  //       approved = false
  //   ];
  // } with authors