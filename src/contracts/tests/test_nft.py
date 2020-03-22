from os.path import dirname, join
from unittest import TestCase
import sys, hashlib
from decimal import Decimal

from pytezos import ContractInterface, pytezos, format_timestamp, MichelsonRuntimeError

# testcases
class RewardProxyTest(TestCase):

    @classmethod
    def setUpClass(cls):
        cls.nft = ContractInterface.create_from(join(dirname(__file__), '../build/nft.tz'), shell='sandboxnet')
        cls.maxDiff = None


    def test_contract_owner_can_mint_as_sender(self):
        storage = {
            "nfts": [],
            "contractOwner": "tz1WtSgQKTpHUNfXwGFKQtXfphZWkLE2FPCs",
        }

        res = self.nft \
            .mint(nftToMintId=0, nftToMint={
                "owner": "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz",
                "data": "9690bbd545bd192eb56edd1d8849f7c78ed3b238ee79b749418d20ed1aa6f5b4" }) \
            .result(storage=storage, sender="tz1WtSgQKTpHUNfXwGFKQtXfphZWkLE2FPCs", source="tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz")

        expected = {
            "contractOwner": "tz1WtSgQKTpHUNfXwGFKQtXfphZWkLE2FPCs",
            "nfts": {
                1: {
                    "owner": "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz",
                    "data": "9690bbd545bd192eb56edd1d8849f7c78ed3b238ee79b749418d20ed1aa6f5b4"
                }
            }
        }

        self.assertDictEqual(expected, res.storage)


    def test_contract_owner_cannot_mint_as_source(self):
        storage = {
            "nfts": [],
            "contractOwner": "tz1WtSgQKTpHUNfXwGFKQtXfphZWkLE2FPCs",
        }

        with self.assertRaises(MichelsonRuntimeError):
            res = self.nft \
                .mint(nftToMintId=0, nftToMint={
                    "owner": "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz",
                    "data": "9690bbd545bd192eb56edd1d8849f7c78ed3b238ee79b749418d20ed1aa6f5b4" }) \
                .result(storage=storage, sender="tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz", source="tz1WtSgQKTpHUNfXwGFKQtXfphZWkLE2FPCs")


    def test_nobody_else_can_mint(self):
        storage = {
            "nfts": [],
            "contractOwner": "tz1WtSgQKTpHUNfXwGFKQtXfphZWkLE2FPCs",
        }

        with self.assertRaises(MichelsonRuntimeError):
            res = self.nft \
                .mint(nftToMintId=0, nftToMint={
                    "owner": "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz",
                    "data": "9690bbd545bd192eb56edd1d8849f7c78ed3b238ee79b749418d20ed1aa6f5b4" }) \
                .result(storage=storage, sender="tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz", source="tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz")


    def test_mint_auto_increases_nft_id(self):
        storage = {
            "contractOwner": "KT1DfXasH5xziaqfmhyzi3cJyP8UmMjtShWQ",
            "nfts": {
                1: {
                    "owner": "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz",
                    "data": "9690bbd545bd192eb56edd1d8849f7c78ed3b238ee79b749418d20ed1aa6f5b4"
                }
            }
        }

        res = self.nft \
            .mint(nftToMintId=0, nftToMint={
                "owner": "tz1aSkwEot3L2kmUvcoxzjMomb9mvBNuzFK6",
                "data": "05070707070a000000160000bbe4aa78aa3c92543de622739ca7cb44451c52ff00010002" }) \
            .result(storage=storage, sender="KT1DfXasH5xziaqfmhyzi3cJyP8UmMjtShWQ", source="tz1aSkwEot3L2kmUvcoxzjMomb9mvBNuzFK6")

        res = self.nft \
            .mint(nftToMintId=0, nftToMint={
                "owner": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
                "data": "05070707070a0000001600005d97210b4e50c9a10e562775010af25ef30d3a6800010004" }) \
            .result(storage=res.storage, sender="KT1DfXasH5xziaqfmhyzi3cJyP8UmMjtShWQ", source="tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb")

        expected = {
            "contractOwner": "KT1DfXasH5xziaqfmhyzi3cJyP8UmMjtShWQ",
            "nfts": {
                1: {
                    "owner": "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz",
                    "data": "9690bbd545bd192eb56edd1d8849f7c78ed3b238ee79b749418d20ed1aa6f5b4"
                },
                2: {
                    "owner": "tz1aSkwEot3L2kmUvcoxzjMomb9mvBNuzFK6",
                    "data": "05070707070a000000160000bbe4aa78aa3c92543de622739ca7cb44451c52ff00010002"
                },
                3: {
                    "owner": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
                    "data": "05070707070a0000001600005d97210b4e50c9a10e562775010af25ef30d3a6800010004"
                }
            }
        }

        self.assertDictEqual(expected, res.storage)


    def test_owner_can_transfer(self):
        storage = {
            "contractOwner": "KT1DfXasH5xziaqfmhyzi3cJyP8UmMjtShWQ",
            "nfts": {
                1: {
                    "owner": "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz",
                    "data": "9690bbd545bd192eb56edd1d8849f7c78ed3b238ee79b749418d20ed1aa6f5b4"
                },
                2: {
                    "owner": "tz1aSkwEot3L2kmUvcoxzjMomb9mvBNuzFK6",
                    "data": "05070707070a000000160000bbe4aa78aa3c92543de622739ca7cb44451c52ff00010002"
                },
                3: {
                    "owner": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
                    "data": "05070707070a0000001600005d97210b4e50c9a10e562775010af25ef30d3a6800010004"
                }
            }
        }

        new_owner = "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb"

        for i in range(1, 3):
            res = self.nft \
                .transfer(nftToTransfer=i, destination=new_owner) \
                .result(storage=storage, source=storage["nfts"][i]["owner"])
            self.assertEqual(new_owner, res.storage["nfts"][i]["owner"])


    def test_nobody_else_can_transfer(self):
        storage = {
            "contractOwner": "KT1DfXasH5xziaqfmhyzi3cJyP8UmMjtShWQ",
            "nfts": {
                1: {
                    "owner": "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz",
                    "data": "9690bbd545bd192eb56edd1d8849f7c78ed3b238ee79b749418d20ed1aa6f5b4"
                },
                2: {
                    "owner": "tz1aSkwEot3L2kmUvcoxzjMomb9mvBNuzFK6",
                    "data": "05070707070a000000160000bbe4aa78aa3c92543de622739ca7cb44451c52ff00010002"
                },
                3: {
                    "owner": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
                    "data": "05070707070a0000001600005d97210b4e50c9a10e562775010af25ef30d3a6800010004"
                }
            }
        }

        new_owner = "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb"

        for i in range(1, 3):
            with self.assertRaises(MichelsonRuntimeError):
                res = self.nft \
                    .transfer(nftToTransfer=i, destination=new_owner) \
                    .result(storage=storage, source="KT1DfXasH5xziaqfmhyzi3cJyP8UmMjtShWQ")


    def test_owner_can_burn(self):
        storage = {
            "contractOwner": "KT1DfXasH5xziaqfmhyzi3cJyP8UmMjtShWQ",
            "nfts": {
                1: {
                    "owner": "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz",
                    "data": "9690bbd545bd192eb56edd1d8849f7c78ed3b238ee79b749418d20ed1aa6f5b4"
                },
                2: {
                    "owner": "tz1aSkwEot3L2kmUvcoxzjMomb9mvBNuzFK6",
                    "data": "05070707070a000000160000bbe4aa78aa3c92543de622739ca7cb44451c52ff00010002"
                },
                3: {
                    "owner": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
                    "data": "05070707070a0000001600005d97210b4e50c9a10e562775010af25ef30d3a6800010004"
                }
            }
        }

        res = self.nft \
            .burn(3) \
            .result(storage=storage, source="tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb")

        expected = {
            "contractOwner": "KT1DfXasH5xziaqfmhyzi3cJyP8UmMjtShWQ",
            "nfts": {
                1: {
                    "owner": "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz",
                    "data": "9690bbd545bd192eb56edd1d8849f7c78ed3b238ee79b749418d20ed1aa6f5b4"
                },
                2: {
                    "owner": "tz1aSkwEot3L2kmUvcoxzjMomb9mvBNuzFK6",
                    "data": "05070707070a000000160000bbe4aa78aa3c92543de622739ca7cb44451c52ff00010002"
                }
            }
        }

        self.assertDictEqual(expected, res.storage)

        res = self.nft \
            .burn(1) \
            .result(storage=res.storage, source="tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz")

        expected = {
            "contractOwner": "KT1DfXasH5xziaqfmhyzi3cJyP8UmMjtShWQ",
            "nfts": {
                2: {
                    "owner": "tz1aSkwEot3L2kmUvcoxzjMomb9mvBNuzFK6",
                    "data": "05070707070a000000160000bbe4aa78aa3c92543de622739ca7cb44451c52ff00010002"
                }
            }
        }

        self.assertDictEqual(expected, res.storage)


    def test_nobody_else_can_burn(self):
        storage = {
            "contractOwner": "KT1DfXasH5xziaqfmhyzi3cJyP8UmMjtShWQ",
            "nfts": {
                1: {
                    "owner": "tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz",
                    "data": "9690bbd545bd192eb56edd1d8849f7c78ed3b238ee79b749418d20ed1aa6f5b4"
                },
                2: {
                    "owner": "tz1aSkwEot3L2kmUvcoxzjMomb9mvBNuzFK6",
                    "data": "05070707070a000000160000bbe4aa78aa3c92543de622739ca7cb44451c52ff00010002"
                },
                3: {
                    "owner": "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb",
                    "data": "05070707070a0000001600005d97210b4e50c9a10e562775010af25ef30d3a6800010004"
                }
            }
        }

        for i in range(1, 3):
            with self.assertRaises(MichelsonRuntimeError):
                res = self.nft \
                    .burn(i) \
                    .result(storage=storage, source="KT1DfXasH5xziaqfmhyzi3cJyP8UmMjtShWQ")
