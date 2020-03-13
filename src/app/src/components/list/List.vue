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
    </div>

    <!-- Content -->
    <div class="container">
      <h1>{{ title }}</h1>
      <ul>
        <li>
          <router-link to="/">Back</router-link>
        </li>
      </ul>
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
    loadStorage: async function () {//here
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
</style>