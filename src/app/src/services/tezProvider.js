import { TezBridgeSigner } from '@taquito/tezbridge-signer';
import { Tezos } from '@taquito/taquito';

const mountProvider = function () {
  Tezos.setProvider({
    rpc: process.env.TESTNET,
    signer: new TezBridgeSigner()
  });

  console.log('Tezos =>', Tezos);
};

const getBalance = async (address) => {
  let worker = await Tezos.tz.getBalance(address);
  return worker;
};

const getContractInstance = async (contract) => {
  let contractInstance = await Tezos.contract.at(contract);
  return contractInstance;
};

module.exports = {
  Tezos: Tezos,
  mountProvider: mountProvider,
  getBalance: getBalance,
  getContractInstance: getContractInstance
};