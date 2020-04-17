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

      <h1>{{ title }}{{ $route.params.id }}</h1>
      
      <div class="container-fluid">
        <!-- Puzzles -->
        <div class="card puzzle-card" v-if="puzzle">
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
              <span>{{ (puzzle.rewards - toClaimedNumber(puzzle)) }}</span>
            </div>
            <!-- Puzzle Secret Answer -->
            <div class="answers puzzle-entry">
              <span class="bold">Secret answer: </span>
              <span class="descr">{{ puzzle.rewards_h }}</span>
            </div>
            <!-- Puzzle - Start Solving / Reset Solution Checker -->
            <div class="to-puzzle puzzle-entry">
              <div 
                class="btn btn-primary" 
                @click="startSolving()"
                v-if="!solve.started"
              >Start</div>
              <div 
                class="btn btn-primary" 
                @click="resetSolving()"
                v-if="solve.started"
              >Start Over</div>
            </div>
          </div>
        </div> 
      </div>

      <div class ="container-fluid" v-if="solve.started">

        <!-- Solution Wizard -->
        <div class="solve-wizard jumbotron" v-if="!solve.result.claimSubmitted">
          <span class="close close-x" @click="closeSolver()">&times;</span>
          <!-- Enter Plain Text Solutions (N Times) -->
          <div v-for="index in solve.questionFields" class="solution raw">
            <label>Answer #{{ index }}</label><br/>
            <input v-if="!solve.result.submittable" type="text" placeholder="Secret answer" v-model="solve.solutions.raw[index - 1]" />
            <input v-if="solve.result.submittable" type="password" placeholder="Secret answer" v-model="solve.solutions.raw[index - 1]" readonly />
          </div>
          <!-- Submit Solutions -->
          <div class="crypto-trigger" v-if="!solve.result.submittable">
            <button class="btn-inverse btn-solve" @click="checkSolutions()" v-if="solve.questionFields > 1">Submit Solutions</button>
            <button class="btn-inverse btn-solve" @click="checkSolutions()" v-else>Submit Solution</button>
          </div>

          <!-- Results Display -->
          <div class="solve-wizard" v-if="solve.result.checked">
            <!-- Correct Result -->
            <div class="bg-success" v-if="solve.result.submittable">
              <p v-if="solve.questionFields > 1">Your answers have been verified locally!</p>
              <p v-if="solve.questionFields == 1">You answer has been verified locally!</p>
              <!-- Claim -->
              <div class="crypto-trigger" v-if="(puzzle.rewards - puzzle.numClaimed) > 0">
                <button class="btn-inverse btn-solve" @click="claimReward()">Claim Reward</button>
              </div>
              <div class="crypto-sorry" v-if="(puzzle.rewards - puzzle.numClaimed) == 0">
                <p>There are no rewards remaining, better luck next time.</p>
              </div>
            </div>
            <!-- Try again -->
            <div class="bg-danger" v-if="!solve.result.submittable || errors">
              <div v-if="!solve.result.submittable">
                <p v-if="solve.questionFields > 1">Your answers could not be verified.</p>
                <p v-if="solve.questionFields == 1">You answer could not be verified.</p>
              </div>
              <div v-if="errors">
                <p>Error claiming reward:</p>
                <p>{{ this.errors }}</p>
              </div>
            </div>
          </div>
        </div>

        <!-- Claim Transaction -->
        <div class="solve-wizard jumbotron" v-if="solve.result.claimSubmitted">
          <h5 v-if="currentMsgState == 1">{{ messages.SUBMITTED }}</h5>
          <h5 v-if="currentMsgState == 2">{{ messages.CONFIRMED }}</h5>

            <!-- Transaction Data -->
            <div class="crypto-view" v-if="currentMsgState == 2">
              <p>
                <a :href="transactionExplorerLink" target="_blank">View transaction in explorer</a>
              </p>
            </div>

            <!-- Loading Display -->
            <div class="loading" v-if="loading">
              <img class="loading" src="../../assets/img/loading.gif">
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

import { generateProofAsString } from '../../services/hasher';

import { imageServer } from '../../services/imageProvider';

export default {
  data: () => ({
    title: "Puzzle #",
    network: null,
    address: null,
    getBalance: getBalance,
    currentBalance: null,
    connected: false,
    Tezos: Tezos,
    mountProvider: mountProvider,
    getContractInstance: getContractInstance,
    contracts: contracts,
    generateProofAsString: generateProofAsString,
    imageServer: imageServer,
    contractInstance: null,
    puzzleStorage: null,
    puzzleId: null,
    puzzle: null,
    loading: false,
    solve: {
      started: false,
      questionFields: 0,
      solutions: {
        raw: [],
        encrypted: null
      },
      result: { 
        submittable: false,
        checked: false,
        claimSubmitted: false
      }
    },
    // Tx. Data
    explorerPrefix: "https://better-call.dev/carthage/",
    transactionExplorerLink: null,
    transactionData: null,
    currentMsgState: 0,
    messages: {
      READY_TO_SUBMT: "Your reward claim is ready to be submitted to the Tezos network",
      SUBMITTED: "Your reward claim has been submitted to the Tezos network",
      CONFIRMED: "Reward has been transferred to your wallet"
    },
    errors: null
  }),
  mounted: async function () {
    this.puzzleId = this.$route.params.id;
    await this.mountProvider();
    this.network = "Carthagenet";
    console.log('View single ID mounted', this.puzzleId);
    let returningUser = sessionStorage.getItem('tzAddress');
    if (returningUser) {
      this.connected = true;
      this.address = returningUser;
      let balance = await this.getBalance(this.address);
      this.currentBalance = Number(balance) / 1000000;
      //console.log("User balance =>", this.currentBalance);
    }
    // Load puzzle storage
    this.getPuzzle();
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
    getPuzzle: async function () {
      if (!this.puzzleId) {
        console.log('Storage not ready');
        return;
      }

      const contractAddress = this.contracts.oracle;
      this.contractInstance = await this.getContractInstance(contractAddress);
      this.puzzleStorage = await this.contractInstance.storage();
      
      try {
        let bigMapEntry = await this.puzzleStorage.get(this.puzzleId);
        this.puzzle = bigMapEntry;
        this.puzzle.numClaimed = Object.keys(this.puzzle.claimed).length;
      } catch(e) {
        console.log(e);
      }

    },
    startSolving: function () {
      console.log(this.puzzle);
      this.solve.questionFields = Number(this.puzzle.questions);
      this.solve.started = true;
      console.log(this.solve);
    },
    resetSolving: async function (hardReset = false) {
      this.solve = {
        started: false,
        questionFields: 0,
        solutions: {
          raw: [],
          encrypted: null
        },
        result: { 
          submittable: false,
          checked: false
        }
      };
      // Load puzzle storage
      await this.getPuzzle();
      // Open solve panel as required
      if (!hardReset)
        this.startSolving();
    },
    closeSolver: function () {
      const forceHardReset = true;
      this.resetSolving(forceHardReset);
    },
    checkSolutions: function () {
      this.solve.result.submittable = false;
      this.solve.result.checked = false;
      this.solve.result.claimSubmitted = false;
      // Depth
      let depth = Number(this.puzzle.rewards) + 1;
      console.log('Encryption depth =>', depth);

      // Answers
      let answers = JSON.stringify(this.solve.solutions.raw);
      let encryptedAnswers = this.generateProofAsString(answers, depth);
      console.log('Answers =>', [answers, encryptedAnswers]);

      // Hash comparison
      if (encryptedAnswers.slice(2, encryptedAnswers.length) == this.puzzle.rewards_h) {
        this.solve.result.submittable = true; // GG!
        this.solve.result.checked = true;
      } else {
        this.solve.result.checked = true;
      }
      console.log('this.solve', this.solve);
    },
    claimReward: async function () {
      // Depth
      let depth = (Number(this.puzzle.rewards) - Number(this.puzzle.numClaimed));
      console.log('Encryption depth =>', depth);

      // Answers
      let answers = JSON.stringify(this.solve.solutions.raw);
      let encryptedAnswers = this.generateProofAsString(answers, depth);
      console.log('Claim Answers =>', [answers, encryptedAnswers]);

      // Set loading / Debug
      this.loading = true;
      this.solve.solutions.encrypted = encryptedAnswers;

      // Contract instance
      const contractAddress = this.contracts.oracle;
      this.contractInstance = this.getContractInstance(contractAddress);

      // Resolve transaction
      this.contractInstance.then(async (contract) => {
        console.log('Contract', contract);

        let id = Number(this.puzzleId),
            proof = this.solve.solutions.encrypted.slice(2, this.solve.solutions.encrypted.length);

        console.log('calling args.', [id, proof]);

        let result = await contract.methods.solve(id, proof).send();

        this.currentMsgState = 1; // Tx. Submitted
        this.solve.result.claimSubmitted = true;

        // Polls every 1 sec. for incoming data
        let timedEvent = setInterval(() => {
          if (result.hasOwnProperty('results')) {
            if (result.results) {
              if (result.results.length) {
                clearInterval(timedEvent);
                let opResults = result.results;
                this.transactionData = JSON.stringify(opResults, null, 2); // Indent 2 JSON output spaces
                this.loading = false;
                let hash = (result.hasOwnProperty('hash')) ? String(result.hash) : false;
                if (hash) {
                  this.transactionExplorerLink = this.explorerPrefix + hash;
                }
                this.currentMsgState = 2; // Tx. Confirmed
                //console.log([this.transactionData, this.transactionExplorerLink]);
              }
            }
          }
        }, 1000);

      }).catch((error) => {
        console.log('ERROR CLAIMING REWARD: =>', error);
        if (error.hasOwnProperty('message')) {
          this.errors = error.message;
        }
        this.loading = false;
      });

    },
    toClaimedNumber: function (puzzle) {
      if (!puzzle) {
        return '';
      } else if (!puzzle.hasOwnProperty('claimed')) {
        return '';
      } else if (puzzle.hasOwnProperty('numClaimed')) {
        return puzzle.numClaimed;
      } else {
        let claimedQuantity = Object.keys(puzzle.claimed).length;
        return claimedQuantity;
      }
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
    background: aliceblue;
    cursor: pointer;
  }
  div.card {
    text-align: left;
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
  li, button {
    padding: 1rem;
    margin: 1rem;
  }
  button {
    cursor: pointer;
  }
  button:disabled {
    opacity: 0.7;
  }
  div.create-wizard {
    text-align: left;
  }
  div.solution {
    margin-top: 1rem;
  }
  input[type=radio] {
    margin-left: 0.25rem;
    margin-right: 0.5rem;
  }
  input[type=text], input[type=password] {
    width: 100%;
    padding: 1rem;
  }
  input.success {
    color: #ffffff;
  }
  button {
    margin-left: auto;
    margin-right: auto;
    margin-top: 2rem;
  }
  h5 {
    margin-top: 1rem;
  }
  .jumbotron {
    margin-top: 1rem;
    text-align: left;
  }
  .bg-success, .bg-danger {
    color: #ffffff;
    padding: 2rem;
    margin-top: 1rem;
  }
  .close.close-x {
    position: relative;
    cursor: pointer;
    top: -55px;
    left: 20px;
  }
</style>