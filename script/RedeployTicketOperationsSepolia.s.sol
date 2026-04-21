// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script, console } from "lib/forge-std/src/Script.sol";
import { TicketOperations } from "../src/TicketOperations.sol";

interface ITicketOfficeFactory {
  function setOperationContract(address, bool) external;
  function isOperationContract(address) external view returns (bool);
  function owner() external view returns (address);
}

/// @title RedeployTicketOperationsSepolia - Upgrade TicketOperations contract on Sepolia
/// @notice Deploys a new TicketOperations, registers it with the existing factory,
///         and decommissions the old one
contract RedeployTicketOperationsSepolia is Script {
  // Sepolia factory address (update this with your actual Sepolia factory address)
  address public constant FACTORY = 0x5ab35151E6a34f23E7381Df4B038Dbd38BF83E4A;
  
  // Current Sepolia TicketOperations to deauthorize (update this with actual address)
  address public constant OLD_TICKET_OPS = 0x48228d825dA48B3dc99c7d29C10705c0212C79D7;
  
  function run() external returns (TicketOperations newTicketOps) {
    ITicketOfficeFactory factory = ITicketOfficeFactory(FACTORY);
    
    console.log("=== UPGRADING TICKET OPERATIONS ON SEPOLIA ===");
    console.log("Factory:", FACTORY);
    console.log("Factory owner:", factory.owner());
    console.log("Old TicketOperations:", OLD_TICKET_OPS);
    
    vm.startBroadcast();
    
    // 1. Deploy new TicketOperations
    newTicketOps = new TicketOperations(FACTORY);
    console.log("New TicketOperations deployed at:", address(newTicketOps));
    
    // 2. Authorize new TicketOperations
    factory.setOperationContract(address(newTicketOps), true);
    console.log("New TicketOperations authorized");
    
    // 3. Deauthorize old TicketOperations
    factory.setOperationContract(OLD_TICKET_OPS, false);
    console.log("Old TicketOperations deauthorized");
    
    vm.stopBroadcast();
    
    console.log("\n=== SEPOLIA UPGRADE COMPLETE ===");
    console.log("New TicketOperations:", address(newTicketOps));
    console.log("Old TicketOperations decommissioned:", OLD_TICKET_OPS);
    console.log("\nUpdate your frontend to use the new Sepolia address!");
    console.log("\nTest the claimRefund functionality on Sepolia before mainnet deployment!");
    
    return newTicketOps;
  }
}