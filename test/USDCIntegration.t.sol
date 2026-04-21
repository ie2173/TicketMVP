// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test } from "lib/forge-std/src/Test.sol";
import { TicketOfficeFactory } from "../src/TicketOfficeFactory.sol";
import { TicketOperations } from "../src/TicketOperations.sol";
import { AdminOperations } from "../src/AdminOperations.sol";
import { EventData } from "../src/EventData.sol";
import { TicketStructs } from "../src/libraries/TicketStructs.sol";
import { IERC20 } from "../src/interfaces/IERC20.sol";

contract USDCIntegrationTest is Test {
  using TicketStructs for TicketStructs.Ticketdetails;

  // Real mainnet USDC
  address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

  TicketOfficeFactory public factory;
  TicketOperations public ticketOps;
  AdminOperations public adminOps;

  address public contractOwner = address(0x70AFEF91DAe765B1E45A9736c21D7cd061EAf205);
  address public eventOwner = address(0x1111);
  address public buyer = address(0x2222);

  function setUp() public {
    // Deploy factory wired to mainnet USDC
    factory = new TicketOfficeFactory(USDC, contractOwner);

    // Deploy operations and authorize
    ticketOps = new TicketOperations(address(factory));
    adminOps = new AdminOperations(address(factory));

    vm.startPrank(contractOwner);
    factory.setOperationContract(address(ticketOps), true);
    factory.setOperationContract(address(adminOps), true);
    vm.stopPrank();
  }

  function testBuyAndWithdrawWithMainnetUSDC() public {
    // Create a simple event with one ticket type, price 50 USDC, fee 10%
    uint256[] memory prices = new uint256[](1);
    prices[0] = 50 * 1e6; // USDC has 6 decimals
    uint256[] memory capacities = new uint256[](1);
    capacities[0] = 100;
    uint256[] memory fees = new uint256[](1);
    fees[0] = 10;
    string[] memory names = new string[](1);
    names[0] = "GA";

    TicketStructs.LocationDetails memory location = TicketStructs.LocationDetails({ venue: "Integration Venue" });
    uint256[] memory ticketsSold = new uint256[](1);

    TicketStructs.Tickets memory ticketInfo = TicketStructs.Tickets({
      ticketNames: names,
      ticketCapacities: capacities,
      ticketPrices: prices,
      ticketsSold: ticketsSold,
      feePercentages: fees
    });

    string[] memory performers = new string[](1);
    performers[0] = "Test Band";
    string[] memory keywords = new string[](1);
    keywords[0] = "integration";
    string[] memory categories = new string[](1);
    categories[0] = "Music";

    TicketStructs.Ticketdetails memory details = TicketStructs.Ticketdetails({
      name: "Integration Event",
      owner: eventOwner,
      eventDate: block.timestamp - 1, // in the past so withdraws are allowed
      ticketInformation: ticketInfo,
      locationDetails: location,
      performers: performers,
      keywords: keywords,
      categories: categories,
      eventDescription: "Integration test",
      eventType: "Live"
    });

    // Create event as contract owner
    vm.prank(contractOwner);
    (uint256 eventId, address eventDataAddr, ) = factory.createEvent(eventOwner, "ipfs://integration", details);

    // Give buyer USDC on the fork
    uint256 buyerAmount = 1_000 * 1e6;
    deal(USDC, buyer, buyerAmount);

    // Approve ticketOps to move USDC
    vm.prank(buyer);
    IERC20(USDC).approve(address(ticketOps), prices[0]);

    // Buy ticket
    vm.prank(buyer);
    ticketOps.buyTicket(eventId, 0);

    // Check EventData balance
    EventData ed = EventData(eventDataAddr);
    uint256 expected = prices[0];
    assertEq(IERC20(USDC).balanceOf(eventDataAddr), expected);
    assertEq(ed.eventBalance(), expected);

    // Withdraw funds as factory owner (allowed by onlyEventAdmin)
    vm.prank(contractOwner);
    adminOps.withdrawFunds(eventId);

    // After withdraw: fees (10%) go to factory owner, remainder to eventOwner
    uint256 fee = (expected * 10) / 100; // 5 USDC
    uint256 ownerAmount = expected - fee; // 45 USDC

    assertEq(IERC20(USDC).balanceOf(contractOwner), fee);
    assertEq(IERC20(USDC).balanceOf(eventOwner), ownerAmount);
    assertEq(IERC20(USDC).balanceOf(eventDataAddr), 0);
  }
}
