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
        
        <!-- Puzzles List -->
        <div v-if="currentState == PUZZLE_DISPLAY">
          
          <!-- My Puzzles -->
          <div v-if="puzzles.length">
            <!-- Puzzle Entry -->
            <div class="card puzzle-card" v-for="(puzzle, index) in puzzles">
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
                  <div class="btn btn-success" @click="showAddReward(index)">Add XTZ Reward</div>
                  <router-link class="btn btn-primary" :to="'/puzzle/' + puzzle.id">Solve</router-link>
                </div>
              </div>
            </div>
          </div>

          <!-- No Puzzles Found -->
          <div v-else>
            <p>No puzzles found for address <i>{{ address }}</i></p>
          </div>
        </div>

        <div v-if="currentState == ADD_REWARD">

          <!-- Add Reward Form -->
          <div class="create-wizard jumbotron">

            <!-- STEP 1: Form Completion -->
            <div v-if="currentMsgState == BEFORE_SUBMIT">
              
              <h5>Add an XTZ reward:</h5>
              
              <!-- Reward Amount -->
              <div class="rewards-amount">
                <label for="r_amount">Reward amount:</label>
                <input 
                  type="number" 
                  name="r_amount" 
                  placeholder="1.0" 
                  step="0.01" 
                  min="0" 
                  v-model="puzzleReward.amount"
                  @change="isValidRewardDonation()"
                > ꜩ
              </div>

              <!-- Reward Claimant Index -->
              <div class="rewards-claimant">
                <label for="r_amount">Which solver gets this reward? (Limited to first 10 solvers):</label>
                <input 
                  type="number" 
                  name="r_amount" 
                  placeholder="1" 
                  min="0" 
                  :max="puzzles[this.selectedIndex].rewards"
                  v-model="puzzleReward.claimIndex"
                  @change="isValidRewardDonation()"
                >
              </div>

              <!-- Submit -->
              <div class="crypto-trigger">
                <button 
                  class="btn-inverse btn-add-reward" 
                  @click="addReward()"
                  :disabled="!puzzleReward.submittable"
                >Add Reward</button>
              </div>

              <div class="bg-danger" v-if="errors">
                <p>{{ errors }}</p>
              </div>

              <div class="to-puzzle puzzle-entry">
                <div class="btn btn-primary" @click="currentState = PUZZLE_DISPLAY">Back</div>
              </div>
            </div>

            <!-- STEP 2: Submitted -->
            <div v-if="currentMsgState !== BEFORE_SUBMIT">

              <h5 v-if="currentMsgState == SUBMITTED">{{ messages.SUBMITTED }}</h5>
              <h5 v-if="currentMsgState == CONFIRMED">{{ messages.CONFIRMED }}</h5>

              <!-- Loading Display -->
              <div class="loading" v-if="loading">
                <img class="loading" src="../../assets/img/loading.gif">
              </div>

              <!-- View Puzzles / Tx. Data -->
              <div class="crypto-view" v-if="currentMsgState == CONFIRMED">
                <p>
                  <a :href="transactionExplorerLink" target="_blank">View transaction in explorer</a>
                </p>
              </div>

              <!-- Back -->
              <div class="to-puzzle puzzle-entry">
                <div class="btn btn-primary" @click="currentState = PUZZLE_DISPLAY">Back to puzzle</div>
              </div>
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

import { imageServer } from '../../services/imageProvider';

export default {
  data: () => ({
    title: "My puzzles",
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
    puzzleStorage: null,
    puzzles: [],
    puzzleReward: {
      id: null,
      amount: null,
      claimIndex: null,
      submittable: false
    },
    // State machine
    PUZZLE_DISPLAY: 0,
    ADD_REWARD: 1,
    currentState: 0,
    selectedPuzzle: null,
    selectedIndex: null,
    states: [0,1],
    // Operation
    loading: false,
    currentMsgState: 0,
    BEFORE_SUBMIT: 0,
    SUBMITTED: 1,
    CONFIRMED: 2,
    messages: {
      READY_TO_SUBMT: "Your rewards update is ready to be submitted to the Tezos network",
      SUBMITTED: "Your reward has been submitted to the Tezos network",
      CONFIRMED: "Your reward has been added to claim index "
    },
    errors: null,
    // Tx. Data
    explorerPrefix: "https://better-call.dev/babylon/",
    transactionExplorerLink: null,
    transactionData: null
  }),
  mounted: async function () {
    await this.mountProvider();
    this.network = "Babylonnet";
    console.log('List mounted');
    let returningUser = sessionStorage.getItem('tzAddress');
    if (returningUser) {
      this.connected = true;
      this.address = returningUser;
      let balance = await this.getBalance(this.address);
      this.currentBalance = Number(balance) / 1000000;
      //console.log("User balance =>", this.currentBalance);
    }
    // Load puzzle storage
    this.loadStorage();
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
    loadStorage: async function () {
      const contractAddress = this.contracts.oracle;
      this.contractInstance = await this.getContractInstance(contractAddress);
      this.puzzleStorage = await this.contractInstance.storage();
      console.log('Storage =>', this.puzzleStorage);

      // Iterate big_map with natural keys
      let iterating = true;
      let i = 1;
      while (iterating && i < 5) {
        let puzzleEntry = await this.getPuzzle(String(i));
        if (!puzzleEntry) {
          iterating = false;
          break;
        } else {
          // Push puzzle if addresses match
          //console.log(puzzleEntry);
          if (this.address) {
            if (this.address == puzzleEntry.author)
              this.puzzles.push(puzzleEntry);
          }
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
    },
    showAddReward: function (index) {
      // Reset form
      this.puzzleReward = {
        id: null,
        amount: null,
        claimIndex: null,
        submittable: false
      };
      this.currentMsgState = this.BEFORE_SUBMIT;

      // Set state
      this.selectedPuzzle = Number(this.puzzles[index].id);
      this.selectedIndex = index;
      this.puzzles[index].newReward = 0;
      this.currentState = this.ADD_REWARD;
      console.log(this.selectedPuzzle);
    },
    addReward: function () {
      console.log("Preparing add rewards...", [this.selectedPuzzle, this.puzzleReward]);
      if (!this.selectedPuzzle == 'undefined' || this.selectedIndex == 'undefined' || !this.puzzleReward.submittable) {
        return;
      } else {
        this.currentMsgState = 0;
        this.errors = null;
        // Loading state
        this.loading = true;
        
        // Selected puzzle id
        this.puzzleReward.id = this.selectedPuzzle;
        
        // Contract instance
        const contractAddress = this.contracts.rewards;
        this.contractInstance = this.getContractInstance(contractAddress);

        // Resolve transaction
        this.contractInstance.then(async (contract) => {
          console.log('Contract', contract);
          
          // Calling args.
          const id = this.puzzleReward.id;
          const price = Number(this.puzzleReward.amount);
          const claimant = parseInt(this.puzzleReward.claimIndex);

          let submit = [id, price, claimant];
        
          console.log('calling args.', submit);

          let result = await contract.methods.addDeposit(claimant, id).send({amount: price});

          this.currentMsgState = 1; // Tx. Submitted

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
          console.log('ERROR UPDATING PUZZLE: =>', error);
          if (error.message) {
            this.errors = error.message;
          }
          this.loading = false;
        });
      }
    },
    isValidRewardDonation: function () {
      //console.log(this.puzzleReward);
      this.errors = null;
      if (this.puzzleReward.amount 
          && this.selectedPuzzle !== 'undefined'
          && this.puzzleReward.claimIndex
          && !this.puzzleReward.submittable) {
            if (this.puzzleReward.claimIndex > this.puzzles[this.selectedIndex].rewards) {
              this.errors = "Error: rewards cannot be sent to solvers outside of the rewards range (" + this.puzzles[this.selectedIndex].rewards + ").";
            } else if (this.toClaimedNumber(this.puzzles[this.selectedIndex].claimed) > 0) {
              this.errors = "Adding prizes is only available for unsolved puzzles.";
            } else {
              this.puzzleReward.submittable = true;
            }
      }
    }
  }
};
</script>

<style scoped>
  .container {
    width: 90vw;
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
  div.puzzle-card, div.create-wizard {
    max-width: 540px;
    text-align: left;
    margin: auto;
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
    width: 42px;
  }
  .btn-add-reward {
    margin-left: 0;
  }
  .bg-success, .bg-danger {
    color: #ffffff;
    padding: 2rem;
    margin-top: 1rem;
    margin-bottom: 1rem;
  }
  .crypto-view {
    text-align: center;
    margin: 1rem;
  }
</style>