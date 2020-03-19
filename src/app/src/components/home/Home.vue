<template>
  <div>

    <!-- Connect -->
    <div class="connect-wallet" v-if="!connected">
      <div>
        <ul>
          <li class="connect" @click="connectUser()">
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
      <ul v-if="connected">
        <li>
          <router-link to="/puzzle/create">Create Puzzle</router-link>
        </li>
        <li>
          <router-link to="/puzzles">Browse Puzzles</router-link>
        </li>
        <li>
          <router-link to="/my-puzzles">My Puzzles</router-link>
        </li>
      </ul>
      <p v-else>Connect your Tezos wallet to get started</p>
    </div>

    <div class="footer">
      <img src="../../assets/img/pop_machine.png" />
    </div>

  </div>
</template>


<script>
import { 
  Tezos,
  mountProvider,
  getBalance
} from '../../services/tezProvider';

export default {
  data: () => ({
    title: "Home",
    network: null,
    address: null,
    getBalance: getBalance,
    currentBalance: null,
    connected: false,
    Tezos: Tezos,
    mountProvider: mountProvider
  }),
  mounted: async function () {
    await this.mountProvider();
    this.network = "Babylonnet";
    console.log('Home mounted');
    let returningUser = sessionStorage.getItem('tzAddress');
    if (returningUser) {
      this.connected = true;
      this.address = returningUser;
      let balance = await this.getBalance(this.address);
      this.currentBalance = Number(balance) / 1000000;
      console.log("User balance =>", this.currentBalance);
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
  }
};
</script>

<style scoped>
  .container {
    width: 800px;
    margin: 50px auto;
    text-align: center;
  }
  ul {
      list-style: none;
      display: block;
      padding-left: 0;
  }
  li {
    width: 20%;
    display: inline-block;
  }
  li, button {
    padding: 1rem;
    margin: 1rem;
    background: aliceblue;
    cursor: pointer;
  }
  div.footer {
    width: 100%;
    display: block;
    text-align: center;
  }
  div.footer img {
    margin: auto;
  }
</style>