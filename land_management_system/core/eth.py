# core/eth.py
from web3 import Web3
import os
from dotenv import load_dotenv
import logging

# Load environment variables
load_dotenv()
logging.basicConfig(
    level=logging.DEBUG, format="%(asctime)s - %(levelname)s - %(message)s"
)

INFURA_URL = os.getenv("INFURA_URL")

web3 = Web3(Web3.HTTPProvider(INFURA_URL))

if web3.is_connected():
    logging.info("Connected to the Ethereum network via Infura.")
else:
    logging.error("Unable to connect to the Ethereum network via Infura.")
