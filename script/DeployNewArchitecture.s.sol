// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { TicketOfficeFactory } from "../src/TicketOfficeFactory.sol";
import { TicketOperations } from "../src/TicketOperations.sol";
import { AdminOperations } from "../src/AdminOperations.sol";
import { Script } from "lib/forge-std/src/Script.sol";
import { console } from "lib/forge-std/src/console.sol";

contract DeployNewArchitecture is Script {
  // USDC addresses
  address public USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // Mainnet
  address public SEPOLIAUSDC = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238; // Sepolia
  address public CheersFinanceEth = 0x70AFEF91DAe765B1E45A9736c21D7cd061EAf205;

  function run() external returns (
    TicketOfficeFactory factory,
    TicketOperations ticketOps,
    AdminOperations adminOps
  ) {
    // Auto-detect network by chain ID
    address usdcAddress;
    if (block.chainid == 1) {
      usdcAddress = USDC;
      console.log("Deploying to Ethereum Mainnet");
    } else if (block.chainid == 11155111) {
      usdcAddress = SEPOLIAUSDC;
      console.log("Deploying to Sepolia Testnet");
    } else {
      revert("Unsupported network");
    }

    console.log("USDC Address:", usdcAddress);
    console.log("Owner Address:", CheersFinanceEth);

    vm.startBroadcast();

    // 1. Deploy Factory
    factory = new TicketOfficeFactory(
      usdcAddress,
      CheersFinanceEth
    );
    console.log("TicketOfficeFactory deployed at:", address(factory));

    // 2. Deploy TicketOperations
    ticketOps = new TicketOperations(address(factory));
    console.log("TicketOperations deployed at:", address(ticketOps));

    // 3. Deploy AdminOperations
    adminOps = new AdminOperations(address(factory));
    console.log("AdminOperations deployed at:", address(adminOps));

    // 4. Register operation contracts with factory
    factory.setOperationContract(address(ticketOps), true);
    console.log("TicketOperations registered with factory");
    
    factory.setOperationContract(address(adminOps), true);
    console.log("AdminOperations registered with factory");

    vm.stopBroadcast();

    console.log("\n=== DEPLOYMENT COMPLETE ===");
    console.log("Factory:", address(factory));
    console.log("TicketOperations:", address(ticketOps));
    console.log("AdminOperations:", address(adminOps));
    console.log("\nSave these addresses for frontend integration!");

    return (factory, ticketOps, adminOps);
  }
}
