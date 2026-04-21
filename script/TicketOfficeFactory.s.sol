// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { TicketOfficeFactory } from "../src/TicketOfficeFactory.sol";
import { Script } from "lib/forge-std/src/Script.sol";
import { console } from "lib/forge-std/src/console.sol";

contract DeployTicketOfficeFactory is Script {
  // USDC addresses
  address public USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // Mainnet
  address public SEPOLIAUSDC = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238; // Sepolia
  address public CheersFinanceEth = 0x70AFEF91DAe765B1E45A9736c21D7cd061EAf205;

  function run() external returns (TicketOfficeFactory) {
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

    TicketOfficeFactory factory = new TicketOfficeFactory(
      usdcAddress,
      CheersFinanceEth
    );

    vm.stopBroadcast();

    console.log("TicketOfficeFactory deployed at:", address(factory));
    return factory;
  }
}
