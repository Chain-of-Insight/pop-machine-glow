<template>
  <div>

    <!-- Connect -->
    <div class="connect-wallet" v-if="!connected">
      <div>
        <ul>
          <li @click="connectUser()">
            <span class="btn-connect">Connect</span>
          </li>
        </ul>
      </div>
    </div>

    <!-- Navigation -->
    <div class="navigation" v-else>
      <p v-if="address">
        <strong>Your address: </strong>
        <span>{{ address }} </span>
        <span class="balance-status" v-if="currentBalance"><strong>({{ currentBalance }} ꜩ)</strong></span>
      </p>
      
      <p v-if="network">
        <strong>Current network: </strong>
        <span>{{ network }}</span>
      </p>

      <!-- Back Home -->
      <div>
        <ul>
          <li>
            <router-link to="/">Back</router-link>
          </li>
        </ul>
      </div>

    </div>

    <!-- Content -->
    <div class="container">

      <h1>{{ title }}</h1>
      
      <div class="container-fluid">
        <!-- Verify Proof -->
        <div v-if="selectedPuzzle">
          <div class="create-wizard jumbotron">
            <!-- Selected Puzzle ID -->
            <h5 class="card-title">Puzzle ID: {{ selectedPuzzle }}</h5>
            
            <!-- Puzzle Icon -->
            <div class="icon-wrapper" v-if="loadedPuzzle">
              <div class="icon-t" :style="'background-image: url(' + imageServer + '0x' + loadedPuzzle.rewards_h + ')'" v-if="loadedPuzzle.rewards_h"></div>
            </div>

            <!-- Proof Index -->
            <div class="proof-element">
              <label>Depth of proof:</label><br/>
              <input type="number" min="0" max="99" placeholder="Index" v-model="proofIndex" />
            </div>

            <!-- Proof -->
            <div class="proof-element">
              <label>Proof:</label><br/>
              <input type="text" placeholder="Proof to be verified" v-model="proof" />
            </div>

            <!-- Verify Proof -->
            <div class="proof-controls">
              <button class="btn-primary is-disabled" v-if="!proofIndex || !proof" disabled>Run Prover</div>
              <button class="btn-success" v-if="proofIndex && proof" @click="verifyProof()">Run Prover</div>
            </div>

            <!-- Prover Errors -->
            <div class="danger bg-danger" v-if="errors.hasOwnProperty('msg')">
              <span class="prover-error" v-if="errors.msg">{{ errors.msg }}</span>
            </div>

            <!-- Proof Verified -->
            <div class="success bg-success proof-verified" v-if="proofVerified == true">
              <span class="verified-proof" v-if="proofVerified">Proof verification successful!</span>
            </div>
          </div>
        </div>
        <!-- Puzzles -->
        <div class="card puzzle-card" v-for="(puzzle, index) in puzzles" v-if="!selectedPuzzle">
          <div class="card-body">
            <!-- Puzzle Title -->
            <h5 class="card-title">Puzzle: {{ puzzle.id }}</h5>
            <!-- Puzzle Icon -->
            <div class="icon-wrapper">
              <div class="icon-t" :style="'background-image: url(' + imageServer + '0x' + puzzle.rewards_h + ')'"></div>
            </div>
            <!-- Puzzle Author -->
            <div class="author puzzle-entry">
              <span class="bold">Author: </span>
              <span class="descr">{{ puzzle.author }}</span>
            </div>
            <!-- Puzzle Rewards -->
            <div class="rewards puzzle-entry">
              <span class="bold">Total rewards: </span>
              <span>{{ puzzle.rewards }}</span><br/>
              <span class="bold">Rewards available: </span>
              <span>{{ (puzzle.rewards - toClaimedNumber(puzzle.claimed)) }}</span>
            </div>
            <!-- Puzzle Secret Answer -->
            <div class="answers puzzle-entry">
              <span class="bold">Secret answer: </span>
              <span class="descr">{{ puzzle.rewards_h }}</span>
            </div>
            <!-- Go To Puzzle -->
            <div class="to-puzzle puzzle-entry">
              <div class="btn btn-primary" @click="selectPuzzle(puzzle.id, true, index)">Verify Proof</div>
            </div>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script>
import { 
  Tezos,
  mountProvider,
  getBalance,
  getContractInstance,
  contracts
} from '../../services/tezProvider';

import { generateKnowledgeCommitmentVerifier } from '../../services/hasher';

import { imageServer } from '../../services/imageProvider';

export default {
  data: () => ({
    title: "",
    titles: ["Select puzzle", "Verify proof"],
    network: null,
    address: null,
    getBalance: getBalance,
    currentBalance: null,
    connected: false,
    Tezos: Tezos,
    mountProvider: mountProvider,
    getContractInstance: getContractInstance,
    contracts: contracts,
    imageServer: imageServer,
    contractInstance: null,
    generateKnowledgeCommitmentVerifier: generateKnowledgeCommitmentVerifier,
    puzzleStorage: null,
    puzzles: [],
    selectedPuzzle: null,
    proof: null,
    proofIndex: null,
    loadedPuzzle: null,
    errors: {},
    proofVerified: null
  }),
  mounted: async function () {
    await this.mountProvider();
    this.network = "Carthagenet";
    console.log('Verify mounted');
    let returningUser = sessionStorage.getItem('tzAddress');
    if (returningUser) {
      this.connected = true;
      this.address = returningUser;
      let balance = await this.getBalance(this.address);
      this.currentBalance = Number(balance) / 1000000;
      //console.log("User balance =>", this.currentBalance);
    }
    // View context
    if (this.$route.params.hasOwnProperty('id')) {
      if (this.$route.params.id) {
        this.selectPuzzle(this.$route.params.id);
      } else {
        this.title = this.titles[0];
        // Load puzzle storage
        this.loadStorage();
      }
    } else {
      this.title = this.titles[0];
      // Load puzzle storage
      this.loadStorage();
    }
  },
  methods: {
    connectUser: async function () {
      // Connect as required
      if (this.connected)
        return;

      // Signer instance
      this.address = await tezbridge.request({method: 'get_source'});
      
      // Fetch balance / Connection callbacks
      if (typeof this.address == 'string') {
        if (this.address.length === 36) {
          console.log('User XTZ Address =>', this.address);
          sessionStorage.setItem('tzAddress', this.address);
          this.connected = true;
          let balance = await this.getBalance(this.address);
          this.currentBalance = Number(balance) / 1000000;
          console.log("User balance =>", this.currentBalance);
        }
      }
    },
    selectPuzzle: async function (puzzleId, preLoaded = false, index = false) {
      console.log([puzzleId, preLoaded, index]);
      if (!puzzleId) {
        return;
      }
      this.selectedPuzzle = puzzleId;
      this.title = this.titles[1];
      if (preLoaded && typeof index == 'number') {
        this.loadedPuzzle = this.puzzles[index];
      } else {
        // Load puzzle storage
        await this.loadStorage();
        // Load puzzle entry
        this.loadedPuzzle = await this.getPuzzle(puzzleId);
      }
      console.log("Loaded Puzzle =>", this.loadedPuzzle);
    },
    verifyProof: function () {
      if (!this.proofIndex || !this.proof) {
        console.warn("Invalid proof, missing required args.")
        return;
      }
      const proofIndex = parseInt(this.proofIndex);
      const proof = String(this.proof);
      console.log("Running prover with args. =>", {proofIndex: proofIndex, proof: proof});
      this.prover(proofIndex, proof);
    },
    prover: function (depth, proof) {
      // Reset prover state
      this.errors = {};
      this.proofVerified = false;
      // Proof or depth or selected puzzle missing
      if (!depth || !proof || !this.loadedPuzzle.rewards_h) {
        this.errors = {msg: "Proof is missing required arguments"};
        return false;
      // Incorrect depth format
      } else if (typeof depth != 'number') {
        this.errors = {msg: "Incorrect depth format"};
        return false;
      // Incorrect proof format
      } else if (proof.length !== this.loadedPuzzle.rewards_h.length) {
        this.errors = {msg: "Incorrect proof format"};
        return false;
      }

      // Run prover
      let size = (Number(this.loadedPuzzle.rewards) + 1);
      let encryptedProof = this.generateKnowledgeCommitmentVerifier(proof, depth, size);

      // Hash comparison
      if (encryptedProof.slice(2, encryptedProof.length) == this.loadedPuzzle.rewards_h) {
        console.log("Proof verification successful!");
        this.proofVerified = true;
        return true;
      } else {
        this.errors = {msg: "Proof failed"};
        console.log(encryptedProof.slice(2, encryptedProof.length));
        return false;
      }
    },
    loadStorage: async function () {
      const contractAddress = this.contracts.oracle;
      this.contractInstance = await this.getContractInstance(contractAddress);
      this.puzzleStorage = await this.contractInstance.storage();
      console.log('Storage =>', this.puzzleStorage);

      // Iterate big_map with natural keys
      let iterating = true;
      let i = 1;
      while (iterating) {
        let puzzleEntry = await this.getPuzzle(String(i));
        if (!puzzleEntry) {
          iterating = false;
          break;
        } else {
          this.puzzles.push(puzzleEntry);
          ++i;
        }
      }
    },
    getPuzzle: async function (bigMapKey) {
      if (!this.puzzleStorage)
        return;
      else if (typeof this.puzzleStorage !== 'object')
        return;
      else if (typeof bigMapKey !== 'string')
        return;
      
      try {
        let bigMapEntry = await this.puzzleStorage.get(bigMapKey);
        return bigMapEntry;
      } catch(e) {
        //console.log(e);
        return false;
      }

    },
    toClaimedNumber: function (claimedMap) {
      //console.log('claimedMap =>', claimedMap);
      if (!claimedMap) {
        return '';
      }
      let claimedQuantity = Object.keys(claimedMap).length;
      return claimedQuantity;
    }
  }
};
</script>

<style scoped>
  .container {
    width: 600px;
    margin: 50px auto;
    text-align: center;
  }
  ul {
      list-style: none;
      display: inline-block;
  }
  li, button {
    padding: 1rem;
    margin: 1rem;
    cursor: pointer;
  }
  li, button:not(.btn-success):not(.btn-primary) {
    background: aliceblue;
  }
  div.puzzle-card {
    text-align: left;
    margin-bottom: 1rem;
  }
  .descr {
    font-size: 14px;
  }
  .puzzle-entry {
    padding: 0.5rem;
  }
  .to-puzzle {
    text-align: center;
  }
  input[type=number] {
    width: 40%;
    padding: 1rem;
  }
  input[type=text] {
    width: 100%;
    padding: 1rem;
  }
  div.proof-element,
  label {
    text-align: left;
    width: 100%;
  }
  div.proof-element {
    margin-bottom: 1.25rem;
  }
  .is-disabled {
    opacity: 0.75;
    cursor: not-allowed;
  }
  .card-title {
    text-align: left;
  }
  .card.puzzle-card {
    max-width: 600px;
    margin: auto;
  }
</style>