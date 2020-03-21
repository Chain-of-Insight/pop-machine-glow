# PoP Machine Glow - Tezos Contracts

## Dependencies

- **Docker** - used to run a local Tezos node together with the LIGO compiler (If you're on linux, follow the post-installation steps as well)
- **Node.js** - Javascript runtime environment that we'll use for testing and deployment
- **pytezos** & **pytest** - Testing framework

## Getting started

**Install the dependencies**
```shell
$ npm i
$ pip3 install -r requirements.txt
```

**Compile the contracts**
```shell
$ npm run compile
```

**Start the local sandbox node (carthage)**
```shell
$ npm run start-sandbox -- carthage
```

**Start the local sandbox node (babylon)**
```shell
$ npm run start-sandbox -- babylon
```

**Run the contract tests**
```shell
$ npm run test
```

**Clean all build artifacts**
```shell
$ npm run clean
```

## Sandbox management

Archive mode sandbox Tezos node is provided within this box with RPC exposed at port `8732` and with two accounts that are generously funded.

> You can start a sandbox with a specific protocol by passing an additional argument to the sandbox commands, e.g. `babylon` or `carthage`

#### Commands

```shell
$ npm run start-sandbox -- carthage
$ npm run kill-sandbox -- carthage
$ npm run restart-sandbox -- carthage
```

#### Available accounts
|alias  |pkh  |pk  |sk   |
|---|---|---|---|
|alice   |tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb   |edpkvGfYw3LyB1UcCahKQk4rF2tvbMUk8GFiTuMjL75uGXrpvKXhjn   |edsk3QoqBuvdamxouPhin7swCvkQNgq4jP5KZPbwWNnwdZpSpJiEbq   |
|bob   |tz1aSkwEot3L2kmUvcoxzjMomb9mvBNuzFK6   |edpkurPsQ8eUApnLUJ9ZPDvu98E8VNj4KtJa1aZr16Cr5ow5VHKnz4   |edsk3RFfvaFaxbHx8BMtEW1rKQcPtDML3LXjNqMNLCzC3wLC1bWbAt   |

## Deploying contracts

We will deploy the contracts to the sandbox as alice `address: tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb`.

**Clean all previous build artifacts**
```shell
$ npm run clean
```

**Compile the contracts**
```shell
$ npm run compile
```

**Deploy the reward proxy contract**
> Usage: `npm run deploy-reward-proxy -- <network> <contract-name> <contract-owner>`

```shell
$ npm run deploy-reward-proxy -- sandbox popm-proxy1 tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb
```

**Get contract address**
```shell
$ tezos-client list known contracts | grep popm-proxy1

Warning:

   The node you are connecting to claims to be running in a
                    Tezos TEST SANDBOX.
      Do NOT use your fundraiser keys on this network.
  You should not see this message if you are not a developer.

popm-proxy1: KT1DWNfHmEzDVHfmMGNjg4uQV4K49KmoXTQG
```

In the commands going forward, replace `KT1DWNfHmEzDVHfmMGNjg4uQV4K49KmoXTQG` with the deployed reward proxy contract address.

**Deploy the nft contract**
> Usage: `npm run deploy-nft -- <network> <contract-name> <contract-owner> <reward-proxy>`

```shell
$ npm run deploy-nft -- sandbox popm-nft1 tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb KT1DWNfHmEzDVHfmMGNjg4uQV4K49KmoXTQG
```

**Deploy the oracle contract**
> Usage: `npm run deploy-oracle -- <network> <contract-name> <contract-owner> <reward-proxy>`

```shell
$ npm run deploy-oracle -- sandbox popm-oracle1 tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb KT1DWNfHmEzDVHfmMGNjg4uQV4K49KmoXTQG
```

Now we must approve the nft and oracle contracts in the reward proxy and configure their addresses.

**Get contract addresses**
```shell
$ tezos-client list known contracts | grep popm

Warning:

   The node you are connecting to claims to be running in a
                    Tezos TEST SANDBOX.
      Do NOT use your fundraiser keys on this network.
  You should not see this message if you are not a developer.

popm-nft1: KT1X7ZE4woNDXk89kf513gwr44W8MHXDh5KG
popm-proxy1: KT1DWNfHmEzDVHfmMGNjg4uQV4K49KmoXTQG
popm-oracle1: KT1KbmpQR4njmP4ZaEGegk7G9dUH6e4pCVdS
```

In the commands going forward, use your deployed contract addresses.

**Approve NFT contract in reward proxy**
> Usage: `npm run reward-proxy-approve-contract -- <network> <proxy-contract> <contract-owner> <approved-contract>`

```shell
$ npm run reward-proxy-approve-contract -- sandbox popm-proxy1 tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb KT1X7ZE4woNDXk89kf513gwr44W8MHXDh5KG
```

**Approve oracle contract in reward proxy**
```shell
$ npm run reward-proxy-approve-contract -- sandbox popm-proxy1 tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb KT1KbmpQR4njmP4ZaEGegk7G9dUH6e4pCVdS
```

**Set NFT contract in reward proxy**
> Usage: `npm run reward-proxy-set-nft -- <network> <proxy-contract> <contract-owner> <nft-contract>`

```shell
$ npm run reward-proxy-approve-set-nft -- sandbox popm-proxy1 tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb KT1X7ZE4woNDXk89kf513gwr44W8MHXDh5KG
```

**Set oracle contract in reward proxy**
> Usage: `npm run reward-proxy-set-oracle -- <network> <proxy-contract> <contract-owner> <oracle-contract>`

```shell
$ npm run reward-proxy-approve-set-oracle -- sandbox popm-proxy1 tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb KT1KbmpQR4njmP4ZaEGegk7G9dUH6e4pCVdS
```

<br/><br/><br/>
<p align="center">
  <img width="250px" height="auto" src="https://raw.githubusercontent.com/Chain-of-Insight/pop-machine-glow/master/Documentation/assets/img/pop_machine.png">
</p>
