type puzzle is
  record [
    id          : nat;          // e.g. Creation Time
    author      : address;      // Author address
    //public_h  : bytes;        // Encrypted bytes output of hashing contract (public)
    //rewards_h : bytes;        // Encrypted bytes output of hashing contract (rewards)
    rewards     : nat           // Max claimable rewards (default 0)
                                // Suggested max rewards capacity: testnet (10), mainnet (100)
  ]


type puzzle_storage is map (nat, puzzle)

type return is list (operation) * puzzle_storage

function main (const parameter : unit; const puzzle_storage : puzzle_storage) : return is
  ((nil : list (operation)), puzzle_storage)

function create_puzzle (const puzzle_index : nat; const puzzle : puzzle; var puzzles : puzzle_storage) : puzzle_storage is
  block {
    // TODO: Check Author is approved
    // TODO: Check if item exists (is new) before changing it?
    
    // Update puzzle storage
    puzzles[puzzle_index] := puzzle
  } with puzzles

function claim_reward (const puzzle_index : nat; var puzzle_storage : puzzle_storage) : return is
  block {
    // Retrieve puzzle from storage or fail
    const puzzle_instance : puzzle =
      case puzzle_storage[puzzle_index] of
        Some (instance) -> instance
      | None -> (failwith ("Unknown puzzle index") : puzzle)
      end;

    // Puzzle must have claimable rewards remaining
    if puzzle_instance.rewards < 1n then
      failwith ("No rewards are claimable");
    else skip;

    // Verify hash puzzle
    // TODO: this

    // Mint token and transfer
    // TODO: this

    // Decrease rewards by 1 after distribution
    puzzle_instance.rewards := abs (puzzle_instance.rewards - 1n);

    // Update puzzle storage
    puzzle_storage[puzzle_index] := puzzle_instance

  } with ((nil : list (operation)), puzzle_storage)