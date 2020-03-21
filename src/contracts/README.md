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

<br/><br/><br/>
<p align="center">
  <img width="250px" height="auto" src="https://raw.githubusercontent.com/Chain-of-Insight/pop-machine-glow/master/Documentation/assets/img/pop_machine.png">
</p>