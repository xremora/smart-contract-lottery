# Lottery contract

## adding mainnet fork

### list of networks

`brownie networks list`

`brownie networks add development mainnet-fork cmd=ganache-cli host=http://127.0.0.1 fork=https://eth-mainnet.alchemyapi.io/v2/asdfasdfs accounts=10 mnemonic=brownie port=8545`

`brownie test --network mainnet-fork`

## Test in rinkeby network

```bash
brownie test -k test_can_pick_winner --network rinkeby -s
```
