// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/console.sol";
import {Script} from "forge-std/Script.sol";
import {Counter} from "../src/Counter.sol";

contract CounterScript is Script {
    Counter public counter;

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

        counter = new Counter();

        vm.stopBroadcast();
        console.log("counter deployed at: ", address(counter));
    }
}
