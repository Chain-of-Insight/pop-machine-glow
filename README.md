# PoP Machine Glow

### Introducing "proof of puzzle"...All your answers are ~~belong~~ _unknown_ to us

PoP Machine Glow (PoPMG) is a zero knowledge encryption oracle and DApp built on the Tezos network, it provides users and puzzle authors with verifiable proof of passing a test. More specifically, PoPMG verifies a user knows the correct answer to a question without revealing the question or its answers. Since PoPMG proofs are zero knowledge proofs, it's safe to publicly commit them to the Tezos blockchain so everyone can verify them should they choose to run the proof calculations on their own hardware.

To begin with, let's take a look at how _puzzles_ are defined in PoPMG. Storage of puzzle answers is handled by the Oracle smart contract. This contract stores the Puzzle ID and its associated answers in a Michelson record type:

Example (Ligo / Pascal)

```
type puzzle is
  record [
    id          : nat;          // e.g. Creation Time
    author      : address;      // Author address
    rewards_h   : bytes;        // Encrypted bytes output of hashing contract (rewards)
    rewards     : nat;          // Max claimable rewards (default 0)
                                // Suggested max rewards capacity: testnet (10), mainnet (100)
    claimed     : claim;        // Number of rewards claimed
    questions   : nat           // Quantity of questions concatenated in the answer hash (for DApp frontend only)
  ]
```

Example 2 - creating a new puzzle record:

```
const new_puzzle_record : Puzzle =
  record [
    id      	= 1n;
    questions	= 10n;           // 10 questions with secret answers embedded in puzzle
    rewards 	= 3n;            // NFTs locked to First, Second and Third place claimants
    rewards_h	= hasherOutput;
  ]
```

### For more about LIGO types see:
- https://gitlab.com/ligolang/ligo/blob/dev/src/passes/operators/operators.ml#L35

# Smart Contract Worklow
The below diagrams detail the _operation_ workflow of our smart contracts. Live examples of our contracts can viewed at the following addresses (Babylonnet):

- _Oracle & Hashing Contracts:_ [KT1NN94PSH8rysDBaw8jDSeJKedfLXRSx7KW](https://babylonnet.tzstats.com/KT1NN94PSH8rysDBaw8jDSeJKedfLXRSx7KW)
- _Rewards Proxy Contract:_ [KT1DfXasH5xziaqfmhyzi3cJyP8UmMjtShWQ](https://babylonnet.tzstats.com/KT1DfXasH5xziaqfmhyzi3cJyP8UmMjtShWQ)
- _NFT Contract:_ [KT1KV3Bp5pDH1bw4bEUpMVsWgQFmkDtg3zxi](https://babylonnet.tzstats.com/KT1KV3Bp5pDH1bw4bEUpMVsWgQFmkDtg3zxi)

## Figure 1.0 - Puzzle creation
<p align="center">
  <img width="auto" height="500px" src="https://github.com/Chain-of-Insight/pop-machine-glow/blob/master/Documentation/assets/img/diagram/Create_Puzzle_UML.png">
</p>

## Figure 2.0 - Submitting a solution & claiming a knowledge commitment
<p align="center">
  <img width="auto" height="900px" src="https://github.com/Chain-of-Insight/pop-machine-glow/blob/master/Documentation/assets/img/diagram/Solve_Puzzle_UML.png">
</p>

## Figure 3.0 - Operation workflow from a testnet `grantReward` transaction
See: https://better-call.dev/babylon/opHdSS7rbnksZnwNtb8QbYUHsLR6x3q8roMeGbpygFZRZTBVzZ7

# The Basic Gist

The _Oracle Contract_ is the main worker for handling the storage of puzzles and it manages the event queue for verifying solution results from a puzzle's players. For both authors and players, the encryption of plain text strings (the answers) must be handled client side to ensure a puzzle's solutions won't become publicly accessible once the puzzle entry is stored on the Tezos blockchain.

To encrypt the answers we'll store access to our primitives and cipher operations in a different smart contract that's inherited by the Oracle. We can call this inherited contract the _Hashing Contract_ and its procedures are easily replicable for client side verifications, for free and by anyone willing, using the `blake2b` npm package (https://www.npmjs.com/package/blake2b). This allows an author to generate encrypted bytes data to send to storage in the Oracle contract without needing to `POST` sensitive data over `HTTP` or store it in the Oracle contract using a transaction. It also allows a puzzle's players to verify they've got a correct set of answers for free, but if they want to reap some of the puzzle creator's sweet rewards they will need to pay a small gas payment to the Oracle to process the claim. 

# What About Rewards? 

Now that we have our Zero Knowledge protocol for answer verification, we get to do cool stuff with it. More importantly, we can reward players for finding correct answers. This requires inheriting a third contract, we can call this the _Rewards contract_ which is in turn connected to a fourth contract, the _NFT contract_, that contains code for minting NFTs according to the proposed Tezos NFT standards of the TZIP-12 proposal.

### Grant Reward Rules
- User must have a verified solution set (correct answers)
- User can only obtain an NFT or XTZ reward if there's a claimable quanitity remaining in storage. 
- User must use a zero knowledge proof to claim the reward

*Note: in order to be processed securely the Rewards contract is locked so that it can only be called by the Hashing Contract. If it's called by other source the transaction is automatically rejected.*

### See:
- Tezos NFT Standard https://nft.stove-labs.com/ (beta proposal)
- https://github.com/stove-labs/nft.stove-labs.com/blob/master/src/contracts/nft.ligo
- https://medium.com/@matej.sima/tutorial-implementing-a-mini-token-contract-on-tezos-with-on-chain-callbacks-tzip-12-b04cf7ee2059
- https://forum.tezosagora.org/t/request-for-comment-on-tzip-12-fa2-a-multi-asset-interface-for-tezos/1737

# Getting More In Depth

## Creation
1) Puzzle Author encrypts the puzzle answers locally using the `blake2b` algorithm
2) The rewards hash is generated by encrypting the answers multiple times:
  - The amount of encryption rounds used in puzzle creation is equal to the puzzle's total quantity of rewards + 1
  - This is a publicly verifiable hash that players use to verify their answers locally
3) Author submits create puzzle transaction with their secret answers encrypted. Author pays their own storage.

## Verification
1) Puzzle solvers submit their answers to the PoPMG DApp which firsts tests the solution locally using `blake2b`. If the solver's answers pass verification they can make a transaction to the Oracle contract to claim a reward (if rewards remain).
  - Note: rewards are computationally expensive proportionate to claim order
2) To obtain an NFT or XTZ reward claimants verify their answers with the help of the _Hashing Contract_ _Prover_ to solve a hash puzzle in a specific order and verify or fail the claimant's proof
	- Since the rewards hash is encrypted with rounds equal to `Rewards Quantity + 1`, the solver calls the `Prover` to generate the hashes of previous rounds
	- Lower round rewards are asymptotically more computationally expensive for the _Prover_ as the amount of computational work is proportional to the number of previous rounds excepting the initial round which has an expense equal to the unencrypted payload. If the first claim hash is Rewards hash - 1 round, than claiming rewards is slightly more expensive for subsequent solvers. If the reverse claim order is used, the first place prize becomes the most expensive transaction.


**For an academic explanation of greater than and less than zero knowledge proofs using hash chains see:**
- https://cs.nyu.edu/~mwalfish/papers/vex-sigcomm13.pdf
- https://www.stratumn.com/thinking/zero-knowledge-proof-of-age-using-hash-chains/
- https://asecuritysite.com/encryption/age

<br/><br/><br/>
<p align="center">
  <img width="250px" height="auto" src="https://raw.githubusercontent.com/Chain-of-Insight/pop-machine-glow/master/Documentation/assets/img/pop_machine.png">
</p>

