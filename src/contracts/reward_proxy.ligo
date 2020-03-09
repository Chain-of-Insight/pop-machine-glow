type trusted is address
type puzzle_id is nat
type claim is nat
type deposit is map (claim, tez)
type callback_set is map (claim, set (trusted))

type storage is
  record [
    trustedContracts  : set (trusted);
    contractOwner     : trusted;
    contractOracle    : trusted;
    deposits          : map (puzzle_id, deposit);
    callbacks         : map (puzzle_id, callback_set)
  ]

(* Deposit params *)
type deposit_params is
  record [
    puzzle_id         : nat;
    claim             : nat
  ]

(* Address params *)
type addr_params is
  record [
    puzzle_id         : nat;
    claim             : nat;
    addr              : address
  ]

(* define return for readability *)
type return is list (operation) * storage

(* define noop for readability *)
const noOperations : list (operation) = nil;

(* Valid entry points *)
type entry_action is
  | SetOracle of trusted
  | ApproveContract of trusted
  | RejectContract of trusted
  | AddDeposit of deposit_params
  | GrantReward of addr_params

(* Add a deposit for a claim *)
function add_deposit (const input : deposit_params; var s : storage) : return is
  block {
    var puzzle_deposits : deposit :=
      case s.deposits[input.puzzle_id] of
        Some (d) -> d
      | None -> (map [] : deposit)
      end;

    (* Update deposit amount *)
    var claims : tez :=
      case puzzle_deposits[input.claim] of
        Some (d) -> d + Tezos.amount
      | None -> (Tezos.amount : tez)
      end;

    puzzle_deposits[input.claim] := claims;
    s.deposits[input.puzzle_id] := puzzle_deposits;
  } with (noOperations, s)

(* Grant reward to puzzle solver *)
function grant_reward (const input : addr_params; var s : storage) : return is
  block {
    if Tezos.sender =/= s.contractOracle then
      failwith("NOPERM")
    else skip;

    (* initialize operations *)
    var operations : list (operation) := nil;

    (* Send any XTZ rewards *)
    const puzzle_deposits : deposit =
      case s.deposits[input.puzzle_id] of
        Some (d) -> d
      | None -> (map [] : deposit)
      end;

    const claims : tez =
      case puzzle_deposits[input.claim] of
        Some (d) -> d
      | None -> 0tz
      end;

    if claims > 0tz then {
      (* Create payout transaction *)
      const receiver : contract (unit) = get_contract (input.addr);
      const payoutOperation : operation = transaction (unit, claims, receiver);
      operations := payoutOperation # operations;

      (* Adjust ledger *)
      puzzle_deposits[input.claim] := 0tz;
      s.deposits[input.puzzle_id] := puzzle_deposits;
    }
    else skip;

    (* Send NFTs *)
    (* @TODO *)


    (* Send contract callbacks (mint nfts, etc) *)
    (* @TODO *)

  } with (operations, s)

(* Set the oracle contract *)
function set_oracle(const addr : trusted; var s : storage) : return is
  block {
    (* Can only be called by contract creator *)
    if Tezos.source =/= s.contractOwner then
      failwith("NOPERM")
    else skip;

    (* Only a trusted contract can be an oracle *)
    const trusted : bool = s.trustedContracts contains addr;
    if trusted = False then
      failwith("NOPERM")
    else skip;

    (* Update storage *)
    s.contractOracle := addr;

  } with (noOperations, s)

(* Approve a trusted contract for reward disbursement *)
function approve_contract (const addr : trusted; var s : storage) : return is
  block {
    (* Can only be called by contract creator *)
    if Tezos.source =/= s.contractOwner then
      failwith("NOPERM")
    else skip;

    (* Add to set *)
    s.trustedContracts := Set.add (addr, s.trustedContracts)

  } with (noOperations, s)

(* Reject a trusted contract *)
function reject_contract (const addr : trusted; var s : storage) : return is
  block {
    (* Can only be called by contract creator *)
    if Tezos.source =/= s.contractOwner then
      failwith("NOPERM")
    else skip;

    (* Remove from set *)
    s.trustedContracts := Set.remove (addr, s.trustedContracts)

  } with (noOperations, s)

(* Main entrypoint *)
function main (const action : entry_action; var s : storage) : return is
  block {
    skip
  } with case action of
    | SetOracle(param) -> set_oracle(param, s)
    | ApproveContract(param) -> approve_contract(param, s)
    | RejectContract(param) -> reject_contract(param, s)
    | AddDeposit(param) -> add_deposit(param, s)
    | GrantReward(param) -> grant_reward(param, s)
  end;
