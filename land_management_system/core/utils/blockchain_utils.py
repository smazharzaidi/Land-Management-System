import json
import os
import logging
import requests
from web3 import Web3
from dotenv import load_dotenv
import web3
import pdb
from web3.datastructures import AttributeDict

load_dotenv()
logging.basicConfig(
    level=logging.DEBUG, format="%(asctime)s - %(levelname)s - %(message)s"
)

CONTRACT_OWNER_PRIVATE_KEY = os.getenv("CONTRACT_OWNER_PRIVATE_KEY")
CONTRACT_OWNER_ADDRESS = os.getenv("CONTRACT_OWNER_ADDRESS")
INFURA_URL = os.getenv("INFURA_URL")
CONTRACT_ADDRESS = os.getenv("CONTRACT_ADDRESS")
ABI_PATH = os.getenv("ABI_PATH")
PINATA_JWT = os.getenv("PINATA_JWT")


def validate_env_vars():
    if not all(
        [
            CONTRACT_OWNER_PRIVATE_KEY,
            CONTRACT_OWNER_ADDRESS,
            INFURA_URL,
            CONTRACT_ADDRESS,
            ABI_PATH,
        ]
    ):
        raise EnvironmentError("Missing one or more required environment variables.")

    return {
        "CONTRACT_OWNER_PRIVATE_KEY": CONTRACT_OWNER_PRIVATE_KEY.strip(),
        "CONTRACT_OWNER_ADDRESS": Web3.to_checksum_address(
            CONTRACT_OWNER_ADDRESS.strip()
        ),
        "INFURA_URL": INFURA_URL.strip(),
        "CONTRACT_ADDRESS": Web3.to_checksum_address(CONTRACT_ADDRESS.strip()),
        "ABI_PATH": ABI_PATH.strip(),
    }


env_vars = validate_env_vars()
CONTRACT_OWNER_PRIVATE_KEY = env_vars["CONTRACT_OWNER_PRIVATE_KEY"]
CONTRACT_OWNER_ADDRESS = env_vars["CONTRACT_OWNER_ADDRESS"]
INFURA_URL = env_vars["INFURA_URL"]
CONTRACT_ADDRESS = env_vars["CONTRACT_ADDRESS"]
ABI_PATH = env_vars["ABI_PATH"]


def connect_to_blockchain():
    """Connect to the Ethereum blockchain"""
    try:
        with open(ABI_PATH, "r") as file:
            abi = json.load(file)
        web3 = Web3(Web3.HTTPProvider(INFURA_URL))
        if not web3.is_connected():
            logging.error("Failed to connect to Infura")
            raise ConnectionError("Failed to connect to Infura")
        logging.info("Successfully connected to blockchain via Infura")
        return web3, web3.eth.contract(address=CONTRACT_ADDRESS, abi=abi)
    except Exception as e:
        logging.error(f"Error connecting to blockchain: {e}")
        raise


def hexbytes_to_str(value):
    """Recursively convert HexBytes to string in transaction receipts"""
    if isinstance(value, bytes):
        return value.hex()
    elif isinstance(value, list):
        return [hexbytes_to_str(v) for v in value]
    elif isinstance(value, dict):
        return {k: hexbytes_to_str(v) for k, v in value.items()}
    elif isinstance(value, AttributeDict):
        return {k: hexbytes_to_str(v) for k, v in value.items()}
    return value


def transfer_nft(web3, contract, from_address, to_address, token_id):
    """Transfer an NFT from one address to another"""
    try:
        pdb.set_trace()
        from_address = Web3.to_checksum_address(from_address)
        to_address = Web3.to_checksum_address(to_address)

        logging.debug(
            f"Using checksummed addresses - From: {from_address}, To: {to_address}"
        )

        nonce = web3.eth.get_transaction_count(from_address)

        transaction = contract.functions.safeTransferFrom(
            from_address, to_address, token_id
        ).build_transaction(
            {
                "chainId": 11155111,
                "gas": 200000,
                "gasPrice": web3.to_wei("10", "gwei"),
                "nonce": nonce,
            }
        )
        logging.debug(f"Transaction: {transaction}")

        HARD_CODED_PRIVATE_KEY = (
            "197e7743669467b88003de5b46d64b9cfcb5edc34d206eda2859300a1dfa38e3"
        )

        masked_private_key = (
            f"{HARD_CODED_PRIVATE_KEY[:5]}...{HARD_CODED_PRIVATE_KEY[-5:]}"
        )
        logging.debug(f"Contract Owner Private Key (Masked): {masked_private_key}")
        logging.debug(f"Private Key Length: {len(HARD_CODED_PRIVATE_KEY)}")

        signed_tx = web3.eth.account.sign_transaction(
            transaction, HARD_CODED_PRIVATE_KEY
        )
        logging.debug(f"Signed transaction: {signed_tx}")

        tx_hash = web3.eth.send_raw_transaction(signed_tx.rawTransaction)
        receipt = web3.eth.wait_for_transaction_receipt(tx_hash)
        logging.info(f"Transfer successful. Transaction receipt: {receipt}")
        return hexbytes_to_str(receipt)
    except Exception as e:
        logging.error(f"Error transferring NFT: {e}")
        raise


def fetch_metadata(token_uri):
    """Fetch existing metadata from the URI"""
    try:
        pdb.set_trace()  # Set a breakpoint here for debugging
        response = requests.get(token_uri)
        if response.status_code == 200:
            logging.info(f"Fetched metadata from {token_uri}")
            return response.json()
        logging.warning(
            f"Failed to fetch metadata from {token_uri}: {response.status_code}"
        )
        return None
    except Exception as e:
        logging.error(f"Error fetching metadata: {e}")
        raise


def upload_to_pinata(metadata):
    """Upload metadata to Pinata and return the new IPFS URI"""
    try:
        pdb.set_trace()  # Set a breakpoint here for debugging
        url = "https://api.pinata.cloud/pinning/pinJSONToIPFS"
        headers = {
            "Authorization": f"Bearer {PINATA_JWT}",
            "Content-Type": "application/json",
        }
        response = requests.post(url, headers=headers, json=metadata)
        if response.status_code == 200:
            ipfs_hash = response.json()["IpfsHash"]
            logging.info(
                f"Successfully uploaded metadata to Pinata. IPFS Hash: {ipfs_hash}"
            )
            return f"ipfs://{response.json()['IpfsHash']}"
        logging.warning(f"Pinata Error: {response.status_code} - {response.text}")
        raise Exception(f"Pinata Error: {response.text}")
    except Exception as e:
        logging.error(f"Error uploading to Pinata: {e}")
        raise


def update_nft_metadata(contract, token_id, new_cnic, tehsil, khasra, division):
    """Update the CNIC attribute in the metadata and return the new URI"""
    try:
        pdb.set_trace()  # Set a breakpoint here for debugging
        token_uri = contract.functions.tokenURI(token_id).call()
        metadata = fetch_metadata(token_uri)
        if not metadata:
            logging.error("Unable to fetch existing metadata")
            raise Exception("Unable to fetch existing metadata")

        for attribute in metadata["attributes"]:
            if attribute["trait_type"] == "CNIC":
                attribute["value"] = new_cnic

        for attribute in metadata["attributes"]:
            if attribute["trait_type"] == "Tehsil":
                attribute["value"] = tehsil
            elif attribute["trait_type"] == "Khasra Number":
                attribute["value"] = khasra
            elif attribute["trait_type"] == "Division":
                attribute["value"] = division

        new_uri = upload_to_pinata(metadata)
        tx_hash = contract.functions.updateTokenURI(token_id, new_uri).transact(
            {"from": CONTRACT_OWNER_ADDRESS}
        )
        logging.info(f"Updating token URI to {new_uri}")
        receipt = web3.eth.wait_for_transaction_receipt(tx_hash)
        logging.info(f"Token URI update transaction receipt: {receipt}")
        return new_uri
    except Exception as e:
        logging.error(f"Error updating NFT metadata: {e}")
        raise
