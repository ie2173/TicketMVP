// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script, console } from "lib/forge-std/src/Script.sol";
import { TicketOperations } from "../src/TicketOperations.sol";

interface ITicketOfficeFactory {
  function setOperationContract(address, bool) external;
  function isOperationContract(address) external view returns (bool);
  function owner() external view returns (address);
}

/// @title RedeployTicketOperations - Upgrade TicketOperations contract only
/// @notice Deploys a new TicketOperations, registers it with the existing factory,
///         and optionally deauthorizes the old one
contract RedeployTicketOperations is Script {
  // Existing mainnet factory address
  address public constant FACTORY = 0xE2A349548e3Aff59681f0eA1c25779F830Fb3ee0;
  
  // Current TicketOperations to deauthorize (optional)
  address public constant OLD_TICKET_OPS = 0x0c931FC196D678b6F327c5d03D8253F75575B484;
  
  function run() external returns (TicketOperations newTicketOps) {
    ITicketOfficeFactory factory = ITicketOfficeFactory(FACTORY);
    
    console.log("=== UPGRADING TICKET OPERATIONS ===");
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
    
    console.log("\n=== UPGRADE COMPLETE ===");
    console.log("New TicketOperations:", address(newTicketOps));
    console.log("Old TicketOperations decommissioned:", OLD_TICKET_OPS);
    console.log("\nUpdate your frontend to use the new address!");
    
    return newTicketOps;
  }
}
