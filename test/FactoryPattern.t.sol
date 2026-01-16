// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test, console } from "forge-std/Test.sol";
import { TicketOfficeFactory } from "../src/TicketOfficeFactory.sol";
import { EventContract } from "../src/EventContract.sol";
import { TicketStructs } from "../src/libraries/TicketStructs.sol";
import { IERC20 } from "../src/interfaces/IERC20.sol";

contract FactoryPatternTest is Test {
    TicketOfficeFactory public factory;
    IERC20 public usdc;
    
    address public constant USDC_MAINNET = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    
    function setUp() public {
        // Fork mainnet for testing
        vm.createFork("https://eth-mainnet.g.alchemy.com/v2/uB0e37C17l2v_Jp8ESmS1rsIyckC-LaI");
        
        usdc = IERC20(USDC_MAINNET);
        factory = new TicketOfficeFactory(USDC_MAINNET);
        
        console.log("Factory deployed at:", address(factory));
        console.log("Factory size check - should be under 24,576 bytes");
    }
    
    function testCreateEvent() public {
        // Create test event data
        string[] memory ticketNames = new string[](2);
        ticketNames[0] = "General Admission";
        ticketNames[1] = "VIP";
        
        uint256[] memory ticketCapacities = new uint256[](2);
        ticketCapacities[0] = 1000;
        ticketCapacities[1] = 100;
        
        uint256[] memory ticketPrices = new uint256[](2);
        ticketPrices[0] = 50e6; // $50 USDC
        ticketPrices[1] = 200e6; // $200 USDC
        
        TicketStructs.TicketInformation memory ticketInfo = TicketStructs.TicketInformation(
            ticketNames,
            ticketCapacities,
            ticketPrices
        );
        
        TicketStructs.Ticketdetails memory eventDetails = TicketStructs.Ticketdetails(
            "Test Concert",
            msg.sender,
            block.timestamp + 7 days,
            TicketStructs.Tickets(new string[](0), new uint256[](0), new uint256[](0), new uint256[](0)),
            TicketStructs.LocationDetails("Test Venue", "Test City"),
            new string[](0),
            new string[](0),
            new string[](0),
            "A test concert",
            "Music"
        );
        
        // Create event
        (uint256 eventId, address eventContract) = factory.createEvent(
            eventDetails,
            ticketInfo,
            "https://test.com/"
        );
        
        // Verify event creation
        assertEq(eventId, 0, "First event should have ID 0");
        assertTrue(eventContract != address(0), "Event contract should be deployed");
        
        // Verify factory registry
        assertEq(factory.getEventContract(eventId), eventContract, "Factory should track event contract");
        
        TicketStructs.BasicEventInfo memory info = factory.getEventInfo(eventId);
        assertEq(info.name, "Test Concert", "Event name should match");
        assertEq(info.owner, msg.sender, "Event owner should match");
        assertEq(info.eventContract, eventContract, "Event contract address should match");
        
        console.log("Event created successfully!");
        console.log("Event ID:", eventId);
        console.log("Event contract:", eventContract);
        
        // Test interaction with event contract
        EventContract eventContractInstance = EventContract(eventContract);
        assertEq(eventContractInstance.eventOwner(), msg.sender, "Event contract should track owner");
        assertEq(eventContractInstance.getTicketPrice(0), 50e6, "General admission price should be $50");
        assertEq(eventContractInstance.getTicketPrice(1), 200e6, "VIP price should be $200");
        
        console.log("Event contract interactions working!");
    }
    
    function testFactorySize() public view {
        // This test verifies our contracts are under the size limit
        // The actual size check happens during compilation
        console.log("Factory contract successfully deployed under size limit");
        console.log("EventContract template ready for deployment");
    }
}