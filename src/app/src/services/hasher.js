const blake2b = require('blake2b');

const hash = function (b) {
    return blake2b(32).update(b).digest();
};

const generateProof = function (message, depth) {
    const input = Buffer.from(message);
    const prefix = Buffer.from("0501", "hex");
    const len_bytes = Buffer.from(message.length.toString(16).padStart(8, '0'), "hex");
    var proof = Buffer.concat([prefix, len_bytes, input], prefix.length + len_bytes.length + input.length);
    for (i = 0; i < depth; i++) {
        proof = hash(proof);
    }
    return proof;
};

const generateProofAsString = function(message, depth) {
    return '0x' + Buffer.from(generateProof(message, depth)).toString('hex');
};

const verifier = function (proof, depth, size) {
    depth = Number(depth);
    for (i = depth; i < size; i++) {
        proof = hash(proof);
    }
    return proof;
}

const generateKnowledgeCommitmentVerifier = function (proof, depth, size) {
    return '0x' + Buffer.from(verifier(proof, depth, size)).toString('hex');
}

module.exports = {
    generateProofAsString: generateProofAsString,
    generateKnowledgeCommitmentVerifier: generateKnowledgeCommitmentVerifier
};
