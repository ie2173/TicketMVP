// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script, console } from "lib/forge-std/src/Script.sol";

interface ITicketOfficeFactory {
  function setOperationContract(address, bool) external;
  function isOperationContract(address) external view returns (bool);
  function owner() external view returns (address);
}

/// @title DecommissionOldContract - Remove authorization from old contracts
/// @notice Deauthorizes old operation contracts that are no longer needed
contract DecommissionOldContract is Script {
  // Existing mainnet factory address
  address public constant FACTORY = 0xE2A349548e3Aff59681f0eA1c25779F830Fb3ee0;
  
  // Old contracts to decommission
  address public constant OLD_TICKET_OPS = 0x0c931FC196D678b6F327c5d03D8253F75575B484;
  
  function run() external {
    ITicketOfficeFactory factory = ITicketOfficeFactory(FACTORY);
    
    console.log("=== DECOMMISSIONING OLD CONTRACTS ===");
    console.log("Factory:", FACTORY);
    console.log("Factory owner:", factory.owner());
    
    // Check current authorization status
    bool isAuthorized = factory.isOperationContract(OLD_TICKET_OPS);
    console.log("Old TicketOperations currently authorized:", isAuthorized);
    
    if (!isAuthorized) {
      console.log("Contract already decommissioned!");
      return;
    }
    
    vm.startBroadcast();
    
    // Deauthorize old contract
    factory.setOperationContract(OLD_TICKET_OPS, false);
    
    vm.stopBroadcast();
    
    console.log("\n=== DECOMMISSION COMPLETE ===");
    console.log("Old TicketOperations deauthorized:", OLD_TICKET_OPS);
    console.log("\nThe old contract can no longer interact with EventData or ERC1155Token contracts.");
  }
}