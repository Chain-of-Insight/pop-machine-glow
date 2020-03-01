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

# See:
LIGO Types: https://gitlab.com/ligolang/ligo/blob/dev/src/passes/operators/operators.ml#L35
Fi Types: https://learn.fi-code.com/overview/types

# How:

The Oracle contract is the main worker for handling storage from the puzzle's Author and is responsible for managing the event queue for verifying results from the puzzle's players. The main worker for handling encryption of plain text strings (the answers) must be handled client side to ensure a puzzle's solutions are kept a secret and won't become publicly accessible once the puzzle entry is stored.

To encrypt the answers we'll store access to our primitives and cipher algorithms in a different smart contract, called the Hashing contract, which is callable without a gas payment. This allows an author to generate encrypted bytes data to send to storage in the Oracle contract without needing to `POST` that data over `HTTP`.


<br/><br/><br/>
<p align="center">
  <img width="250px" height="auto" src="https://raw.githubusercontent.com/Chain-of-Insight/pop-machine-glow/master/Documentation/assets/img/pop_machine.png">
</p>

