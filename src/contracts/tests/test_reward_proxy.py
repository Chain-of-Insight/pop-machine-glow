from os.path import dirname, join
from unittest import TestCase
import sys, hashlib
from decimal import Decimal

from pytezos import ContractInterface, pytezos, format_timestamp, MichelsonRuntimeError

# testcases
class RewardProxyTest(TestCase):

    @classmethod
    def setUpClass(cls):
        cls.proxy = ContractInterface.create_from(join(dirname(__file__), '../build/reward_proxy.tz'), shell='sandboxnet')
        cls.maxDiff = None


    def test_source_can_approve(self):
        storage = {
            "trustedContracts": [],
            "contractOwner": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "contractOracle": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "contractNft": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "deposits": {}
        }
        res = self.proxy \
            .approveContract('KT1JepfBfMSqkQyf9B1ndvURghGsSB8YCLMD') \
            .result(storage=storage, source="tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb")

        expected = {
            "trustedContracts": [ "KT1JepfBfMSqkQyf9B1ndvURghGsSB8YCLMD" ],
            "contractOwner": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "contractOracle": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "contractNft": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "deposits": {}
        }
        self.assertDictEqual(expected, res.storage)


    def test_anyone_cannot_approve(self):
        storage = {
            "trustedContracts": [],
            "contractOwner": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "contractOracle": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "contractNft": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "deposits": {}
        }
        with self.assertRaises(MichelsonRuntimeError):
            res = self.proxy \
                .approveContract('KT1JepfBfMSqkQyf9B1ndvURghGsSB8YCLMD') \
                .result(storage=storage, sender="tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb", source="tz1WtSgQKTpHUNfXwGFKQtXfphZWkLE2FPCs")

    def test_approve_multiple(self):
        storage = {
            "trustedContracts": [ "KT1RUT25eGgo9KKWXfLhj1xYjghAY1iZ2don" ],
            "contractOwner": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "contractOracle": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "contractNft": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "deposits": {}
        }
        res = self.proxy \
            .approveContract('KT1JepfBfMSqkQyf9B1ndvURghGsSB8YCLMD') \
            .result(storage=storage, source="tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb")

        expected = {
            "trustedContracts": [ "KT1JepfBfMSqkQyf9B1ndvURghGsSB8YCLMD", "KT1RUT25eGgo9KKWXfLhj1xYjghAY1iZ2don" ],
            "contractOwner": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "contractOracle": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "contractNft": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "deposits": {}
        }
        self.assertDictEqual(expected, res.storage)


    def test_add_initial_deposit(self):
        storage = {
            "trustedContracts": [ "KT1RUT25eGgo9KKWXfLhj1xYjghAY1iZ2don" ],
            "contractOwner": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "contractOracle": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "contractNft": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "deposits": {}
        }
        res = self.proxy \
            .addDeposit(puzzle_id=1583093350498, claim=1) \
            .with_amount(100000) \
            .result(storage=storage, source="tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb")

        expected = {
            "trustedContracts": [ "KT1RUT25eGgo9KKWXfLhj1xYjghAY1iZ2don" ],
            "contractOwner": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "contractOracle": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "contractNft": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "deposits": {1583093350498: {1: Decimal('0.1')}}
        }
        self.assertDictEqual(expected, res.storage)


    def test_add_subsequent_deposit(self):
        storage = {
            "trustedContracts": [ "KT1RUT25eGgo9KKWXfLhj1xYjghAY1iZ2don" ],
            "contractOwner": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "contractOracle": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "contractNft": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "deposits": {1583093350498: {1: Decimal('0.1')}}
        }
        res = self.proxy \
            .addDeposit(puzzle_id=1583093350498, claim=1) \
            .with_amount(200000) \
            .result(storage=storage, source="tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb")

        expected = {
            "trustedContracts": [ "KT1RUT25eGgo9KKWXfLhj1xYjghAY1iZ2don" ],
            "contractOwner": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "contractOracle": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "contractNft": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "deposits": {1583093350498: {1: Decimal('0.3')}}
        }
        self.assertDictEqual(expected, res.storage)


    def test_add_deposit_multiple_puzzle(self):
        storage = {
            "trustedContracts": [ "KT1RUT25eGgo9KKWXfLhj1xYjghAY1iZ2don" ],
            "contractOwner": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "contractOracle": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "contractNft": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "deposits": {1583093350498: {1: Decimal('0.1')}}
        }
        res = self.proxy \
            .addDeposit(puzzle_id=1583258505553, claim=1) \
            .with_amount(1500000) \
            .result(storage=storage, source="tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb")

        expected = {
            "trustedContracts": [ "KT1RUT25eGgo9KKWXfLhj1xYjghAY1iZ2don" ],
            "contractOwner": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "contractOracle": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "contractNft": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "deposits": {
                1583093350498: {1: Decimal('0.1')},
                1583258505553: {1: Decimal('1.5')}
            }
        }
        self.assertDictEqual(expected, res.storage)


    def test_add_deposit_multiple_claim(self):
        storage = {
            "trustedContracts": [ "KT1RUT25eGgo9KKWXfLhj1xYjghAY1iZ2don" ],
            "contractOwner": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "contractOracle": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "contractNft": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "deposits": {1583093350498: {1: Decimal('0.1')}}
        }
        res = self.proxy \
            .addDeposit(puzzle_id=1583093350498, claim=2) \
            .with_amount(50000) \
            .result(storage=storage, source="tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb")

        expected = {
            "trustedContracts": [ "KT1RUT25eGgo9KKWXfLhj1xYjghAY1iZ2don" ],
            "contractOwner": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "contractOracle": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "contractNft": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "deposits": {
                1583093350498: {1: Decimal('0.1'), 2: Decimal('0.05')}
            }
        }
        self.assertDictEqual(expected, res.storage)


    def test_source_can_set_trusted_oracle(self):
        storage = {
            "trustedContracts": [ "KT1JepfBfMSqkQyf9B1ndvURghGsSB8YCLMD" ],
            "contractOwner": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "contractOracle": "KT1RUT25eGgo9KKWXfLhj1xYjghAY1iZ2don",
            "contractNft": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "deposits": {}
        }
        res = self.proxy \
            .setOracle('KT1JepfBfMSqkQyf9B1ndvURghGsSB8YCLMD') \
            .result(storage=storage, source="tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb")

        expected = {
            "trustedContracts": [ "KT1JepfBfMSqkQyf9B1ndvURghGsSB8YCLMD" ],
            "contractOwner": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "contractOracle": "KT1JepfBfMSqkQyf9B1ndvURghGsSB8YCLMD",
            "contractNft": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "deposits": {}
        }
        self.assertDictEqual(expected, res.storage)


    def test_source_cannot_set_untrusted_oracle(self):
        storage = {
            "trustedContracts": [ "KT1RUT25eGgo9KKWXfLhj1xYjghAY1iZ2don" ],
            "contractOwner": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "contractOracle": "KT1RUT25eGgo9KKWXfLhj1xYjghAY1iZ2don",
            "contractNft": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "deposits": {}
        }

        with self.assertRaises(MichelsonRuntimeError):
            res = self.proxy \
                .setOracle('KT1JepfBfMSqkQyf9B1ndvURghGsSB8YCLMD') \
                .result(storage=storage, source="tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb")


    def test_anyone_cannot_set_oracle(self):
        storage = {
            "trustedContracts": [ "KT1JepfBfMSqkQyf9B1ndvURghGsSB8YCLMD" ],
            "contractOwner": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "contractOracle": "KT1RUT25eGgo9KKWXfLhj1xYjghAY1iZ2don",
            "contractNft": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
            "deposits": {}
        }
        with self.assertRaises(MichelsonRuntimeError):
            res = self.proxy \
                .setOracle('KT1JepfBfMSqkQyf9B1ndvURghGsSB8YCLMD') \
                .result(storage=storage, sender="tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb", source="tz1WtSgQKTpHUNfXwGFKQtXfphZWkLE2FPCs")
