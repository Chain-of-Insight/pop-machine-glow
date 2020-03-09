#include "hasher.ligo"

type puzzle is
  record [
    id          : nat;          // e.g. Creation Time
    author      : address;      // Author address
    //public_h  : bytes;        // Encrypted bytes output of hashing contract (public)
    rewards_h   : bytes;        // Encrypted bytes output of hashing contract (rewards)
    rewards     : nat;          // Max claimable rewards (default 0)
                                // Suggested max rewards capacity: testnet (10), mainnet (100)
    claimed     : nat           // Number of rewards claimed
  ]

(* Input for create entry *)
type create_params is
  record [
    id          : nat;          // e.g. Creation Time
    rewards     : nat;          // Max claimable rewards
    rewards_h   : bytes         // Solution hashchain value at rewards + 1
  ]

(* Input for solve entry *)
type solve_params is
  record [
    id          : nat;
    proof       : bytes;        // Solution proof for current depth (rewards - claimed)
  ]

(* Valid entry points *)
type entry_action is
  | Create of create_params
  | Update of create_params
  | Solve of solve_params

type puzzle_storage is big_map (nat, puzzle)

(* define return for readability *)
type return is list (operation) * puzzle_storage

(* define noop for readability *)
const noOperations: list(operation) = nil;

function create_puzzle (const input : create_params; var puzzles : puzzle_storage) : return is
  block {
    (* XXX TODO:
      Verify Author exists in registry: see ./authors.ligo *)

    (* Make sure puzzle doesn't exist *)
    case puzzles[input.id] of
        Some (puzzle) -> failwith ("Puzzle already exists.")
      | None -> skip
      end;

    (* Create puzzle record *)
    const puzzle : puzzle =
      record [
        id        = input.id;
        author    = Tezos.sender;
        rewards_h = input.rewards_h;
        rewards   = input.rewards;
        claimed   = 0n
      ];

    (* Update puzzle storage *)
    puzzles[input.id] := puzzle;

  } with (noOperations, puzzles)

function update_puzzle (const input : create_params; var puzzles : puzzle_storage) : return is
  block {
    (* Retrieve puzzle from storage or fail *)
    const puzzle_instance : puzzle =
      case puzzles[input.id] of
        Some (instance) -> instance
      | None -> (failwith ("Unknown puzzle index") : puzzle)
      end;

    (* Only author can update *)
    if Tezos.sender =/= puzzle_instance.author then
      failwith("Cannot update puzzle");
    else skip;

    (* One caveat; rewards cannot be less than already claimed *)
    if input.rewards < puzzle_instance.claimed then
      failwith("Cannot update puzzle");
    else skip;

    (* Update puzzle *)
    puzzle_instance.rewards_h := input.rewards_h;
    puzzle_instance.rewards   := input.rewards;

    (* Update puzzle storage *)
    puzzles[puzzle_instance.id] := puzzle_instance;

  } with (noOperations, puzzles)

function claim_reward (const input : solve_params; var puzzles : puzzle_storage) : return is
  block {
    (* Retrieve puzzle from storage or fail *)
    const puzzle_instance : puzzle =
      case puzzles[input.id] of
        Some (instance) -> instance
      | None -> (failwith ("Unknown puzzle index") : puzzle)
      end;

    (* Author claiming own prize? *)
    if Tezos.sender = puzzle_instance.author then
      failwith("No rewards are claimable.");
    else skip;

    (* Current depth in hashchain to verify *)
    const atdepth : nat = abs(puzzle_instance.rewards - puzzle_instance.claimed);

    (* Puzzle must have claimable rewards remaining *)
    if atdepth < 1n then
      failwith ("No rewards are claimable.");
    else skip;

    (* Verify submitted proof *)
    if verify_proof(input.proof, puzzle_instance.rewards_h, puzzle_instance.rewards + 1n, atdepth) then
      skip;
    else failwith("Solution proof could not be verified.");

    (* Mint token and transfer
       TODO: this *)

    (* Increase claimed by 1 after distribution *)
    puzzle_instance.claimed := puzzle_instance.claimed + 1n;

    (* Update puzzle storage *)
    puzzles[puzzle_instance.id] := puzzle_instance;

  } with (noOperations, puzzles)

function main (const action : entry_action; var puzzles : puzzle_storage) : return is
  block {
    skip
  } with case action of
    | Create(param) -> create_puzzle(param, puzzles)
    | Update(param) -> update_puzzle(param, puzzles)
    | Solve(param)  -> claim_reward(param, puzzles)
  end;
