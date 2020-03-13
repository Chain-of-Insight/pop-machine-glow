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
      
      <!-- Create Puzzle Form -->
      <div class="create-wizard jumbotron">
        
        <!-- Step: DEFINE ANSWERS (Plain Text) -->
        <div v-if="currentStep == DEFINE_ANSWERS">
          <!-- Set Answer Quantity -->
          <label for="p_quantity">Riddle quantity:</label>
          <p class="descr">How many secret answers are needed to solve your entire puzzle?</p>
          <input name="p_quantity" type="number" v-model="puzzle.solutionQuantity" min="0" max="50" />

          <!-- Set Prize Quantity -->
          <div class="rewards-toggle">
            <p>Offer rewards: </p>
            <label for="rewards">Yes: </label>
            <input type="radio" id="rewards" name="rewards" v-bind:value="true" v-model="hasRewards">
            <label for="rewards">No: </label>
            <input type="radio" id="no_rewards" name="rewards" v-bind:value="false" v-model="hasRewards">
          </div>
          <div class="rewards-quantity" v-if="hasRewards">
            <label for="pr_quantity">Prize quantity:</label>
            <p class="descr">How many NFT prizes are you offering as reward?</p>
            <input name="pr_quantity" type="number" v-model="puzzle.rewardQuantity" min="0" max="10" />
          </div>

          <!-- Enter Plain Text Solutions (N Times) -->
          <div v-for="index in solutionQuantity" class="solution raw">
            <label>Answer #{{ index }}</label><br/>
            <input type="text" placeholder="Secret answer" v-model="puzzle.solutions.raw[index - 1]" />
          </div>
        </div>

        <!-- Step: ENCRYPT ANSWERS (enc) -->
        <div v-if="currentStep == ENCRYPT_ANSWERS">
          <!-- READ ONLY: Answer Quantity -->
          <label for="p_quantity_read_only">Riddle quantity:</label>
          <input name="p_quantity_read_only" type="number" v-model="puzzle.solutionQuantity" min="0" max="50" readonly />
          <!-- READ ONLY: Rewards Quantity -->
          <span v-if="hasRewards">
            <label class="rewards-quantity" class="pr_quantity" for="pr_quantity_read_only">Prize quantity:</label>
            <input name="pr_quantity_read_only" type="number" v-model="puzzle.rewardQuantity" min="0" max="10" readonly />
          </span>
          <!-- READ ONLY: Solutions (N Times) -->
          <h5>Plain-text answers:</h5>
          <div v-for="index in solutionQuantity" class="solution raw">
            <input type="text" placeholder="Secret answer" v-model="puzzle.solutions.raw[index - 1]" readonly />
          </div>
          <!-- Enc. Output -->
          <h5 v-if="puzzle.solutions.encrypted">Encrypted answers:</h5>
          <div class="solution enc" v-if="puzzle.solutions.encrypted">
            <input 
              type="text" 
              class="bg-success success"
              placeholder="Secret answer" 
              v-model="puzzle.solutions.encrypted" 
              v-if="(typeof puzzle.solutions.encrypted == 'string' && puzzle.solutions.encrypted.length == 66)"
              readonly 
            />
          </div>
          <!-- Submit for encryption -->
          <div class="crypto-trigger">
            <button 
              class="btn-inverse" 
              @click="generateEncryptedAnswers()"
            >Encrypt Answers</button>
          </div>
        </div>

        <!-- Step: Submit Create Puzzle Tx. -->
        <div v-if="currentStep == CREATE_PUZZLE">
          <h5>Your puzzle is ready to be submitted to the Tezos network</h5>
          <div class="crypto-trigger">
            <button class="btn-inverse" @click="createPuzzleTx()">Create Puzzle</button>
          </div>
        </div>

        <!-- Step Controls (Next / Previous) -->
        <div>
          <!-- Prev. Step -->
          <button 
            class="btn-primary step-back" 
            v-if="currentStep > DEFINE_ANSWERS"
            @click="--currentStep"
          >Previous</button>
          <!-- Next Step -->
          <button 
            class="btn-primary step-forward" 
            v-if="currentStep < CREATE_PUZZLE" 
            @click="++currentStep"
            :disabled="!isValidSolutionSet"
          >Next</button>
        </div>
      </div>

    </div>

  </div>
</template>

<script>
import { 
  Tezos,
  mountProvider,
  getBalance
} from '../../services/tezProvider';

import { generateProofAsString } from '../../services/hasher';

export default {
  data: () => ({
    title: "Create new puzzle",
    network: null,
    address: null,
    getBalance: getBalance,
    currentBalance: null,
    connected: false,
    Tezos: Tezos,
    mountProvider: mountProvider,
    generateProofAsString: generateProofAsString,
    canProceed: false,
    // State machine
    DEFINE_ANSWERS: 0, 
    ENCRYPT_ANSWERS: 1,
    CREATE_PUZZLE: 2,
    steps: [0,1,2], // e.g. DEFINE_ANSWERS, ENCRYPT_ANSWERS, CREATE_PUZZLE
    currentStep: 0, // DEFINE_ANSWERS,
    hasRewards: false,
    puzzle: {
      solutionQuantity: 0,
      rewardQuantity: 0,
      solutions: {
        raw: [],
        encrypted: null
      }
    }
  }),
  mounted: async function () {
    await this.mountProvider();
    this.network = "Babylonnet";
    console.log('Create mounted');
    let returningUser = sessionStorage.getItem('tzAddress');
    if (returningUser) {
      this.connected = true;
      this.address = returningUser;
      let balance = await this.getBalance(this.address);
      this.currentBalance = Number(balance) / 1000000;
      //console.log("User balance =>", this.currentBalance);
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
    generateEncryptedAnswers: function () {
      this.canProceed = false;

      if (typeof this.puzzle.solutions.raw !== 'object') {
        return;
      } else if (!this.puzzle.solutions.raw.length) {
        return;
      }

      console.log([typeof this.hasRewards]);

      if (typeof this.hasRewards !== "boolean") {
        this.puzzle.rewardQuantity = 0;
      } else if (!this.hasRewards) {
        this.puzzle.rewardQuantity = 0;
      } 

      // Create string from answer array
      let answers = JSON.stringify(this.puzzle.solutions.raw);
      let encryptedAnswers = this.generateProofAsString(answers, (this.puzzle.rewardQuantity + 1));
      this.puzzle.solutions.encrypted = encryptedAnswers;
      this.canProceed = true;
      console.log('Encrypted set =>', [typeof encryptedAnswers,encryptedAnswers]);
      console.log('this.puzzle =>', this.puzzle);
    },
    createPuzzleTx: async function () {
      let todo = `
      TODO: Deploy contracts so we can send a Create Puzzle transaction to the Oracle Contract
      `;
      alert(todo);
      this.$router.push('/puzzles');
    }
  },
  computed: {
    solutionQuantity: function () {
      if (isNaN(this.puzzle.solutionQuantity)) {
        return 0;
      } else if (this.puzzle.solutionQuantity < 1) {
        return 0;
      } else {
        return Number(this.puzzle.solutionQuantity);
      }
    },
    isValidSolutionSet: function () {
      switch (this.currentStep) {
        case this.DEFINE_ANSWERS:
          // Parse empty fields
          let emptyFields = 0;
          for (let i = 0; i < this.puzzle.solutions.raw.length; i++) {
            //console.log([typeof this.puzzle.solutions.raw[i]], i);
            if (typeof this.puzzle.solutions.raw[i] !== 'string') {
              ++emptyFields;
            } else if (this.puzzle.solutions.raw[i].length < 1) {
              ++emptyFields
            }
            if (i == (this.puzzle.solutionQuantity - 1)) {
              if (emptyFields == 0) {
                //console.log(true);
                return true;
              } else {
                //console.log(false);
                return false;
              }
            }
          }
          break;
        case this.ENCRYPT_ANSWERS:
          return this.canProceed;
        default:
          return false;
      }
    }
  }
};
</script>

<style scoped>
  .container {
    width: 80%;
    margin: 10px auto;
    text-align: center;
  }
  ul {
      list-style: none;
      display: inline-block;
  }
  li {
    background: aliceblue;
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
  input[type=text] {
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
  div.rewards-toggle, div.rewards-quantity {
    padding-top: 1rem;
  }
  label.rewards-quantity {
    margin-left: 1rem;
  }
  .descr {
    font-size: 14px;
  }
</style>