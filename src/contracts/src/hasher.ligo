(* Hashing implementation *)
function hash (const b : bytes) : bytes is
  block {
    skip
  } with Crypto.blake2b(b)

(* Recursive hash depth times *)
function deephash(var b : bytes; const depth: nat) : bytes is
  block {
    var i : nat := 1n;
    while i <= depth block {
      b := hash(b);
      i := i + 1n;
    }
  } with b

(* Generate HASH^depth(s) *)
function generate_proof (const solution: string; const depth: nat) : bytes is
  block {
    var proof : bytes := deephash(Bytes.pack(solution), depth);
  } with proof

(* Verify proof=HASH^atdepth of chain verification=HASH^depth *)
function verify_proof (const proof : bytes; const verification : bytes; const depth: nat; const atdepth: nat) : bool is
  block {
    skip
  } with ( deephash(proof, abs(depth - atdepth)) = verification)
