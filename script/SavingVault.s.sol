// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {SavingsVault} from "../src/SaveVault.sol";
import {Script} from "forge-std/Script.sol";

contract SavingVaultScript is Script {
    SavingsVault public savingVault;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        savingVault = new SavingsVault();

        vm.stopBroadcast();
    }
}



