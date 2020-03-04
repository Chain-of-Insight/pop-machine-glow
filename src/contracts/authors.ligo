type author is
  record [ 
    stake    : map(address, tez); // e.g. (Author, Stake)
    approved : bool
  ]

type author_storage is map (address, author)

type staking_price is nat

type return is list (operation) * author_storage

function main (const p : unit; const author_storage : author_storage) : return is
  ((nil : list (operation)), author_storage)

function add (const index : nat; const author_address : address; var authors : author_storage) : author_storage is
  block {
    // Verify sender is approved to add another author to the registry
    const author_instance : author =
      case author_storage[sender] of
        Some (instance) -> instance
      | None -> (failwith ("Permissions failed") : author)
      end;

    if author_storage[sender].approved =/= true
        failwith ("Permissions failed")

    // Adds empty author entry
    // Approval and stake amount handled by fn approve
    authors[author_address] := record [
        stake = map(address, 0n)
        approved = false
    ];
  } with authors

  function approve (const index : nat; const author_address : address; var authors : author_storage) : author_storage is
  block {
    // Verify sender has been added
    const author_instance : author =
      case author_storage[sender] of
        Some (instance) -> instance
      | None -> (failwith ("Permissions failed") : author)
      end;

    // Verify stake
    if Tezos.amount >= staking_price then
      failwith ("Staking amount rejected");

    // Add author stake
    authors[author_address] := record [
        stake = map(address, Tezos.amount)
        approved = true
    ];
  } with authors

  function leave_registry (const index : nat; var authors : author_storage) : author_storage is
  block {
    // Verify sender is approved
    const author_instance : author =
      case author_storage[sender] of
        Some (instance) -> instance
      | None -> (failwith ("Permissions failed") : author)
      end;

    // Verify stake / approval
    if author_storage[sender].approved =/= true
        failwith ("Permissions failed")
    if author_storage[sender].stake < staking_price
        failwith ("Permissions failed")

    // Withdraw stake
    // TODO: This

    // Add author
    authors[sender] := record [
        stake = map(sender, 0n)
        approved = false
    ];
  } with authors