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

The *Oracle contract* is the main worker for handling storage from the puzzle's Author and manages the event queue for verifying results from a puzzle's players. Encryption of plain text strings (the answers) must be handled client side to ensure a puzzle's solutions are kept a secret and won't become publicly accessible once the puzzle entry is stored.

To encrypt the answers we'll store access to our primitives and cipher operations in a different smart contract, we call this the *Hashing contract*, and its cipher operations are callable without any gas payment. This allows an author to generate encrypted bytes data to send to storage in the Oracle contract without needing to `POST` sensitive data over `HTTP` or store it in the contract. It also allows a puzzle's players to verify they've got a correct set of answers for free, but if they want to reap some of the creator's sweet rewards they will need to fund the contract with a small amount of XTZ so it can perform operations on their behalf.

The *Hashing contract* uses its public key + the Oracle contract's public key for encryption operations. This resulting key is visible and calculable by everyone but that's what enables all parties involved (Author, Oracle and Player) to call the contract independently to check if they've got the correct answers for free.

# What About Rewards? 

Now that we have our Zero Knowledge protocol for answer verification, we get to do cool stuff with it. More importantly, we can reward players for finding correct answers. This requires inheriting a third contract, we can call this the *Rewards contract* which contains code for minting NFTs according to the proposed Tezos NFT standards. 

### Reward Rules
- User must have a verified their set of solutions as 100% correct
  - We can accomplish this be giving correct solvers a self destructing mempool entry for their Tezos address. This gives them a time limit to claim an NFT prize after verifying their solutions.
- User can only obtain an NFT if there's a claimable quanitity remaining in storage. If a reward is claimed the `rewards: int` property of the `Puzzle` record is decremented at time of mint / distribution. 

*Note: in order to be processed securely the Rewards contract needs to be locked so that it can only be called by Hashing Contract, if it's called by other source the transaction needs to be rejected*

### See:
- Tezos NFT Standard https://nft.stove-labs.com/ (beta proposal)
- https://github.com/stove-labs/nft.stove-labs.com/blob/master/src/contracts/nft.ligo
- https://medium.com/@matej.sima/tutorial-implementing-a-mini-token-contract-on-tezos-with-on-chain-callbacks-tzip-12-b04cf7ee2059

# Getting More In Depth

## Creation
1) Puzzle Author encrypts the puzzle answers by calling Hashing Contract client side (Client): `Sha-256((Oracle Public Key + Hasher Public Key) + Answers) => Encrypted Bytes`
2) Author submits create puzzle transaction. Author pays their own storage.

## Verification
1) Users submit their answers to the DApp which calls the Hashing contract to test. Can proceed to next step if solutions are correct and output hash matches the Oracle contract storage (Client)
2) User pre-pays a defined amount to the Hashing contract (Hashing Contract)
  - Now the Hashing contract can make a transaction on their behalf 
  - This avoids requiring the user to submit their answers as a publicly viewable transaction
  - Account balances need to be namespaced by calling user (address)
3) User calls the Hashing contract verifier again with an extra argument: `processPayment = true` (Hashing Contract)
4) Hashing contract verifies the result again and checks if tokens can be minted and transferred to the user. (Hashing)
5) If correct result and reward tokens are available, uses the pre-paid gas payment to mint the user a token and transfer it to their wallet and the amount of tokens available in the Oracle contract is decremented (Hashing Contract / NFT Contract / Oracle Contract)
6) Surplus XTZ remaining in the Hashing Contract after NFTs are transferred to the winner can be sent to COI as payment of service operation. Transfer COI earnings out of the contract and into COI custody can be conducted either manually or automatically.
7) A user can always withdraw their funds back to their wallet before calling the Hashing contract with `processPayment = true`, or if calling the contract with `processPayment = true` fails. If there's a race to claim the final NFT reward, the losing party won't end up with their funds stuck in the contract irretrievably. 

The above works because the Hashing contract processes the transaction on the user's behalf. This ensures the user's answers were used to create the target hash and that the hash—since it's public knowledge—wasn't created arbitrarily.

<br/><br/><br/>
<p align="center">
  <img width="250px" height="auto" src="https://raw.githubusercontent.com/Chain-of-Insight/pop-machine-glow/master/Documentation/assets/img/pop_machine.png">
</p>

