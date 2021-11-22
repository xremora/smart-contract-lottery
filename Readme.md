# Lottery contract

## adding mainnet fork

### list of networks

`brownie networks list`

`brownie networks add development mainnet-fork cmd=ganache-cli host=http://127.0.0.1 fork=https://eth-mainnet.alchemyapi.io/v2/1jqF0mvR0Dl3pcHS2fjtecW1sopg8lb0 accounts=10 mnemonic=brownie port=8545`

`brownie test --network mainnet-fork`
