// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { EventContract } from "../src/EventContract.sol";
import { TicketOfficeFactory } from "../src/TicketOfficeFactory.sol";
import { TicketStructs } from "../src/libraries/TicketStructs.sol";
import { Script } from "lib/forge-std/src/Script.sol";
import { console } from "lib/forge-std/src/console.sol";

contract DeployEventContract is Script {
  function run() external returns (uint256 eventId, address eventData, address ticketToken) {
    // Get factory address from environment or use deployed address
    address factoryAddress = vm.envAddress("FACTORY_ADDRESS");
    
    // Example event details - customize as needed
    TicketStructs.Ticketdetails memory details = createExampleEvent();
    
    console.log("Creating event...");
    console.log("Factory:", factoryAddress);
    console.log("Event Owner:", details.owner);

    vm.startBroadcast();

    // Factory creates everything
    TicketOfficeFactory factory = TicketOfficeFactory(factoryAddress);
    (eventId, eventData, ticketToken) = factory.createEvent(
      details.owner,
      "ipfs://your-token-uri", // Update with actual URI
      details
    );

    vm.stopBroadcast();

    console.log("EventData deployed at:", eventData);
    console.log("Ticket Token at:", ticketToken);
    console.log("Registered as Event ID:", eventId);
    
    return (eventId, eventData, ticketToken);
  }

  function createExampleEvent() internal view returns (TicketStructs.Ticketdetails memory) {
    // Create ticket arrays
    string[] memory ticketNames = new string[](2);
    ticketNames[0] = "General Admission";
    ticketNames[1] = "VIP";

    uint256[] memory ticketPrices = new uint256[](2);
    ticketPrices[0] = 50 * 1e6; // 50 USDC
    ticketPrices[1] = 150 * 1e6; // 150 USDC

    uint256[] memory ticketCapacities = new uint256[](2);
    ticketCapacities[0] = 1000;
    ticketCapacities[1] = 100;

    uint256[] memory ticketsSold = new uint256[](2);
    // Will be initialized to 0

    uint256[] memory feePercentages = new uint256[](2);
    feePercentages[0] = 10; // 10%
    feePercentages[1] = 10; // 10%

    TicketStructs.Tickets memory tickets = TicketStructs.Tickets({
      ticketNames: ticketNames,
      ticketCapacities: ticketCapacities,
      ticketPrices: ticketPrices,
      ticketsSold: ticketsSold,
      feePercentages: feePercentages
    });

    TicketStructs.LocationDetails memory location = TicketStructs.LocationDetails({
      venue: "Madison Square Garden, New York, NY"
    });

    string[] memory performers = new string[](1);
    performers[0] = "Example Artist";

    string[] memory keywords = new string[](2);
    keywords[0] = "concert";
    keywords[1] = "rock";

    string[] memory categories = new string[](1);
    categories[0] = "Music";

    return TicketStructs.Ticketdetails({
      name: "Example Concert",
      owner: msg.sender, // Or specify address
      eventDate: block.timestamp + 90 days,
      ticketInformation: tickets,
      locationDetails: location,
      performers: performers,
      keywords: keywords,
      categories: categories,
      eventDescription: "An amazing concert experience",
      eventType: "Concert"
    });
  }
}
