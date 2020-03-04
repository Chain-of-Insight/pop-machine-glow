from os.path import dirname, join
from unittest import TestCase
import sys, hashlib

from pytezos import ContractInterface, pytezos, format_timestamp, MichelsonRuntimeError

# Helper functions for proof tests
def hashman(b):
    h = hashlib.blake2b(digest_size=32)
    h.update(b)
    return h.digest()

def generate_proof(message, depth):
    prefix = b'\x05\x01'
    len_bytes = (len(message)).to_bytes(4, byteorder='big')
    b = bytearray()
    b.extend(message.encode())
    proof = prefix + len_bytes + b
    for i in range(0, depth):
        proof = hashman(proof)
    return proof.hex()


# testcases
class OracleTest(TestCase):

    @classmethod
    def setUpClass(cls):
        cls.oracle = ContractInterface.create_from(join(dirname(__file__), 'build/oracle.tz'))


    def test_create_new_blank(self):
        res = self.oracle \
            .create(id=1583093350498, rewards=10, rewards_h='7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e') \
            .result(storage={}, sender="tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb")

        expected = {1583093350498: {'author': 'tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb',
                        'claimed': 0,
                        'id': 1583093350498,
                        'rewards': 10,
                        'rewards_h': '7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e'}}
        self.assertDictEqual(expected, res.storage)


    def test_create_existing(self):
        storage = {1583093350498: {'author': 'tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb',
                        'claimed': 0,
                        'id': 1583093350498,
                        'rewards': 10,
                        'rewards_h': '7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e'}}
        with self.assertRaises(MichelsonRuntimeError):
            res = self.oracle \
                .create(id=1583093350498, rewards=10, rewards_h='7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e') \
                .result(storage=storage, sender="tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb")


    def test_create_new_append(self):
        storage = {1583093350498: {'author': 'tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb',
                        'claimed': 0,
                        'id': 1583093350498,
                        'rewards': 10,
                        'rewards_h': '7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e'}}
        res = self.oracle \
            .create(id=1583258505553, rewards=5, rewards_h='7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e') \
            .result(storage=storage, sender="tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb")
        expected = {'author': 'tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb',
                    'claimed': 0,
                    'id': 1583258505553,
                    'rewards': 5,
                    'rewards_h': '7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e'}
        self.assertDictEqual(expected, res.storage[1583258505553])


    def test_can_update_own_puzzle(self):
        storage = {1583093350498: {'author': 'tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb',
                        'claimed': 0,
                        'id': 1583093350498,
                        'rewards': 10,
                        'rewards_h': '7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e'}}
        res = self.oracle \
            .update(id=1583093350498, rewards=5, rewards_h='6b2c38e3a7d1bbca95cd302d03d77c1c0c90085f229f35caa0914d7dcd1b44b4') \
            .result(storage=storage, sender="tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb")
        expected = {'author': 'tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb',
                    'claimed': 0,
                    'id': 1583093350498,
                    'rewards': 5,
                    'rewards_h': '6b2c38e3a7d1bbca95cd302d03d77c1c0c90085f229f35caa0914d7dcd1b44b4'}
        self.assertDictEqual(expected, res.storage[1583093350498])


    def test_cannot_update_others_puzzle(self):
        storage = {1583093350498: {'author': 'tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz',
                        'claimed': 0,
                        'id': 1583093350498,
                        'rewards': 10,
                        'rewards_h': '7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e'}}
        with self.assertRaises(MichelsonRuntimeError):
            res = self.oracle \
                .update(id=1583093350498, rewards=5, rewards_h='6b2c38e3a7d1bbca95cd302d03d77c1c0c90085f229f35caa0914d7dcd1b44b4') \
                .result(storage=storage, sender="tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb")


    def test_cannot_update_already_claimed(self):
        storage = {1583093350498: {'author': 'tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb',
                        'claimed': 1,
                        'id': 1583093350498,
                        'rewards': 10,
                        'rewards_h': '7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e'}}
        with self.assertRaises(MichelsonRuntimeError):
            res = self.oracle \
                .update(id=1583093350498, rewards=5, rewards_h='6b2c38e3a7d1bbca95cd302d03d77c1c0c90085f229f35caa0914d7dcd1b44b4') \
                .result(storage=storage, sender="tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb")


    def test_cannot_solve_invalid_puzzle(self):
        with self.assertRaises(MichelsonRuntimeError):
            res = self.oracle \
                .solve(id=1583093350498, proof='7b15bb3dee5f8891f60cd181ff424012548a9ed5e26721eb9f6518e9dd409d9e') \
                .result(storage={}, sender="tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb")


    def test_can_be_the_1st_solver(self):
        solution = "identify gentle hazard impact boy say rotate fame robot hole dog economy"
        storage = {1583093350498: {
            'id': 1583093350498,
            'author': 'tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb',
            'claimed': 0,
            'rewards': 10,
            'rewards_h': generate_proof(solution, 11) # rewards_h = HASH^rewards+1(Solution)
        }}
        proof = generate_proof(solution, 10)
        res = self.oracle \
            .solve(id=1583093350498, proof=proof) \
            .result(storage=storage, sender="tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz")
        self.assertEqual(1, res.storage[1583093350498]['claimed'])


    def test_can_only_be_one_1st_solver(self):
        solution = "identify gentle hazard impact boy say rotate fame robot hole dog economy"
        storage = {1583093350498: {
            'id': 1583093350498,
            'author': 'tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb',
            'claimed': 1,
            'rewards': 10,
            'rewards_h': generate_proof(solution, 11) # rewards_h = HASH^rewards+1(Solution)
        }}
        proof = generate_proof(solution, 10)
        with self.assertRaises(MichelsonRuntimeError):
            res = self.oracle \
                .solve(id=1583093350498, proof=proof) \
                .result(storage=storage, sender="tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz")


    def test_can_be_2nd_solver(self):
        solution = "identify gentle hazard impact boy say rotate fame robot hole dog economy"
        storage = {1583093350498: {
            'id': 1583093350498,
            'author': 'tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb',
            'claimed': 1,
            'rewards': 10,
            'rewards_h': generate_proof(solution, 11) # rewards_h = HASH^rewards+1(Solution)
        }}
        proof = generate_proof(solution, 9)
        res = self.oracle \
            .solve(id=1583093350498, proof=proof) \
            .result(storage=storage, sender="tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz")
        self.assertEqual(2, res.storage[1583093350498]['claimed'])


    def test_can_only_be_one_2nd_solver(self):
        solution = "identify gentle hazard impact boy say rotate fame robot hole dog economy"
        storage = {1583093350498: {
            'id': 1583093350498,
            'author': 'tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb',
            'claimed': 2,
            'rewards': 10,
            'rewards_h': generate_proof(solution, 11) # rewards_h = HASH^rewards+1(Solution)
        }}
        proof = generate_proof(solution, 9)
        with self.assertRaises(MichelsonRuntimeError):
            res = self.oracle \
                .solve(id=1583093350498, proof=proof) \
                .result(storage=storage, sender="tz1cmWyycuCBdHVHVCnXbRLdKfjNSesRPJyz")
