# PoP Machine Glow

### Introducing "proof of puzzle"...All your answers are ~~belong~~ _unknown_ to us

PoP Machine Glow (PoPMG) is a zero knowledge encryption oracle and DApp that provides users and puzzle authors with methods to obtain verifiable proof of test completion. PoPMG verifies your user knows an without storing a plain text copy of those answers. 

Storage of puzzle answers is handled by the Oracle smart contract; this contract stores the Puzzle ID and its associated answers in a Michelson record type:

Example (Ligo / Pascal)

```
type Puzzle is
  record [
    id      : string;   // e.g. Creation Time + User Address
    author  : address;  // Author address
    name    : string;   // Puzzle name (frontend display)
    domain  : string;   // Where to find the puzzle online
    answers : bytes;    // Encrypted bytes output of hasher contract
    rewards : int       // Max claimable rewards (default 0)
    					// Suggested max rewards capacity: testnet (10), mainnet (100)
  ]
```

Example 2 - creating a new puzzle record:

```
const new_puzzle_record : Puzzle =
  record [
    id      = "1583093350498-tz1UAtabHR2whB3PWAuEQcKiHzkbHsPzcmHH";
    author  = authorAddress;
    name    = "Satoshi\'s Lost Faucet";
    domain  = "https://satoshislostfaucet.com";
    answers = encryptedOutput;
    rewards = 3   // e.g. NFTs locked to First, Second and Third place claimants
  ]
```

### See:
- LIGO Types: https://gitlab.com/ligolang/ligo/blob/dev/src/passes/operators/operators.ml#L35
- Fi Types: https://learn.fi-code.com/overview/types

# The Basic Gist

The *Oracle Contract* is the main worker for handling storage from the puzzle's Author and manages the event queue for verifying results from a puzzle's players. Encryption of plain text strings (the answers) must be handled client side to ensure a puzzle's solutions are kept a secret and won't become publicly accessible once the puzzle entry is stored.

To encrypt the answers we'll store access to our primitives and cipher operations in a different smart contract, we call this the *Hashing Contract*, and its cipher operations are callable without any gas payment. This allows an author to generate encrypted bytes data to send to storage in the Oracle contract without needing to `POST` sensitive data over `HTTP` or store it in the contract. It also allows a puzzle's players to verify they've got a correct set of answers for free, but if they want to reap some of the creator's sweet rewards they will need to fund the contract with a small amount of XTZ so it can perform operations on their behalf.

The *Hashing Contract* uses its public key + the Oracle contract's public key for encryption operations. This resulting key is visible and calculable by everyone but that's what enables all parties involved (Author, Oracle and Player) to call the contract independently to check if they've got the correct answers for free.

# What About Rewards? 

Now that we have our Zero Knowledge protocol for answer verification, we get to do cool stuff with it. More importantly, we can reward players for finding correct answers. This requires inheriting a third contract, we can call this the *Rewards contract* which contains code for minting NFTs according to the proposed Tezos NFT standards. 

### Reward Rules
- User must have a verified solution set (correct answers)
- User can only obtain an NFT reward if there's a claimable quanitity remaining in storage. If a reward is claimed the `rewards: int` property of the `Puzzle` record gets decremented when the reward has been sent to the winner.

*Note: in order to be processed securely the Rewards contract needs to be locked so that it can only be called by the Hashing Contract. If it's called by other source the transaction needs to be automatically rejected.*

### See:
- Tezos NFT Standard https://nft.stove-labs.com/ (beta proposal)
- https://github.com/stove-labs/nft.stove-labs.com/blob/master/src/contracts/nft.ligo
- https://medium.com/@matej.sima/tutorial-implementing-a-mini-token-contract-on-tezos-with-on-chain-callbacks-tzip-12-b04cf7ee2059

# Getting More In Depth

ok, so let's say 10 people can claim a solution.  The hasher will hash the solution 11 times in an RPC call and that will be stored in the contract.  Now the first person to solve must prove they know the answer by providing the solution hashed 10 time.  The contract can verify by hashing it 1 more time. That solution slot is now used. The next solver must prove they know the solution by having it hashed 9 times. The contract can verify by hashing that twice. and so on until all solution spots are used up. Knowing the hash the previous solvers sent (which will public on the chain with the transactions) does not help anyone claim a solve since you can't reverse the hashes. You have to know the correct solution to know any given spot on the hashchain. And we work the chain backwards so that each solve does not help the next person.
RichGirlOnLSDToday at 10:53 AM

## Creation



1) Puzzle Author encrypts the puzzle answers by calling Hashing Contract client side (Client): `Sha-256((Oracle Public Key + Hasher Public Key) + Answers) => Encrypted Bytes`
	- This is the publicly verifiable hash that can be checked by players calling the Hashing contract for free
2) If more than 0 rewards, Author encrypts the puzzle answers again by calling the rewards hash generator of the Hashing Contract client side (Client)
	- The rewards hash is generated by encrypting the answers again multiple times. 
	- The amount of encryption rounds at creation is equal to the total max NFT rewards + 1 and during creating the Oracle / Hashing Contracts will verify this resultant hash is really NFT Quantity + 1
3) Author submits create puzzle transaction with Public (and Rewards hash if applicable). Author pays their own storage.

## Verification
1) Users submit their answers to the DApp which calls the Hashing contract to test. Can proceed to next step if solutions are correct and output hash matches the Oracle contract storage (Client)
2) If NFT rewards are available, and a User has the correct set of answers, they can send a transaction to rewards claim function to claim a reward (Hasing Contract / Oracle Contract)
	- Note: rewards are computationally expensive proportionate to claim order
3) To verify and obtain an NFT reward claimants user their answers with the help of the Hashing Contract Prover to solve a hash puzzle in a specific order (Client):
	- Since the rewards hash is encrypted with rounds equal to Quantity + 1, the first solver calls the Prover to generate the hashes of previous rounds
	- Lower round rewards are more computationally expensive for the prover. If the first claim hash is Rewards hash - 1 round, than claiming rewards is slightly more expensive for subsequent solvers. If the reverse claim order is used, the first place prize becomes the most expensive transaction.


**The above works because using a concept known as "proving age with hash chains". For a more academic explanation see:**
- https://www.stratumn.com/thinking/zero-knowledge-proof-of-age-using-hash-chains/
- https://asecuritysite.com/encryption/age

<br/><br/><br/>
<p align="center">
  <img width="250px" height="auto" src="https://raw.githubusercontent.com/Chain-of-Insight/pop-machine-glow/master/Documentation/assets/img/pop_machine.png">
</p>

