import json
from django.http import JsonResponse
from django.shortcuts import render
from web3 import Web3
import ipfshttpclient
import requests
import os
from dotenv import load_dotenv
from core.models import *
from moralis import evm_api
from django.contrib.auth.decorators import login_required
from core.views import api_key

# Load the environment variables from the .env file
load_dotenv()

# Accessing the environment variables
contract_owner_private_key = os.getenv("CONTRACT_OWNER_PRIVATE_KEY")
contract_owner_address = os.getenv("CONTRACT_OWNER_ADDRESS")
pinata_api_key = os.getenv("PINATA_API_KEY")


# Connect to the Sepolia network
web3 = Web3(
    Web3.HTTPProvider("https://sepolia.infura.io/v3/f355980e6f754a008580551756be21fc")
)

# Check connection
print("Connected:", web3.isConnected())

contract_address = "0x7Ac3E878727211328EcfE4D5eecFd8C9Fe3D2089"
# Path to your ABI file
abi_path = "D:\\University\\FYP\\final_project\\LandManagementABI.json"

# Load the ABI
with open(abi_path, "r") as abi_file:
    abi = json.load(abi_file)

# Now you can use the 'abi' variable to interact with your contract
contract = web3.eth.contract(address=contract_address, abi=abi)


def transfer_nft(user, receiver_wallet_address, token_id):
    txn = contract.functions.transferFrom(
        user.wallet_address, receiver_wallet_address, token_id
    ).buildTransaction(
        {
            "chainId": web3.eth.chain_id,
            "gas": 2000000,
            "nonce": web3.eth.getTransactionCount(contract_owner_address),
        }
    )
    # Sign the transaction with the user's private key (ensure security)
    signed_txn = web3.eth.account.signTransaction(txn, private_key="USER_PRIVATE_KEY")
    result = web3.eth.sendRawTransaction(signed_txn.rawTransaction)
    return result.hex()


def upload_to_pinata(json_metadata):
    url = "https://api.pinata.cloud/pinning/pinJSONToIPFS"
    headers = {
        "Authorization": f"Bearer {os.getenv('PINATA_API_KEY')}",
        "Content-Type": "application/json",
    }
    response = requests.post(url, json=json_metadata, headers=headers)
    if response.status_code == 200:
        ipfs_hash = response.json()["IpfsHash"]
        return f"ipfs://{ipfs_hash}"
    else:
        raise Exception("Failed to upload to Pinata")


def update_metadata(token_id, new_metadata):
    new_uri = upload_to_pinata(new_metadata)

    txn = contract.functions.updateTokenURI(token_id, new_uri).buildTransaction(
        {
            "chainId": web3.eth.chain_id,
            "gas": 2000000,
            "nonce": web3.eth.getTransactionCount(contract_owner_address),
        }
    )
    signed_txn = web3.eth.account.signTransaction(
        txn, private_key=contract_owner_private_key
    )
    result = web3.eth.sendRawTransaction(signed_txn.rawTransaction)
    return result.hex()


def update_metadata_from_request(request, land_id, new_owner_wallet):
    try:
        # Assuming `get_metadata_for_land` fetches metadata from your model or IPFS directly
        metadata = get_metadata_for_land(land_id)
        metadata["attributes"][0]["value"] = get_cnic_from_wallet(
            new_owner_wallet
        )  # Update CNIC
        new_uri = upload_to_pinata(metadata)  # Upload updated metadata to Pinata

        # Update the tokenURI on the blockchain
        txn_hash = update_token_uri_on_chain(land_id, new_uri)
        return JsonResponse({"status": "success", "txn_hash": txn_hash})
    except Exception as e:
        return JsonResponse({"status": "error", "message": str(e)})


def get_cnic_from_wallet(wallet_address):
    try:
        user = User.objects.get(wallet_address=wallet_address)
        return user.cnic
    except User.DoesNotExist:
        raise ValueError("No user found with the given wallet address")


def upload_to_pinata(metadata):
    url = "https://api.pinata.cloud/pinning/pinJSONToIPFS"
    headers = {
        "Authorization": f"Bearer {os.getenv('PINATA_API_KEY')}",  # Ensure your API key is correctly configured
        "Content-Type": "application/json",
    }
    response = requests.post(url, json=metadata, headers=headers)
    if response.status_code == 200:
        ipfs_hash = response.json()["IpfsHash"]
        return f"ipfs://{ipfs_hash}"
    else:
        raise Exception("Failed to upload to Pinata: " + response.text)


def update_metadata(request, land_id, new_owner_wallet):
    try:
        nft = NFT.objects.get(land__id=land_id)
        old_metadata = requests.get(
            nft.metadata_url
        ).json()  # Fetching existing metadata from IPFS
        old_metadata["attributes"][0]["value"] = get_cnic_from_wallet(
            new_owner_wallet
        )  # Update CNIC

        new_uri = upload_to_pinata(old_metadata)  # Upload updated metadata to Pinata

        # Update the tokenURI on the blockchain (not shown here, would require web3.py interaction)
        txn_hash = update_token_uri_on_chain(nft.token_id, new_uri)

        # Optionally update the metadata URL in the NFT model
        nft.metadata_url = new_uri
        nft.save()

        return JsonResponse(
            {"status": "success", "txn_hash": txn_hash, "new_metadata_url": new_uri}
        )
    except Exception as e:
        return JsonResponse({"status": "error", "message": str(e)})


def get_metadata_for_land(land_id):
    try:
        nft = NFT.objects.get(land__id=land_id)
        response = requests.get(nft.metadata_url)
        if response.status_code == 200:
            return response.json()
        else:
            raise Exception("Failed to fetch metadata from IPFS.")
    except NFT.DoesNotExist:
        raise ValueError("No NFT found for the given land ID")


def update_token_uri_on_chain(token_id, new_uri):
    contract = web3.eth.contract(address=contract_address, abi=abi)
    txn = contract.functions.updateTokenURI(token_id, new_uri).buildTransaction(
        {
            "from": contract_owner_address,
            "chainId": web3.eth.chain_id,
            "gas": 2000000,
            "nonce": web3.eth.getTransactionCount(contract_owner_address),
        }
    )
    signed_txn = web3.eth.account.signTransaction(
        txn, private_key=contract_owner_private_key
    )
    result = web3.eth.sendRawTransaction(signed_txn.rawTransaction)
    return result.hex()


def fetch_metadata(request, land_id):
    try:
        metadata = get_metadata_for_land(land_id)
        return JsonResponse({"status": "success", "metadata": metadata})
    except Exception as e:
        return JsonResponse({"status": "error", "message": str(e)})


def check_wallet_connection(request):
    connected = web3.isConnected()
    return JsonResponse({"connected": connected})


@login_required
def get_user_nfts(request):
    user = request.user
    if not user.wallet_address:
        return JsonResponse(
            {"error": "Wallet address not found for the user"}, status=404
        )

    try:
        api_key = api_key
        chain = "sepolia"  # Adjust the chain as necessary
        response = evm_api.nft.get_wallet_nfts(
            api_key=api_key,
            params={
                "address": user.wallet_address,
                "chain": chain,
                "format": "decimal",
                "limit": 100,
                "token_addresses": [],
                "normalizeMetadata": True,
            },
        )
        nfts = response.json()
        return JsonResponse(nfts)
    except User.DoesNotExist:
        return JsonResponse({"error": "User not found."}, status=404)


@login_required
def get_nft_by_land_details(request, tehsil, khasra_number, division):
    user = request.user
    if not user.wallet_address:
        return JsonResponse(
            {"error": "Wallet address not found for the user"}, status=404
        )

    try:
        api_key = api_key
        chain = "sepolia"  # Adjust as necessary
        response = evm_api.nft.get_wallet_nfts(
            api_key=api_key,
            params={
                "address": user.wallet_address,
                "chain": chain,
                "format": "decimal",
                "limit": 100,
                "token_addresses": [],
                "normalizeMetadata": True,
            },
        )
        nfts = response.json()

        for nft in nfts.get(
            "data", []
        ):  # Adjust depending on the structure of response
            if (
                nft.get("metadata", {}).get("tehsil") == tehsil
                and nft.get("metadata", {}).get("khasra_number") == khasra_number
                and nft.get("metadata", {}).get("division") == division
            ):
                return JsonResponse(nft)  # Return the matching NFT

        return JsonResponse({"error": "No matching NFT found"}, status=404)
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=500)
