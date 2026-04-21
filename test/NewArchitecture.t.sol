// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test } from "lib/forge-std/src/Test.sol";
import { console } from "lib/forge-std/src/console.sol";
import { TicketOfficeFactory } from "../src/TicketOfficeFactory.sol";
import { EventData } from "../src/EventData.sol";
import { TicketOperations } from "../src/TicketOperations.sol";
import { AdminOperations } from "../src/AdminOperations.sol";
import { ERC1155Token } from "../src/ERC1155Token.sol";
import { TicketStructs } from "../src/libraries/TicketStructs.sol";
import { IERC20 } from "../src/interfaces/IERC20.sol";

// Mock USDC for testing
contract MockERC20 {
  mapping(address => uint256) public balanceOf;
  mapping(address => mapping(address => uint256)) public allowance;
  
  function approve(address spender, uint256 amount) external returns (bool) {
    allowance[msg.sender][spender] = amount;
    return true;
  }
  
  function transfer(address to, uint256 amount) external returns (bool) {
    balanceOf[msg.sender] -= amount;
    balanceOf[to] += amount;
    return true;
  }
  
  function transferFrom(address from, address to, uint256 amount) external returns (bool) {
    require(allowance[from][msg.sender] >= amount, "!A");
    balanceOf[from] -= amount;
    balanceOf[to] += amount;
    allowance[from][msg.sender] -= amount;
    return true;
  }
  
  function mint(address to, uint256 amount) external {
    balanceOf[to] += amount;
  }
}

contract NewArchitectureTest is Test {
  using TicketStructs for TicketStructs.Ticketdetails;

  TicketOfficeFactory public factory;
  TicketOperations public ticketOps;
  AdminOperations public adminOps;
  MockERC20 public usdc;
  
  address public contractOwner = 0x70AFEF91DAe765B1E45A9736c21D7cd061EAf205;
  address public eventOwner = address(767);
  address public buyer1 = address(100);
  address public buyer2 = address(200);
  
  string public eventName = "Test Concert 2024";
  string public baseUrl = "ipfs://testBase";
  
  string[] public ticketNames = ["GA", "VIP"];
  uint256[] public ticketPrices = [50 * 1e6, 100 * 1e6];
  uint256[] public ticketCapacities = [100, 50];
  uint256[] public feePercentages = [10, 10];
  
  uint256 public eventDate = block.timestamp + 432_000;
  
  function setUp() public {
    // Deploy mock USDC
    usdc = new MockERC20();
    
    // Deploy factory
    vm.prank(contractOwner);
    factory = new TicketOfficeFactory(address(usdc), contractOwner);
    
    // Deploy operation contracts
    ticketOps = new TicketOperations(address(factory));
    adminOps = new AdminOperations(address(factory));
    
    // Authorize operation contracts
    vm.startPrank(contractOwner);
    factory.setOperationContract(address(ticketOps), true);
    factory.setOperationContract(address(adminOps), true);
    vm.stopPrank();
    
    // Fund buyers with USDC
    usdc.mint(buyer1, 1000 * 1e6);
    usdc.mint(buyer2, 1000 * 1e6);
  }
  
  function testFactoryDeployment() public {
    assertEq(factory.owner(), contractOwner);
    assertEq(factory.ticketOfficeOpen(), true);
    assertEq(factory.getEventCount(), 0);
  }
  
  function testCreateEvent() public {
    vm.prank(contractOwner);
    
    TicketStructs.Ticketdetails memory details = _createEventDetails();
    
    (uint256 eventId, address eventData, address ticketToken) = factory.createEvent(
      eventOwner,
      baseUrl,
      details
    );
    
    assertEq(eventId, 0);
    assertEq(factory.getEventCount(), 1);
    assertEq(factory.getEventData(0), eventData);
    
    EventData ed = EventData(eventData);
    assertEq(ed.factory(), address(factory));
    assertEq(ed.eventOwner(), eventOwner);
    assertEq(ed.eventId(), 0);
    // tokenURI now retrieved via event logs or directly from token contract
    assertEq(ERC1155Token(ed.ticketToken()).uri(), baseUrl);
  }
  
  function testBuyTicket() public {
    // Create event
    vm.prank(contractOwner);
    TicketStructs.Ticketdetails memory details = _createEventDetails();
    (uint256 eventId, , ) = factory.createEvent(eventOwner, baseUrl, details);
    
    // Buyer approves and buys ticket
    vm.startPrank(buyer1);
    usdc.approve(address(ticketOps), 50 * 1e6);
    ticketOps.buyTicket(eventId, 0);
    vm.stopPrank();
    
    // Check state
    address eventDataAddr = factory.getEventData(eventId);
    EventData ed = EventData(eventDataAddr);
    assertEq(ed.getTicketsSold(0), 1);
    assertEq(ed.eventBalance(), 50 * 1e6);
    
    // Check USDC is in EventData contract
    assertEq(usdc.balanceOf(eventDataAddr), 50 * 1e6);
    assertEq(usdc.balanceOf(address(ticketOps)), 0); // TicketOps doesn't hold funds
    
    // Check NFT was minted
    ERC1155Token token = ERC1155Token(ed.ticketToken());
    assertEq(token.balanceOf(buyer1, 0), 1);
  }
  
  function testBuyMultipleTickets() public {
    // Create event
    vm.prank(contractOwner);
    TicketStructs.Ticketdetails memory details = _createEventDetails();
    (uint256 eventId, , ) = factory.createEvent(eventOwner, baseUrl, details);
    
    // Buy multiple tickets
    uint256[] memory types = new uint256[](2);
    types[0] = 0;
    types[1] = 1;
    
    uint256[] memory quantities = new uint256[](2);
    quantities[0] = 2;
    quantities[1] = 1;
    
    vm.startPrank(buyer1);
    usdc.approve(address(ticketOps), 200 * 1e6);
    ticketOps.buyTickets(eventId, types, quantities);
    vm.stopPrank();
    
    // Check state
    address eventDataAddr = factory.getEventData(eventId);
    EventData ed = EventData(eventDataAddr);
    assertEq(ed.getTicketsSold(0), 2);
    assertEq(ed.getTicketsSold(1), 1);
  }
  
  function testCannotBuyWhenOfficeClosed() public {
    // Create event
    vm.prank(contractOwner);
    TicketStructs.Ticketdetails memory details = _createEventDetails();
    (uint256 eventId, , ) = factory.createEvent(eventOwner, baseUrl, details);
    
    // Close office
    vm.prank(contractOwner);
    factory.toggleOffice();
    
    // Try to buy ticket
    vm.startPrank(buyer1);
    usdc.approve(address(ticketOps), 50 * 1e6);
    vm.expectRevert(bytes("!O"));
    ticketOps.buyTicket(eventId, 0);
    vm.stopPrank();
  }
  
  function testAddCompTicket() public {
    // Create event
    vm.prank(contractOwner);
    TicketStructs.Ticketdetails memory details = _createEventDetails();
    (uint256 eventId, , ) = factory.createEvent(eventOwner, baseUrl, details);
    
    // Event owner adds comp ticket
    vm.prank(eventOwner);
    adminOps.addCompTicket(eventId, buyer1, 0);
    
    // Check voucher was added
    address eventDataAddr = factory.getEventData(eventId);
    EventData ed = EventData(eventDataAddr);
    assertTrue(ed.freeTicketVoucher(buyer1, 0));
  }
  
  function testRedeemCompTicket() public {
    // Create event
    vm.prank(contractOwner);
    TicketStructs.Ticketdetails memory details = _createEventDetails();
    (uint256 eventId, , ) = factory.createEvent(eventOwner, baseUrl, details);
    
    // Add comp ticket
    vm.prank(eventOwner);
    adminOps.addCompTicket(eventId, buyer1, 0);
    
    // Redeem comp ticket
    vm.prank(buyer1);
    ticketOps.redeemCompTicket(eventId, 0);
    
    // Check state
    address eventDataAddr = factory.getEventData(eventId);
    EventData ed = EventData(eventDataAddr);
    assertEq(ed.getTicketsSold(0), 1);
    assertTrue(ed.ticketComped(buyer1, 0));
    
    // Check NFT was minted
    ERC1155Token token = ERC1155Token(ed.ticketToken());
    assertEq(token.balanceOf(buyer1, 0), 1);
  }
  
  function _createEventDetails() internal view returns (TicketStructs.Ticketdetails memory) {
    TicketStructs.LocationDetails memory location = TicketStructs.LocationDetails({
      venue: "Test Venue, Test Location"
    });
    
    uint256[] memory ticketsSold = new uint256[](2);
    
    TicketStructs.Tickets memory ticketInfo = TicketStructs.Tickets({
      ticketNames: ticketNames,
      ticketCapacities: ticketCapacities,
      ticketPrices: ticketPrices,
      ticketsSold: ticketsSold,
      feePercentages: feePercentages
    });
    
    string[] memory performers = new string[](1);
    performers[0] = "Test Band";
    
    string[] memory keywords = new string[](1);
    keywords[0] = "rock";
    
    string[] memory categories = new string[](1);
    categories[0] = "Music";
    
    return TicketStructs.Ticketdetails({
      name: eventName,
      owner: eventOwner,
      eventDate: eventDate,
      ticketInformation: ticketInfo,
      locationDetails: location,
      performers: performers,
      keywords: keywords,
      categories: categories,
      eventDescription: "Test event description",
      eventType: "Live"
    });
  }
  
  function testFactoryUpgrade() public {
    // Create event
    vm.prank(contractOwner);
    TicketStructs.Ticketdetails memory details = _createEventDetails();
    (uint256 eventId, address eventDataAddr, ) = factory.createEvent(eventOwner, baseUrl, details);
    
    EventData eventData = EventData(eventDataAddr);
    assertEq(eventData.factory(), address(factory));
    
    // Deploy new factory (simulated with a random address)
    address newFactory = address(0x999);
    
    // Event owner can update factory on their EventData
    vm.prank(eventOwner);
    eventData.setFactory(newFactory);
    assertEq(eventData.factory(), newFactory);
    
    // Protocol owner can update factory on operation contracts
    vm.prank(contractOwner);
    ticketOps.setFactory(newFactory);
    assertEq(ticketOps.factory(), newFactory);
    
    vm.prank(contractOwner);
    adminOps.setFactory(newFactory);
    assertEq(adminOps.factory(), newFactory);
  }
  
  function testFactoryUpgradeOnlyOwner() public {
    // Create event
    vm.prank(contractOwner);
    TicketStructs.Ticketdetails memory details = _createEventDetails();
    (, address eventDataAddr, ) = factory.createEvent(eventOwner, baseUrl, details);
    
    EventData eventData = EventData(eventDataAddr);
    
    // Non-owner cannot update factory
    vm.prank(buyer1);
    vm.expectRevert(bytes("!A"));
    eventData.setFactory(address(0x999));
    
    // Non-protocol-owner cannot update operation contracts
    vm.prank(buyer1);
    vm.expectRevert(bytes("!A"));
    ticketOps.setFactory(address(0x999));
  }
  
  function testEventMetadataStorage() public {
    // Create event with detailed metadata
    vm.prank(contractOwner);
    TicketStructs.Ticketdetails memory details = _createEventDetails();
    
    (uint256 eventId, address eventDataAddr, address ticketToken) = factory.createEvent(
      eventOwner,
      baseUrl,
      details
    );
    
    // Get EventData contract
    EventData ed = EventData(eventDataAddr);
    
    // Test basic event info
    assertEq(ed.eventOwner(), eventOwner);
    assertEq(ed.eventId(), eventId);
    assertEq(ed.factory(), address(factory));
    
    // Test NEW array/nested data getters
    assertEq(ed.getEventName(), eventName);
    assertEq(ed.getVenue(), "Test Venue, Test Location");
    assertEq(ed.getEventDescription(), "Test event description");
    assertEq(ed.getEventType(), "Live");
    
    // Test performers array
    string[] memory performers = ed.getPerformers();
    assertEq(performers.length, 1);
    assertEq(performers[0], "Test Band");
    
    // Test keywords array
    string[] memory keywords = ed.getKeywords();
    assertEq(keywords.length, 1);
    assertEq(keywords[0], "rock");
    
    // Test categories array
    string[] memory categories = ed.getCategories();
    assertEq(categories.length, 1);
    assertEq(categories[0], "Music");
    
    // Test ticket names array
    string[] memory ticketNames = ed.getTicketNames();
    assertEq(ticketNames.length, 2);
    assertEq(ticketNames[0], "GA");
    assertEq(ticketNames[1], "VIP");
    assertEq(ed.getTicketName(0), "GA");
    assertEq(ed.getTicketName(1), "VIP");
    
    // Verify individual getter functions for ticket information
    assertEq(ed.getEventDate(), eventDate);
    assertEq(ed.getTicketPrice(0), 50 * 1e6);
    assertEq(ed.getTicketPrice(1), 100 * 1e6);
    assertEq(ed.getTicketCapacity(0), 100);
    assertEq(ed.getTicketCapacity(1), 50);
    assertEq(ed.getTicketsSold(0), 0);
    assertEq(ed.getTicketsSold(1), 0);
    assertEq(ed.getTicketFeePercentage(0), 10);
    assertEq(ed.getTicketFeePercentage(1), 10);
    assertEq(ed.getTicketCount(), 2);
    
    // Verify token URI and name
    ERC1155Token token = ERC1155Token(ticketToken);
    assertEq(token.uri(), baseUrl);
    assertEq(token.name(), eventName);
    
    console.log("Event metadata stored correctly:");
    console.log("  - Event name:", eventName);
    console.log("  - Event owner:", eventOwner);
    console.log("  - Event date:", eventDate);
    console.log("  - Ticket types:", 2);
    console.log("  - GA price: 50 USDC");
    console.log("  - VIP price: 100 USDC");
    console.log("  - GA capacity:", 100);
    console.log("  - VIP capacity:", 50);
  }
  
  function testEventMetadataWithMultiplePerformers() public {
    // Create event with multiple performers
    vm.prank(contractOwner);
    
    TicketStructs.LocationDetails memory location = TicketStructs.LocationDetails({
      venue: "Madison Square Garden, New York"
    });
    
    uint256[] memory ticketsSold = new uint256[](2);
    
    TicketStructs.Tickets memory ticketInfo = TicketStructs.Tickets({
      ticketNames: ticketNames,
      ticketCapacities: ticketCapacities,
      ticketPrices: ticketPrices,
      ticketsSold: ticketsSold,
      feePercentages: feePercentages
    });
    
    string[] memory performers = new string[](3);
    performers[0] = "The Rolling Stones";
    performers[1] = "AC/DC";
    performers[2] = "Metallica";
    
    string[] memory keywords = new string[](3);
    keywords[0] = "rock";
    keywords[1] = "classic";
    keywords[2] = "metal";
    
    string[] memory categories = new string[](2);
    categories[0] = "Music";
    categories[1] = "Festival";
    
    TicketStructs.Ticketdetails memory details = TicketStructs.Ticketdetails({
      name: "Rock Legends Festival",
      owner: eventOwner,
      eventDate: eventDate,
      ticketInformation: ticketInfo,
      locationDetails: location,
      performers: performers,
      keywords: keywords,
      categories: categories,
      eventDescription: "The biggest rock festival of the year",
      eventType: "Festival"
    });
    
    (uint256 eventId, address eventDataAddr, ) = factory.createEvent(
      eventOwner,
      "ipfs://rockfestival",
      details
    );
    
    // Get EventData contract
    EventData ed = EventData(eventDataAddr);
    
    // Verify basic metadata through getters
    assertEq(ed.getEventDate(), eventDate);
    assertEq(ed.getTicketCount(), 2);
    assertEq(ed.getTicketPrice(0), 50 * 1e6);
    assertEq(ed.getTicketPrice(1), 100 * 1e6);
    
    console.log("Multi-performer event created:");
    console.log("  - Event: Rock Legends Festival");
    console.log("  - Venue: Madison Square Garden, New York");
    console.log("  - Performers: 3 bands");
    console.log("  - Categories: 2");
  }
  
  function testTicketQuantitiesAfterPurchases() public {
    // Create event
    vm.prank(contractOwner);
    TicketStructs.Ticketdetails memory details = _createEventDetails();
    (uint256 eventId, address eventDataAddr, ) = factory.createEvent(eventOwner, baseUrl, details);
    
    EventData ed = EventData(eventDataAddr);
    
    // Initial quantities should be 0
    assertEq(ed.getTicketsSold(0), 0);
    assertEq(ed.getTicketsSold(1), 0);
    assertEq(ed.getTotalTicketsSold(), 0);
    
    // Buyer1 buys tickets
    vm.startPrank(buyer1);
    usdc.approve(address(ticketOps), 250 * 1e6);
    ticketOps.buyTicket(eventId, 0); // Buy 1 GA
    ticketOps.buyTicket(eventId, 1); // Buy 1 VIP
    vm.stopPrank();
    
    // Check quantities updated
    assertEq(ed.getTicketsSold(0), 1);
    assertEq(ed.getTicketsSold(1), 1);
    assertEq(ed.getTotalTicketsSold(), 2);
    
    // Buyer2 buys tickets
    vm.startPrank(buyer2);
    usdc.approve(address(ticketOps), 300 * 1e6);
    ticketOps.buyTicket(eventId, 0); // Buy 1 GA
    ticketOps.buyTicket(eventId, 0); // Buy another GA
    ticketOps.buyTicket(eventId, 1); // Buy 1 VIP
    vm.stopPrank();
    
    // Check final quantities
    assertEq(ed.getTicketsSold(0), 3);
    assertEq(ed.getTicketsSold(1), 2);
    assertEq(ed.getTotalTicketsSold(), 5);
    
    // Verify capacities are still correct
    assertEq(ed.getTicketCapacity(0), 100);
    assertEq(ed.getTicketCapacity(1), 50);
  }

  function testClaimRefundSelfService() public {
    // Create event
    vm.prank(contractOwner);
    TicketStructs.Ticketdetails memory details = _createEventDetails();
    (uint256 eventId, address eventDataAddr, ) = factory.createEvent(eventOwner, baseUrl, details);
    
    EventData ed = EventData(eventDataAddr);
    ERC1155Token token = ERC1155Token(ed.ticketToken());
    
    // Buyer1 buys multiple tickets: 2 GA ($50 each) + 1 VIP ($100)
    // Total: $200 = 200 * 1e6
    vm.startPrank(buyer1);
    usdc.approve(address(ticketOps), 200 * 1e6);
    
    uint256[] memory ticketTypes = new uint256[](2);
    uint256[] memory quantities = new uint256[](2);
    ticketTypes[0] = 0; // GA
    ticketTypes[1] = 1; // VIP
    quantities[0] = 2;  // 2 GA tickets
    quantities[1] = 1;  // 1 VIP ticket
    
    ticketOps.buyTickets(eventId, ticketTypes, quantities);
    vm.stopPrank();
    
    // Verify buyer1 has tickets
    assertEq(token.balanceOf(buyer1, 0), 2); // 2 GA
    assertEq(token.balanceOf(buyer1, 1), 1); // 1 VIP
    
    // Verify event balance
    assertEq(ed.eventBalance(), 200 * 1e6);
    
    // Record buyer1's USDC balance before refund
    uint256 buyer1UsdcBefore = usdc.balanceOf(buyer1);
    
    // Lock the event (cancellation)
    vm.prank(eventOwner);
    adminOps.lockEvent(eventId);
    
    // Now buyer1 can claim their own refund
    vm.prank(buyer1);
    ticketOps.claimRefund(eventId);
    
    // Verify all tickets burned
    assertEq(token.balanceOf(buyer1, 0), 0);
    assertEq(token.balanceOf(buyer1, 1), 0);
    
    // Verify buyer1 received full refund ($200)
    assertEq(usdc.balanceOf(buyer1), buyer1UsdcBefore + 200 * 1e6);
    
    // Verify event balance is now 0
    assertEq(ed.eventBalance(), 0);
    
    // Verify tickets sold decremented
    assertEq(ed.getTicketsSold(0), 0);
    assertEq(ed.getTicketsSold(1), 0);
    
    console.log("Self-service refund test passed:");
    console.log("  - Buyer purchased 2 GA + 1 VIP = $200");
    console.log("  - Event was locked/cancelled");
    console.log("  - Buyer claimed refund in one transaction");
    console.log("  - All tickets burned, full refund received");
  }

  function testClaimRefundCannotClaimCompedTickets() public {
    // Create event
    vm.prank(contractOwner);
    TicketStructs.Ticketdetails memory details = _createEventDetails();
    (uint256 eventId, address eventDataAddr, ) = factory.createEvent(eventOwner, baseUrl, details);
    
    EventData ed = EventData(eventDataAddr);
    ERC1155Token token = ERC1155Token(ed.ticketToken());
    
    // Buyer1 buys 1 GA ticket ($50)
    vm.startPrank(buyer1);
    usdc.approve(address(ticketOps), 50 * 1e6);
    ticketOps.buyTicket(eventId, 0);
    vm.stopPrank();
    
    // Event owner gives buyer1 a comp VIP ticket
    vm.prank(eventOwner);
    adminOps.addCompTicket(eventId, buyer1, 1);
    
    // Buyer1 redeems the comp ticket
    vm.prank(buyer1);
    ticketOps.redeemCompTicket(eventId, 1);
    
    // Verify buyer1 has both tickets
    assertEq(token.balanceOf(buyer1, 0), 1); // 1 GA (paid)
    assertEq(token.balanceOf(buyer1, 1), 1); // 1 VIP (comped)
    
    // Record buyer1's USDC balance
    uint256 buyer1UsdcBefore = usdc.balanceOf(buyer1);
    
    // Lock the event
    vm.prank(eventOwner);
    adminOps.lockEvent(eventId);
    
    // Buyer1 claims refund - should only get refund for paid GA ticket
    vm.prank(buyer1);
    ticketOps.claimRefund(eventId);
    
    // GA ticket burned (paid), VIP ticket NOT burned (comped - skipped)
    assertEq(token.balanceOf(buyer1, 0), 0); // GA burned
    assertEq(token.balanceOf(buyer1, 1), 1); // VIP still there (comped)
    
    // Buyer1 should only get $50 refund (for GA), not $150
    assertEq(usdc.balanceOf(buyer1), buyer1UsdcBefore + 50 * 1e6);
    
    console.log("Comp ticket exclusion test passed:");
    console.log("  - Buyer had 1 paid GA ($50) + 1 comped VIP");
    console.log("  - After refund: only GA refunded, VIP kept");
    console.log("  - Refund amount: $50 (not $150)");
  }
}
