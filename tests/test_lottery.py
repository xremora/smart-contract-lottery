from brownie import Lottery, accounts, network, config
from web3 import Web3


def test_get_entrace_fee():
    account = accounts[0]
    print("account", account)
    lottery = Lottery.deploy(
        config["networks"][network.show_active()]["eth_usd_price_feed"],
        {"from": account},
    )
    # assert lottery.getEntranceFee() > Web3.toWei(0.019, "ether")
