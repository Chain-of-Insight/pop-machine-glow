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
        <div class="card" v-if="puzzle">
          <!--
          <img class="card-img-top" src="https://via.placeholder.com/25x25" alt="Card image cap">
          -->
          <div class="card-body">
            <h5 class="card-title">Puzzle: {{ puzzle.id }}</h5>
            <div class="author puzzle-entry">
              <span class="bold">Author: </span>
              <span class="descr">{{ puzzle.author }}</span>
            </div>
            <div class="rewards puzzle-entry">
              <span class="bold">Total rewards: </span>
              <span>{{ puzzle.rewards }}</span><br/>
              <span class="bold">Rewards available: </span>
              <span>{{ (puzzle.rewards - puzzle.claimed) }}</span>
            </div>
            <div class="answers puzzle-entry">
              <span class="bold">Secret answer: </span>
              <span class="descr">{{ puzzle.rewards_h }}</span>
            </div>
            <div class="to-puzzle puzzle-entry">
              <div 
                class="btn btn-primary" 
                @click="startSolving()">Start</div>
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
    contractInstance: null,
    puzzleStorage: null,
    puzzleId: null,
    puzzle: null
  }),
  mounted: async function () {
    this.puzzleId = this.$route.params.id;
    await this.mountProvider();
    this.network = "Babylonnet";
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
        console.log('not ready');
        return;
      }

      const contractAddress = this.contracts.oracle;
      this.contractInstance = await this.getContractInstance(contractAddress);
      this.puzzleStorage = await this.contractInstance.storage();
      
      try {
        let bigMapEntry = await this.puzzleStorage.get(this.puzzleId);
        this.puzzle = bigMapEntry;
      } catch(e) {
        console.log(e);
      }

    },
    startSolving: function () {
      alert('TODO: Refactor oracle.ligo to store question quantity, so we know how many question fields to display to the solver...');
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
</style>