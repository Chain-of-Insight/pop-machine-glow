const blake2b = require('blake2b');

const hash = function (b) {
    return blake2b(32).update(b).digest();
};

const deephash = function (b, depth) {
    for (i = 0; i < depth; i++) {
        b = hash(b);
    }
    return b;
};

const generateProof = function (message, depth) {
    const input = Buffer.from(message);
    const prefix = Buffer.from("0501", "hex");
    const len_bytes = Buffer.from(message.length.toString(16).padStart(8, '0'), "hex");
    var proof = Buffer.concat([prefix, len_bytes, input], prefix.length + len_bytes.length + input.length);
    return deephash(proof, depth)
};

const generateProofAsString = function(message, depth) {
    return '0x' + Buffer.from(generateProof(message, depth)).toString('hex');
};

const verifyProof = function (proof, verification, depth, atdepth) {
    depth = Math.abs(depth - atdepth);
    proof = deephash(Buffer.from(proof, "hex"), depth);
    hexProof = Buffer.from(proof).toString('hex');
    return hexProof == verification;
}

module.exports = {
    generateProofAsString: generateProofAsString,
    verifyProof: verifyProof
};
