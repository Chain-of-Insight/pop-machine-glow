type author_stake is map (address, tez)

type author is
  record [ 
    stake    : author_stake;
    approved : bool
  ]

type author_storage is map (address, author)

(* Minimum stake required to create puzzles - Can be withdrawn by the Author at anytime 
  If withdrawn Author loses access to create new or modify existings Puzzles *)
type staking_price is tez
const staking_price : staking_price = 1000000mutez // e.g. 1 XTZ

type return is list (operation) * author_storage

(* Add unpapproved unstaked Author *)
function add (const index : nat; const author_address : address; var author_storage : author_storage) : author_storage is
  block {
    (* Verify sender is approved to add another author to the registry *)
    const sender_address : address = Tezos.sender;
    const author_instance : author =
      case author_storage[sender_address] of
        Some (instance) -> instance
      | None -> (failwith ("Permissions failed") : author)
      end;

    const is_approved : bool = author_instance.approved;

    if is_approved =/= True then
      failwith ("Permissions failed")
    else skip;

    (* Add unstaked unapproved Author *)
    const zero_stake : author_stake = map[(author_address : address) -> (0mutez)];
    
    const author_entry : author = 
      record [
        stake = zero_stake;
        approved = False
      ];
    author_storage[(author_address)] := (author_entry)
  } with (author_storage)

(* Stake and approve in the registry *)
function approve (const index : nat; var author_storage : author_storage) : author_storage is
  block {
    (* Verify sender has been added *)
    const sender_address: address = Tezos.sender;
    const author_instance : author =
      case author_storage[sender_address] of
        Some (instance) -> instance
      | None -> (failwith ("Permissions failed") : author)
      end;

    (* Verify not already approved *)
    const is_approved : bool = author_instance.approved;

    if is_approved =/= True then
      failwith ("Permissions failed")
    else skip;

    (* Verify valid stake *)
    const stake_value : tez = Tezos.amount;
    if stake_value < staking_price then
      failwith ("Staking amount rejected");
    else skip;

    (* Author stake *)
    const a_stake : author_stake = map[(sender_address) -> (stake_value)];
    
    const author_entry : author = 
      record [
        stake = a_stake;
        approved = True
      ];
    
    (* Save approved Author *)
    author_storage[(sender_address)] := (author_entry)

    (* TODO: Send over payments (tips) to COI address *)
  } with (author_storage)

(* Withdraw Author stake - Author can rejoin at any time by staking 
  only the initial entry to the registry requires approval from a trusted source *)
function leave_registry (const index : nat; var author_storage : author_storage) : return is
  block {
    (* Verify Author *)
    const sender_address: address = Tezos.sender;
    const author_instance : author =
      case author_storage[sender_address] of
        Some (instance) -> instance
      | None -> (failwith ("Author not in the registry") : author)
      end;

    (* Verify Author stake *)
    const staking_instance : tez =
      case author_instance.stake[sender_address] of
        Some (instance) -> instance
      | None -> (failwith ("Inadequate stake") : tez)
      end;

    // Verify approval
    const is_approved : bool = author_instance.approved;

    if is_approved =/= True then
      failwith ("Author already removed from the registry")
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

function main (const p : unit; const author_storage : author_storage) : return is
  ((nil : list (operation)), author_storage)