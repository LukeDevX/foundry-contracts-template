// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {console} from "forge-std/console.sol";
import {Script} from "forge-std/Script.sol";
import "../../src/KNSToken.sol";

contract TellerDeploy is Script {
    KNSToken public kns_token1;

    function setUp() public {}

    function getChainID() public view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }

    function run() public {
        vm.startBroadcast();
        uint256 chainId = getChainID();
        console.log("chain id: ", chainId);
        console.log("Deployer: ", msg.sender);

        kns_token1 = new KNSToken(msg.sender, "knstoken1", "kns1");

        // polygon usdc address: 0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359
        // Arbitrum usdc address: 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8


        console.log("1. kns_token1 deployed at: ", address(kns_token1));
    }
}
