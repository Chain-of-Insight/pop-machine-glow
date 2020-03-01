# PoP Machine Glow
PoP Machine Glow (PoPMG) is a zero knowledge encryption oracle and DApp that provides users and puzzle authors with methods to obtain verifiable proof of test completion. PoPMG verifies your user knows an without itself holding a plain text version of the answer. 

### All your answers are ~~belong~~ _unknown_ to us

Storage of puzzle answers is handled by the Oracle smart contract; this contract stores the Puzzle ID and its associated answers in a Michelson record type (storage) variable:

Example (Ligo / Pascal)

```
type Puzzle is
  record [
    id      : string;   // e.g. Creation Time + User Address
    author  : address;  // Author address
    name    : string;   // Puzzle name (frontend display)
    domain  : string;   // Where to find the puzzle online
    answers : bytes     // Encrypted bytes output of hasher contract
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
    answers = encryptedOutput
  ]
```

## See:
- LIGO Types: https://gitlab.com/ligolang/ligo/blob/dev/src/passes/operators/operators.ml#L35
- Fi Types: https://learn.fi-code.com/overview/types

# How:

The *Oracle contract* is the main worker for handling storage from the puzzle's Author and is responsible for managing the event queue for verifying results from the puzzle's players. The main worker for handling encryption of plain text strings (the answers) must be handled client side to ensure a puzzle's solutions are kept a secret and won't become publicly accessible once the puzzle entry is stored.

To encrypt the answers we'll store access to our primitives and cipher operations in a different smart contract, we can call this the *Hashing contract*, which is callable without a gas payment. This allows an author to generate encrypted bytes data to send to storage in the Oracle contract without needing to `POST` that data over `HTTP`, and its players to verify they've got a correct set of answers.

To do this, the *Hashing contract* uses its public key for encryption operations. This key is visible to everyone, but that's also what enables all parties involved (Author, Oracle and Player) to each call the contract independently and produce a reliable encrypted or decrypted result without needing to `POST` the answers of `HTTP`.

E.g. (TODO XXX: This part is vague / informal)
1) Puzzle author (Client): Hasher_Key + Answers => Encrypted Bytes (Oracle Storage)
2) User encrypts (Client): (User_key + Hasher_key) + Answers => Encrypted Bytes (Comparison hash)
3) Oracle decrypts (Oracle): Decrypt bytes using User_key + Public_Key (must be private local variable) and re-encrypt that output using Hasher_key + Decrypted => Encrypted Bytes - if this output matches the puzzle ID's storage value in `answers` return true, else return false / throw;

# Why: 

Now that we have our Zero Knowledge protocol for answer verification, it's time to have some fun with it!

The first use case we have 

## See:
- Tezos NFT Standard https://nft.stove-labs.com/ (beta)

<br/><br/><br/>
<p align="center">
  <img width="250px" height="auto" src="https://raw.githubusercontent.com/Chain-of-Insight/pop-machine-glow/master/Documentation/assets/img/pop_machine.png">
</p>

