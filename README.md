## Foundry-CONTRACTS-TEMPLATE

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**
Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Update .env

`cp .env.template .env`

### Build

```shell
$ forge build
$ make build
```

### Test

```shell
$ forge test
$ make test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Cast

```shell
$ cast <subcommand>
```

### Flatten

```shell
$ make flatten
```

### Extract ABIs

```shell
$ make abi
```

### Coverage Summary

Generate a summary of test coverage, excluding mocks and script directories.  

```shell
$ make cov_summary
```

### Full Coverage Report

Clean previous reports, generate an lcov coverage file, and convert it into an HTML report using genhtml.  

```shell
$ make cov_report
```

### Start Anvil (Local Fork Node)

Start a local Anvil node that forks mainnet at the specified RPC and port.

```shell
$ make anvil_start
```

### Fund Account on Anvil

Set the test ETH balance of a local account in Anvil.

```shell
$ make anvil_fund
```

### Clean

```shell
$ make clean
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

Used to batch execute all script files ending with `.s.sol` in the `script/` directory for contract deployment.  
**Supported networks**: `mainnet`, `bsc`, `polygon`, `arbitrum`, `optimism`, `sepolia`, `bsc_testnet`, `local`.

```shell
$ make deploy network=sepolia
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
