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
        <!-- Puzzles -->
        <div class="card" v-for="puzzle in puzzles">
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
              <router-link class="btn btn-primary" :to="'/puzzle/' + puzzle.id">Solve</router-link>
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

export default {
  data: () => ({
    title: "Browse puzzles",
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
    puzzles: []
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
      let originationEntry = await this.getPuzzle("1583093350498");
      this.puzzles.push(originationEntry);
      console.log('Storage =>', this.puzzleStorage);
      console.log('Puzzles =>', this.puzzles);
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
        console.log(e);
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
</style>