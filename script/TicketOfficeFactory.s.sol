// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script, console } from "forge-std/Script.sol";
import { TicketOfficeFactory } from "../src/TicketOfficeFactory.sol";
import { EventContract } from "../src/EventContract.sol";

contract TicketOfficeFactoryDeploy is Script {
    address constant USDC_MAINNET = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant USDC_SEPOLIA = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238;
    
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Get USDC address based on chain
        address usdcAddress;
        if (block.chainid == 1) {
            usdcAddress = USDC_MAINNET;
        } else if (block.chainid == 11155111) {
            usdcAddress = USDC_SEPOLIA;
        } else {
            // For local testing, deploy a mock USDC
            revert("Unsupported chain");
        }

        console.log("Deploying TicketOfficeFactory on chain:", block.chainid);
        console.log("Using USDC address:", usdcAddress);
        
        TicketOfficeFactory factory = new TicketOfficeFactory(usdcAddress);
        
        console.log("TicketOfficeFactory deployed at:", address(factory));
        console.log("Factory owner:", factory.contractOwner());
        console.log("Office open:", factory.isOpen());

        vm.stopBroadcast();
    }
}