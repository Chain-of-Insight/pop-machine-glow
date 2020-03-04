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

function approve (const index : nat; const author_address : address; var authors : author_storage) : author_storage is
  block {
    // Verify sender is approved to add another author
    const author_instance : author =
      case author_storage[Tezos.sender] of
        Some (instance) -> instance
      | None -> (failwith ("Permissions failed") : author)
      end;

    if author_storage[Tezos.sender].approved =/= true
        failwith ("Permissions failed")

    // Verify stake
    if Tezos.amount =/= staking_price then
      failwith ("Staking amount rejected");

    // Add author
    authors[author_address] := record [
        stake = map(address, Tezos.amount)
        approved = true
    ];
  } with authors

  function leave_registry (const index : nat; var authors : author_storage) : author_storage is
  block {
    // Verify sender is approved to add another author
    const author_instance : author =
      case author_storage[Tezos.sender] of
        Some (instance) -> instance
      | None -> (failwith ("Permissions failed") : author)
      end;

    // Withdraw stake
    // TODO: This

    // Add author
    authors[Tezos.sender] := record [
        stake = map(Tezos.sender, 0n)
        approved = false
    ];
  } with authors