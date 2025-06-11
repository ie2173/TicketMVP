// // SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "../src/libraries/TicketStructs.sol";
import "lib/forge-std/src/Test.sol";
import "src/TicketOffice.sol";
import "src/interfaces/IERC20.sol";

contract TicketOfficeTest2 is Test {
  using TicketStructs for TicketStructs.Ticketdetails;
  using TicketStructs for TicketStructs.LocationDetails;

  TicketOffice public ticketOffice;
  ERC1155Token public ERC1155ConcertToken;
  IERC20 public usdCoin;
  address public contractOwner = 0x70AFEF91DAe765B1E45A9736c21D7cd061EAf205;
  address public contractAddress;
  string public name = "Cheers Finance";
  address public ownerWallet = address(767);
  string public eventName = "Monster Energy Drink Presents LollaPalooza 2023";
  string public symbol = "lolla";
  string public baseUrl = "ipfs:/demoBase";
  // Need Array for Ticket Names:
  string[] public ticketNames = ["General Admission", "VIP", "Backstage Pass"];
  // Need Array for Ticket Prices;
  uint256[] public ticketPrices = [10, 50, 100];
  // Need Array for Ticket Capacities;
  uint256[] public ticketCapacities = [100, 50, 10];
  uint256 public eventDate = block.timestamp + 432_000;
  string public concertLocation = "29.7572, -95.3556";
  string public venueName = "The Astrodome";
  string[] public groups = ["the Beasty Boys", "Mc5"];
  string[] public keywords = ["music", "festival", "rock"];
  string[] public categories = ["Rock", "concert", "LiveMusic"];
  string description = "This is a test event for the Ticket Office";
  string eventType = "Live";
  TicketStructs.Ticketdetails public details;
  TicketStructs.LocationDetails public location;
  TicketStructs.LocationDetails editLocation;
  TicketStructs.Tickets ticketDetails;
  TicketStructs.Ticketdetails badDetails;
  TicketStructs.Tickets editTickets;
  TicketStructs.Ticketdetails editDetails;

  // Ticket Office Events
  event Event(
    uint256 indexed eventIdCounter,
    string name,
    address nftAddress,
    string ticketUri,
    TicketStructs.Tickets ticketInformation,
    uint256 eventDate,
    TicketStructs.LocationDetails locationDetails,
    string[] performers,
    string[] keywords,
    string[] categories,
    string eventDescription,
    string eventType
  );

  event TicketPurchased(
    address indexed buyer, uint256 indexed eventId, uint256 indexed ticketId, uint256 quantity
  );

  // ERC20 (USDCOIN) Events
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  // ERC1155 Events
  event TransferSingle(address operator, address from, address to, uint256 id, uint256 value);
  event TransferBatch(address operator, address from, address to, uint256[] ids, uint256[] values);

  function setUp() public {
    ticketOffice = new TicketOffice(
      name,
      0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
      address(0x70AFEF91DAe765B1E45A9736c21D7cd061EAf205)
    );
    usdCoin = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    contractOwner = address(0x70AFEF91DAe765B1E45A9736c21D7cd061EAf205);
    contractAddress = address(ticketOffice);
    uint256[] memory ticketSoldArray = new uint256[](3);
    ticketSoldArray[0] = 0;
    ticketSoldArray[1] = 0;
    ticketSoldArray[2] = 0;
    string[] memory blankTicketNames = new string[](3);
    blankTicketNames[0] = "";
    blankTicketNames[1] = "";
    blankTicketNames[2] = "";
    location =
      TicketStructs.LocationDetails({ concertLocation: concertLocation, venueName: venueName });

    TicketStructs.Tickets memory blankTickets = TicketStructs.Tickets({
      ticketNames: blankTicketNames,
      ticketCapacities: ticketSoldArray,
      ticketPrices: ticketSoldArray,
      ticketsSold: ticketSoldArray
    });

    ticketDetails = TicketStructs.Tickets({
      ticketNames: ticketNames,
      ticketCapacities: ticketCapacities,
      ticketPrices: ticketPrices,
      ticketsSold: ticketSoldArray
    });

    details = TicketStructs.Ticketdetails({
      name: eventName,
      owner: ownerWallet,
      eventDate: eventDate,
      ticketInformation: blankTickets,
      locationDetails: location,
      performers: groups,
      keywords: keywords,
      categories: categories,
      eventDescription: description,
      eventType: eventType
    });
  }

  function testCreateEvent() public {
    //uint256[] memory ticketSoldArray = new uint256[](3);

    vm.startPrank(ownerWallet);
    vm.expectEmit();
    emit Event(
      0,
      eventName,
      address(0x3f739c53777872fe22B8ecebBe7Fa798ff987B5C),
      baseUrl,
      ticketDetails,
      eventDate,
      location,
      groups,
      keywords,
      categories,
      description,
      eventType
    );
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    vm.stopPrank();
    vm.startPrank(address(765));
    uint256 badDate = block.timestamp + 69;
    badDetails = TicketStructs.Ticketdetails({
      name: eventName,
      owner: ownerWallet,
      eventDate: badDate,
      ticketInformation: ticketDetails,
      locationDetails: location,
      performers: groups,
      keywords: keywords,
      categories: categories,
      eventDescription: description,
      eventType: eventType
    });
    vm.expectRevert("Event Must be created at least 3 days in advance");
    ticketOffice.createEvent(badDetails, ticketDetails, baseUrl);
  }

  function testGetTicketPrice() public {
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    uint256 result = ticketOffice.getTicketPrice(0, 0);
    assertEq(result, ticketPrices[0]);
  }

  function testGetTicketsSold() public {
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    uint256 result = ticketOffice.ticketPurchasedCounter(0, 0);
    assertEq(result, 0);
  }

  function testGetEventName() public {
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    string memory result = ticketOffice.getEventName(0);
    assertEq(result, eventName);
  }

  function testGetIsEventOwner() public {
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    bool result = ticketOffice.isEventOwner(0, ownerWallet);
    assertTrue(result);
  }

  function testGetEvent1155Address() public {
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    address results = ticketOffice.getAddress(0);
    string memory verification = ERC1155Token(results).name();
    assertEq(eventName, verification);
  }

  function testGetTicketNames() public {
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    string[] memory result = ticketOffice.getTicketNames(0);
    assertEq(result[0], ticketNames[0]);
    assertEq(result[1], ticketNames[1]);
    assertEq(result[2], ticketNames[2]);
  }

  function testGetTicketPrices() public {
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    uint256[] memory result = ticketOffice.getTicketPrices(0);
    assertEq(result[0], ticketPrices[0]);
    assertEq(result[1], ticketPrices[1]);
    assertEq(result[2], ticketPrices[2]);
  }

  function testGetTicketCapacities() public {
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    uint256[] memory result = ticketOffice.getEventCapacities(0);
    assertEq(result[0], ticketCapacities[0]);
    assertEq(result[1], ticketCapacities[1]);
    assertEq(result[2], ticketCapacities[2]);
  }

  function testGetTicketCapacity() public {
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    uint256 result = ticketOffice.getEventCapacity(0, 0);
    assertEq(result, ticketCapacities[0]);
  }

  function testGetEventOwner() public {
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    address result = ticketOffice.getEventOwner(0);
    assertEq(result, ownerWallet);
  }

  function testSingleMintTicketPasses() public {
    // set up event, Set up wallets with USDC, and approve the contract to spend the USDC

    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    address nftAddress = ticketOffice.getAddress(0);
    vm.stopPrank();
    deal(address(usdCoin), address(278), 50);
    assertEq(usdCoin.balanceOf(address(278)), 50);
    vm.startPrank(address(278));
    usdCoin.approve(address(ticketOffice), 50);
    assertEq(usdCoin.allowance(address(278), address(ticketOffice)), 50);
    // Mint a ticket verify event logs
    vm.expectEmit();
    emit Transfer(address(278), contractAddress, 10);
    emit TransferSingle(contractAddress, address(0), address(278), 0, 1);
    emit TicketPurchased(address(278), 0, 0, 1);
    ticketOffice.mintSingleTicket(0, 1, 0, address(278));
    //verify NFT
    uint256 nftValue = ERC1155Token(nftAddress).balanceOf(address(278), 0);
    assertEq(nftValue, 1);
    // Verify UsdcBalance
    assertEq(usdCoin.balanceOf(address(278)), 40);
    assertEq(usdCoin.balanceOf(address(ticketOffice)), 10);
    // Verify Ticket Balance
    address[] memory addressArray = new address[](1);
    addressArray[0] = address(278);
    uint256[] memory ticketIdArray = new uint256[](1);
    ticketIdArray[0] = 0;
    uint256[] memory balanceResult =
      ticketOffice.ticketHoldersBalance(0, addressArray, ticketIdArray);
    assertEq(balanceResult[0], 1);
    // Purchase 4 more tickets
    vm.expectEmit();
    emit Transfer(address(278), contractAddress, 40);
    emit TransferSingle(contractAddress, address(0), address(278), 0, 4);
    emit TicketPurchased(address(278), 0, 0, 4);
    ticketOffice.mintSingleTicket(0, 4, 0, address(278));

    uint256[] memory balanceResult1 =
      ticketOffice.ticketHoldersBalance(0, addressArray, ticketIdArray);
    assertEq(balanceResult1[0], 5);
    assertEq(usdCoin.balanceOf(address(278)), 0);
    assertEq(usdCoin.balanceOf(address(ticketOffice)), 50);
  }

  function testSingleMintTicketReverts() public {
    // Check Revert if Event not created
    vm.startPrank(address(278));
    vm.expectRevert("Event Does Not Exist");
    ticketOffice.mintSingleTicket(0, 1, 0, address(278));
    // set up event, Set up wallets with USDC, and approve the contract to spend the USDC
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    vm.stopPrank();
    deal(address(usdCoin), address(278), 10 * 101);
    vm.startPrank(address(278));
    // Check revert if approve fails
    vm.expectRevert();
    ticketOffice.mintSingleTicket(0, 1, 0, address(278));
    // check Revert if insufficient funds
    deal(address(usdCoin), address(279), 1);
    vm.startPrank(address(279));
    usdCoin.approve(address(ticketOffice), 1);
    vm.expectRevert();
    ticketOffice.mintSingleTicket(0, 1, 0, address(279));
    // Expect Revert if Tickets sold out
    deal(address(usdCoin), address(280), 10);
    vm.startPrank(address(278));
    usdCoin.approve(address(ticketOffice), 10 * 100);
    ticketOffice.mintSingleTicket(0, 100, 0, address(278));
    vm.startPrank(address(280));
    usdCoin.approve(address(ticketOffice), 10);
    vm.expectRevert("Event is Sold out");
    ticketOffice.mintSingleTicket(0, 1, 0, address(280));
    // Expect Revert if Ticket ID does not exist
    vm.expectRevert("Event Does Not Exist");
    ticketOffice.mintSingleTicket(45, 1, 0, address(280));
    // Expect Revert if Event is Locked
    vm.stopPrank();
    vm.startPrank(contractOwner);
    ticketOffice.lockEvent(0);
    vm.startPrank(address(280));
    vm.expectRevert("Concert Event is Frozen");
    ticketOffice.mintSingleTicket(0, 1, 0, address(280));

    // Expect Revert if Ticket Office is Locked
    vm.stopPrank();
    vm.startPrank(contractOwner);
    ticketOffice.closeTicketOffice();
    vm.startPrank(address(280));
    vm.expectRevert("Ticket Office is Closed");
    ticketOffice.mintSingleTicket(0, 1, 1, address(280));
  }

  function testMultipleMintTicketsPasses() public {
    // set up event, Set up wallets with USDC, and approve the contract to spend the USDC
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    vm.stopPrank();
    deal(address(usdCoin), address(278), 160);
    assertEq(usdCoin.balanceOf(address(278)), 160);
    vm.startPrank(address(278));
    usdCoin.approve(address(ticketOffice), 160);
    assertEq(usdCoin.allowance(address(278), address(ticketOffice)), 160);
    // Mint a ticket verify event logs
    uint256[] memory ticketIds = new uint256[](3);
    ticketIds[0] = 0;
    ticketIds[1] = 1;
    ticketIds[2] = 2;
    uint256[] memory amounts = new uint256[](3);
    amounts[0] = 1;
    amounts[1] = 1;
    amounts[2] = 1;
    vm.expectEmit();
    vm.startPrank(address(278));
    emit Transfer(address(278), contractAddress, 160);
    emit TransferBatch(contractAddress, address(0), address(278), ticketIds, amounts);
    emit TicketPurchased(address(278), 0, 0, 1);
    emit TicketPurchased(address(278), 0, 1, 1);
    emit TicketPurchased(address(278), 0, 2, 1);

    ticketOffice.mintMultipleTickets(0, ticketIds, amounts, address(278));
    //assertEq(usdCoin.balanceOf(address(278)),0);
    //assertEq(usdCoin.balanceOf(address(ticketOffice)),160);
    // Verify Ticket Balance
    address[] memory addressArray = new address[](3);
    addressArray[0] = address(278);
    addressArray[1] = address(278);
    addressArray[2] = address(278);
    uint256[] memory ticketIdArray = new uint256[](3);
    ticketIdArray[0] = 0;
    ticketIdArray[1] = 1;
    ticketIdArray[2] = 2;
    uint256[] memory balanceResult =
      ticketOffice.ticketHoldersBalance(0, addressArray, ticketIdArray);
    assertEq(balanceResult[0], 1);
    assertEq(balanceResult[1], 1);
    assertEq(balanceResult[2], 1);
    // Mint 4 more tickets
    deal(address(usdCoin), address(278), 1000);
    usdCoin.approve(address(ticketOffice), 1000);
    amounts[0] = 4;
    amounts[1] = 4;
    amounts[2] = 4;
    vm.expectEmit();
    emit Transfer(address(278), contractAddress, 640);
    emit TransferBatch(contractAddress, address(0), address(278), ticketIds, amounts);
    emit TicketPurchased(address(278), 0, 0, 4);
    emit TicketPurchased(address(278), 0, 1, 4);
    emit TicketPurchased(address(278), 0, 2, 4);
    ticketOffice.mintMultipleTickets(0, ticketIds, amounts, address(278));
    uint256[] memory balanceResult1 =
      ticketOffice.ticketHoldersBalance(0, addressArray, ticketIdArray);
    assertEq(balanceResult1[0], 5);
    assertEq(balanceResult1[1], 5);
    assertEq(balanceResult1[2], 5);
  }

  function testMultipleMintTicketsReverts() public {
    // Check Revert if Event not created
    uint256[] memory ticketIds = new uint256[](3);
    ticketIds[0] = 0;
    ticketIds[1] = 1;
    ticketIds[2] = 2;
    uint256[] memory amounts = new uint256[](3);
    amounts[0] = 1;
    amounts[1] = 1;
    amounts[2] = 1;
    vm.startPrank(address(278));
    vm.expectRevert("Event Does Not Exist");
    ticketOffice.mintMultipleTickets(0, ticketIds, amounts, address(278));
    // set up event, Set up wallets with USDC, and approve the contract to spend the USDC
    // Not Approved Reverts
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    vm.stopPrank();
    deal(address(usdCoin), address(278), 10 + 50 + 100);
    vm.startPrank(address(278));
    vm.expectRevert("ERC20: transfer amount exceeds allowance");
    ticketOffice.mintMultipleTickets(0, ticketIds, amounts, address(278));
    // insufficient USDC Reverts
    deal(address(usdCoin), address(278), 0);
    vm.startPrank(address(278));
    usdCoin.approve(address(ticketOffice), 10 * 100 + 50 * 50 + 100 * 10);
    vm.expectRevert("Insufficient Funds");
    ticketOffice.mintMultipleTickets(0, ticketIds, amounts, address(278));
    deal(address(usdCoin), address(278), 10 * 100 + 50 * 50 + 100 * 10);
    amounts[0] = 100;
    amounts[1] = 50;
    amounts[2] = 10;
    ticketOffice.mintMultipleTickets(0, ticketIds, amounts, address(278));
    deal(address(usdCoin), address(279), 10 + 50 + 100);
    amounts[0] = 1;
    amounts[1] = 1;
    amounts[2] = 1;
    vm.startPrank(address(279));
    usdCoin.approve(address(ticketOffice), 10 + 50 + 100);
    vm.expectRevert("Event is Sold out");
    ticketOffice.mintMultipleTickets(0, ticketIds, amounts, address(279));
    // Expect Revert if Ticket ID does not exist
    vm.expectRevert("Event Does Not Exist");
    ticketOffice.mintMultipleTickets(45, ticketIds, amounts, address(279));

    // Expect Revert if Event is Locked
    vm.stopPrank();
    vm.startPrank(contractOwner);
    ticketOffice.lockEvent(0);
    vm.startPrank(address(279));
    vm.expectRevert("Concert Event is Frozen");
    ticketOffice.mintMultipleTickets(0, ticketIds, amounts, address(279));
    vm.startPrank(contractOwner);
    ticketOffice.unLockEvent(0);
    vm.stopPrank();

    // expect revert is event is sold out
    deal(address(usdCoin), address(280), 100_000);
    vm.startPrank(address(280));
    usdCoin.approve(address(ticketOffice), 100_000);
    vm.expectRevert("Event is Sold out");
    amounts[0] = 500;
    amounts[1] = 500;
    amounts[2] = 500;
    ticketOffice.mintMultipleTickets(0, ticketIds, amounts, address(280));

    // Expect Revert if Ticket Office is Locked
    vm.stopPrank();
    vm.startPrank(contractOwner);
    ticketOffice.closeTicketOffice();
    vm.startPrank(address(279));
    vm.expectRevert("Ticket Office is Closed");
    ticketOffice.mintMultipleTickets(0, ticketIds, amounts, address(279));
  }

  function testEventLocked() public {
    uint256[] memory ticketIds = new uint256[](3);
    ticketIds[0] = 0;
    ticketIds[1] = 1;
    ticketIds[2] = 2;
    uint256[] memory amounts = new uint256[](3);
    amounts[0] = 1;
    amounts[1] = 1;
    amounts[2] = 1;
    deal(address(usdCoin), address(123), 50);
    deal(address(usdCoin), address(456), 100);
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    ticketOffice.compOne(0, address(123), 0);
    vm.stopPrank();
    vm.startPrank(ownerWallet);

    ticketOffice.lockEvent(0);
    vm.startPrank(address(123));
    usdCoin.approve(address(ticketOffice), 20_000);
    vm.expectRevert("Concert Event is Frozen");
    ticketOffice.mintSingleTicket(0, 1, 0, address(123));
    vm.expectRevert("Concert Event is Frozen");
    ticketOffice.mintMultipleTickets(0, ticketIds, amounts, address(123));
    vm.expectRevert("Concert Event is Frozen");
    vm.startPrank(address(123));
    ticketOffice.redeemTicket(0, 0);
    vm.stopPrank();
    vm.startPrank(contractOwner);
    ticketOffice.unLockEvent(0);
    vm.startPrank(address(123));
    vm.expectEmit();
    emit TicketPurchased(address(123), 0, 0, 1);
    ticketOffice.mintSingleTicket(0, 1, 0, address(123));
  }

  function testIssueRefund() public {
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    vm.stopPrank();
    deal(address(usdCoin), address(278), 60);
    assertEq(usdCoin.balanceOf(address(278)), 60);
    vm.startPrank(address(278));
    usdCoin.approve(address(ticketOffice), 60);
    uint256[] memory ticketIds = new uint256[](3);
    ticketIds[0] = 0;
    ticketIds[1] = 1;
    ticketIds[2] = 2;
    uint256[] memory amounts = new uint256[](3);
    amounts[0] = 1;
    amounts[1] = 1;
    amounts[2] = 0;
    ticketOffice.mintMultipleTickets(0, ticketIds, amounts, address(278));
    assertEq(usdCoin.balanceOf(address(278)), 0);
    address[] memory addressArray = new address[](3);
    addressArray[0] = address(278);
    addressArray[1] = address(278);
    addressArray[2] = address(278);
    uint256[] memory userTicketBalance =
      ticketOffice.ticketHoldersBalance(0, addressArray, ticketIds);
    assertEq(userTicketBalance[0], 1);
    assertEq(userTicketBalance[1], 1);
    assertEq(userTicketBalance[2], 0);
    vm.expectRevert("Refund Ineligible");
    ticketOffice.issueRefund(0);
    vm.stopPrank();
    vm.startPrank(ownerWallet);
    ticketOffice.lockEvent(0);
    vm.startPrank(address(278));
    ticketOffice.issueRefund(0);
    uint256[] memory userTicketBalanceAfter =
      ticketOffice.ticketHoldersBalance(0, addressArray, ticketIds);
    assertEq(userTicketBalanceAfter[0], 0);
    assertEq(userTicketBalanceAfter[1], 0);
    assertEq(userTicketBalanceAfter[2], 0);
    assertEq(usdCoin.balanceOf(address(278)), 60);
  }

  function testCompOneTickets() public {
    // set up event
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    // Set Up Comp One Ticket
    ticketOffice.compOne(0, address(278), 0);
    // Verify issedComp works
    bool result = ticketOffice.issuedComp(0, address(278), 0);
    assertTrue(result);
    bool voucherResult = ticketOffice.freeTicketVoucher(address(278), 0, 0);
    assertEq(voucherResult, true);
  }

  function testCompOneReverts() public {
    // Check Revert if Event not created
    vm.startPrank(address(278));
    vm.expectRevert("Unauthorized user");
    ticketOffice.compOne(0, address(278), 0);
    // set up event
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    vm.stopPrank();
    // reverts if not owner
    vm.startPrank(address(278));
    vm.expectRevert("Unauthorized user");
    ticketOffice.compOne(0, address(278), 0);
  }

  function testCompManyTickets() public {
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    address[] memory CompAddressArray = new address[](4);
    CompAddressArray[0] = address(279);
    CompAddressArray[1] = address(280);
    CompAddressArray[2] = address(281);
    CompAddressArray[3] = address(282);
    ticketOffice.compMany(0, CompAddressArray, 0);
    bool result279 = ticketOffice.issuedComp(0, address(279), 0);
    bool result280 = ticketOffice.issuedComp(0, address(280), 0);
    bool result281 = ticketOffice.issuedComp(0, address(281), 0);
    bool result282 = ticketOffice.issuedComp(0, address(282), 0);
    assertTrue(result279);
    assertTrue(result280);
    assertTrue(result281);
    assertTrue(result282);
  }

  function testCompManyReverts() public {
    // Check Revert if Event not created
    vm.startPrank(address(278));
    address[] memory CompAddressArray = new address[](4);
    CompAddressArray[0] = address(279);
    CompAddressArray[1] = address(280);
    CompAddressArray[2] = address(281);
    CompAddressArray[3] = address(282);
    vm.expectRevert();
    ticketOffice.compMany(0, CompAddressArray, 0);
    // set up event
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    vm.stopPrank();
    // Check Revert if not owner
    vm.startPrank(address(278));
    vm.expectRevert("Unauthorized user");
    ticketOffice.compMany(0, CompAddressArray, 0);
  }

  function testRedeemTickets() public {
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    ticketOffice.compOne(0, address(278), 0);
    //Test Comp One Ticket Refund
    vm.expectEmit();
    emit TransferSingle(contractAddress, address(0), address(278), 0, 1);
    emit TicketPurchased(address(278), 0, 0, 1);
    vm.startPrank(address(278));
    bool preRedeemResult = ticketOffice.issuedComp(0, address(278), 0);
    assertEq(preRedeemResult, true);
    ticketOffice.redeemTicket(0, 0);
    bool issuedResult = ticketOffice.issuedComp(0, address(278), 0);
    assertEq(issuedResult, false);
    console.log("issued Result: ", issuedResult);
  }

  function testRedeemTicketReverts() public {
    // test redeem reverts if no ticket comp
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    vm.startPrank(address(278));
    bool issuedResult = ticketOffice.issuedComp(0, address(278), 0);
    assertFalse(issuedResult);
    vm.expectRevert("Comp Ineligible");
    ticketOffice.redeemTicket(0, 0);
    vm.startPrank(ownerWallet);
    ticketOffice.compOne(0, address(279), 0);
    ticketOffice.lockEvent(0);
    vm.startPrank(address(279));
    vm.expectRevert("Concert Event is Frozen");
    ticketOffice.redeemTicket(0, 0);
  }

  function testRefund() public {
    // set up event
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    ticketOffice.compOne(0, address(280), 0);
    console.log(ticketOffice.freeTicketVoucher(address(280), 0, 0));
    vm.stopPrank();
    // set up wallets with USDC, and approve the contract to spend the USDC
    deal(address(usdCoin), address(278), 160);
    deal(address(usdCoin), address(279), 160);
    deal(address(usdCoin), address(280), 0);
    vm.startPrank(address(278));
    usdCoin.approve(address(ticketOffice), 160);
    vm.startPrank(address(279));
    usdCoin.approve(address(ticketOffice), 160);

    // set up multiple ticket buys
    uint256[] memory ticketIds = new uint256[](3);
    ticketIds[0] = 0;
    ticketIds[1] = 1;
    ticketIds[2] = 2;
    uint256[] memory amounts = new uint256[](3);
    amounts[0] = 1;
    amounts[1] = 1;
    amounts[2] = 1;
    vm.startPrank(address(278));
    ticketOffice.mintMultipleTickets(0, ticketIds, amounts, address(278));
    vm.startPrank(address(279));
    console.log("CHECK MSG SENDER", msg.sender);
    ticketOffice.mintMultipleTickets(0, ticketIds, amounts, address(279));
    vm.startPrank(address(280));
    console.log("TICKET VOUCHER", ticketOffice.freeTicketVoucher(address(280), 0, 0));
    ticketOffice.redeemTicket(0, 0);
    vm.stopPrank();
    vm.startPrank(ownerWallet);
    ticketOffice.lockEvent(0);
    // issue refunds
    vm.startPrank(address(278));
    ticketOffice.issueRefund(0);
    // verify user 278 has no tickets and has been refunded
    address[] memory addressArray = new address[](3);
    addressArray[0] = address(278);
    addressArray[1] = address(278);
    addressArray[2] = address(278);
    uint256[] memory userTicketBalance =
      ticketOffice.ticketHoldersBalance(0, addressArray, ticketIds);
    assertEq(userTicketBalance[0], 0);
    assertEq(userTicketBalance[1], 0);
    assertEq(userTicketBalance[2], 0);
    assertEq(usdCoin.balanceOf(address(278)), 160);
    //assertEq(usdCoin.balanceOf(address(279)), 160);
    // verify user 279 has tickets and has not been refunded
    vm.startPrank(address(279));
    ticketOffice.issueRefund(0);
    addressArray[0] = address(279);
    addressArray[1] = address(279);
    addressArray[2] = address(279);
    uint256[] memory userTicketBalance279 =
      ticketOffice.ticketHoldersBalance(0, addressArray, ticketIds);
    assertEq(userTicketBalance279[0], 0);
    assertEq(userTicketBalance279[1], 0);
    assertEq(userTicketBalance279[2], 0);
    assertEq(usdCoin.balanceOf(address(279)), 160);

    // ensure comped ticket receives no refund

    vm.startPrank(address(280));
    vm.expectRevert("Refund Ineligible");
    ticketOffice.issueRefund(0);
    //assertEq(usdCoin.balanceOf(address(280)),0);
  }

  function testAddTreasurer() public {
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    ticketOffice.approveTreasurer(0, address(123));
    address treasurer = ticketOffice.getTreasurer(0);
    assertEq(treasurer, address(123));
  }

  function testAddTreasurerReverts() public {
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    vm.stopPrank();
    vm.startPrank(address(123));
    vm.expectRevert("Unauthorized user");
    ticketOffice.approveTreasurer(0, address(123));
  }

  function testEditEvents() public {
    vm.startPrank(ownerWallet);
    vm.expectEmit();
    emit Event(
      0,
      eventName,
      address(0x3f739c53777872fe22B8ecebBe7Fa798ff987B5C),
      baseUrl,
      ticketDetails,
      eventDate,
      location,
      groups,
      keywords,
      categories,
      description,
      eventType
    );
    ticketOffice.createEvent(details, ticketDetails, baseUrl);

    // Test Name Change Works
    editDetails = TicketStructs.Ticketdetails({
      name: "NEW EVENT NAME",
      owner: ownerWallet,
      eventDate: eventDate,
      ticketInformation: ticketDetails,
      locationDetails: location,
      performers: groups,
      keywords: keywords,
      categories: categories,
      eventDescription: description,
      eventType: eventType
    });
    vm.expectEmit();
    emit Event(
      0,
      "NEW EVENT NAME",
      address(0x3f739c53777872fe22B8ecebBe7Fa798ff987B5C),
      baseUrl,
      ticketDetails,
      eventDate,
      location,
      groups,
      keywords,
      categories,
      description,
      eventType
    );
    ticketOffice.editEvent(0, editDetails);

    // test eventDate Works
    editDetails.eventDate = eventDate + 86_400 * 3; // add 3 days to event date
    vm.expectEmit();
    emit Event(
      0,
      "NEW EVENT NAME",
      address(0x3f739c53777872fe22B8ecebBe7Fa798ff987B5C),
      baseUrl,
      ticketDetails,
      editDetails.eventDate,
      location,
      groups,
      keywords,
      categories,
      description,
      eventType
    );
    ticketOffice.editEvent(0, editDetails);

    // test Location Details Works
    editLocation =
      TicketStructs.LocationDetails({ concertLocation: "NEW COORDINATES", venueName: "NEW VENUE" });
    editDetails.locationDetails = editLocation;
    vm.expectEmit();
    emit Event(
      0,
      "NEW EVENT NAME",
      address(0x3f739c53777872fe22B8ecebBe7Fa798ff987B5C),
      baseUrl,
      ticketDetails,
      editDetails.eventDate,
      editLocation,
      groups,
      keywords,
      categories,
      description,
      eventType
    );
    ticketOffice.editEvent(0, editDetails);
    // test performers works
    string[] memory newGroups = new string[](3);
    newGroups[0] = "SHARK ATTACK";
    newGroups[1] = "THE SHARKS";
    newGroups[2] = "SHARKS IN THE WATER";
    editDetails.performers = newGroups;
    vm.expectEmit();
    emit Event(
      0,
      "NEW EVENT NAME",
      address(0x3f739c53777872fe22B8ecebBe7Fa798ff987B5C),
      baseUrl,
      ticketDetails,
      editDetails.eventDate,
      editLocation,
      newGroups,
      keywords,
      categories,
      description,
      eventType
    );
    ticketOffice.editEvent(0, editDetails);

    // test keywords works
    string[] memory newKeywords = new string[](3);
    newKeywords[0] = "SHARKS";
    newKeywords[1] = "SHARK ATTACK";
    newKeywords[2] = "SHARKS IN THE WATER";
    editDetails.keywords = newKeywords;
    vm.expectEmit();
    emit Event(
      0,
      "NEW EVENT NAME",
      address(0x3f739c53777872fe22B8ecebBe7Fa798ff987B5C),
      baseUrl,
      ticketDetails,
      editDetails.eventDate,
      editLocation,
      newGroups,
      newKeywords,
      categories,
      description,
      eventType
    );
    ticketOffice.editEvent(0, editDetails);
    // test categories works
    string[] memory newCategories = new string[](3);
    newCategories[0] = "SHARKS";
    newCategories[1] = "SHARK ATTACK";
    newCategories[2] = "SHARKS IN THE WATER";
    editDetails.categories = newCategories;
    vm.expectEmit();
    emit Event(
      0,
      "NEW EVENT NAME",
      address(0x3f739c53777872fe22B8ecebBe7Fa798ff987B5C),
      baseUrl,
      ticketDetails,
      editDetails.eventDate,
      editLocation,
      newGroups,
      newKeywords,
      newCategories,
      description,
      eventType
    );
    ticketOffice.editEvent(0, editDetails);
    // test description works
    string memory newDescription = "This is a new description for the event.";
    editDetails.eventDescription = newDescription;
    vm.expectEmit();
    emit Event(
      0,
      "NEW EVENT NAME",
      address(0x3f739c53777872fe22B8ecebBe7Fa798ff987B5C),
      baseUrl,
      ticketDetails,
      editDetails.eventDate,
      editLocation,
      newGroups,
      newKeywords,
      newCategories,
      newDescription,
      eventType
    );
    ticketOffice.editEvent(0, editDetails);
    // test Event Type works
    editDetails.eventType = "NEW TYPE OF THING";
    vm.expectEmit();
    emit Event(
      0,
      "NEW EVENT NAME",
      address(0x3f739c53777872fe22B8ecebBe7Fa798ff987B5C),
      baseUrl,
      ticketDetails,
      editDetails.eventDate,
      editLocation,
      newGroups,
      newKeywords,
      newCategories,
      newDescription,
      "NEW TYPE OF THING"
    );
    ticketOffice.editEvent(0, editDetails);

    // ensure that ticket details are not changed
    TicketStructs.Tickets memory oldTicketDetails = editDetails.ticketInformation;
    string[] memory newTicketNames = new string[](4);
    newTicketNames[0] = "VIP";
    newTicketNames[1] = "General Admission";
    newTicketNames[2] = "Early Bird";
    newTicketNames[3] = "Last Minute";
    uint256[] memory newTicketPrices = new uint256[](4);
    newTicketPrices[0] = 100;
    newTicketPrices[1] = 50;
    newTicketPrices[2] = 25;
    newTicketPrices[3] = 10;
    uint256[] memory newTicketCapacities = new uint256[](4);
    newTicketCapacities[0] = 100;
    newTicketCapacities[1] = 200;
    newTicketCapacities[2] = 300;
    newTicketCapacities[3] = 400;
    uint256[] memory newTicketQuantities = new uint256[](4);
    newTicketQuantities[0] = 0;
    newTicketQuantities[1] = 0;
    newTicketQuantities[2] = 0;
    newTicketQuantities[3] = 0;
    TicketStructs.Tickets memory newTicketDetails = TicketStructs.Tickets({
      ticketNames: newTicketNames,
      ticketCapacities: newTicketCapacities,
      ticketPrices: newTicketPrices,
      ticketsSold: newTicketQuantities
    });
    editDetails.ticketInformation = newTicketDetails;
    vm.expectEmit();
    emit Event(
      0,
      "NEW EVENT NAME",
      address(0x3f739c53777872fe22B8ecebBe7Fa798ff987B5C),
      baseUrl,
      oldTicketDetails,
      editDetails.eventDate,
      editLocation,
      newGroups,
      newKeywords,
      newCategories,
      newDescription,
      "NEW TYPE OF THING"
    );
    ticketOffice.editEvent(0, editDetails);
  }

  function testEditEventReverts() public {
    // check revert if Event does not exist
    vm.startPrank(address(123));
    TicketStructs.Ticketdetails memory newDetails = TicketStructs.Ticketdetails({
      name: "NEW EVENT NAME",
      owner: address(123),
      eventDate: block.timestamp + 86_400 * 5,
      ticketInformation: ticketDetails,
      locationDetails: location,
      performers: groups,
      keywords: keywords,
      categories: categories,
      eventDescription: description,
      eventType: eventType
    });
    vm.expectRevert("Unauthorized user");
    ticketOffice.editEvent(0, newDetails);

    // check revert if not owner
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    vm.stopPrank();
    vm.startPrank(address(123));
    vm.expectRevert("Unauthorized user");
    ticketOffice.editEvent(0, newDetails);
    // check revert is event is locked
    vm.startPrank(ownerWallet);
    ticketOffice.lockEvent(0);
    vm.expectRevert("Concert Event is Frozen");
    ticketOffice.editEvent(0, newDetails);
    vm.startPrank(contractOwner);
    ticketOffice.unLockEvent(0);
    // check revert if swap in owner
    vm.startPrank(ownerWallet);
    vm.expectRevert("Unauthorized OwnerSwap");
    ticketOffice.editEvent(0, newDetails);

    // revert if event date is behind current date
    newDetails.eventDate = block.timestamp - 86_400 * 5; // set event date to 5 days in the past
    vm.expectRevert("Invalid Date");
    ticketOffice.editEvent(0, newDetails);
  }

  function testRevokeTicket() public {
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    vm.startPrank(address(278));
    deal(address(usdCoin), address(278), 160);
    assertEq(usdCoin.balanceOf(address(278)), 160);
    usdCoin.approve(contractAddress, 160);
    ticketOffice.mintSingleTicket(0, 1, 0, address(278));
    bool result = ticketOffice.isTicketHolder(0, address(278), 0);
    assertTrue(result, "Ticket Holder should be true before revoking ticket");
    vm.stopPrank();
    vm.startPrank(contractOwner);
    ticketOffice.revokeTickets(address(278), 0, 0, 1);
    bool resultAfter = ticketOffice.isTicketHolder(0, address(278), 0);
    assertFalse(resultAfter, "Ticket Holder should be false after revoking ticket");
  }

  function testRevokeTicketReverts() public {
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    vm.startPrank(address(278));
    deal(address(usdCoin), address(278), 1000);
    usdCoin.approve(contractAddress, 1000);
    ticketOffice.mintSingleTicket(0, 1, 0, address(278));
    vm.startPrank(address(478));
    vm.expectRevert("Unauthorized Access");
    ticketOffice.revokeTickets(address(278), 0, 0, 1);
    // reverts if revoking more than user balance
    vm.startPrank(contractOwner);
    vm.expectRevert();
    ticketOffice.revokeTickets(address(278), 0, 0, 2);
  }

  // function testAddPerformers() public {
  //     vm.startPrank(ownerWallet);
  //     ticketOffice.createEvent(details, baseUrl);
  //     vm.expectEmit();
  //     string[] memory newGroups = new string[](3);
  //     newGroups[0] = "the Beasty Boys";
  //     newGroups[1] = "Mc5";
  //     newGroups[2] = "The Rolling Stones";
  //     emit Event(0,eventName, address(0x104fBc016F4bb334D775a19E8A6510109AC63E00),baseUrl,ticketNames,ticketPrices,ticketCapacities,eventDate,location,newGroups,keywords,categories,eventType);
  //     string[] memory results = ticketOffice.addPerformers(0, "The Rolling Stones");
  //     assertEq(results[0], "the Beasty Boys");
  //     assertEq(results[1], "Mc5");
  //     assertEq(results[2], "The Rolling Stones");
  // }

  // function testRemovePerformers() public {
  //     vm.startPrank(ownerWallet);
  //     ticketOffice.createEvent(details, baseUrl);
  //     vm.expectEmit();
  //     string[] memory newGroups = new string[](1);
  //     newGroups[0] = "the Beasty Boys";
  //     emit Event(0,eventName, address(0x104fBc016F4bb334D775a19E8A6510109AC63E00),baseUrl,ticketNames,ticketPrices,ticketCapacities,eventDate,location,newGroups,keywords,categories,eventType);
  //     string[] memory results = ticketOffice.removePerformers(0, 1);
  //     assertEq(results[0],"the Beasty Boys");

  // }

  // function testChangeLocation() public {
  //     vm.startPrank(ownerWallet);
  //     ticketOffice.createEvent(details, baseUrl);
  //     string memory result = ticketOffice.getEventLocation(0);
  //     assertEq(result, location);
  //     vm.expectEmit();
  //     emit Event(0,eventName, address(0x104fBc016F4bb334D775a19E8A6510109AC63E00),baseUrl,ticketNames,ticketPrices,ticketCapacities,eventDate,"Antartica",groups,keywords,categories,eventType);
  //     string memory result1 = ticketOffice.changeLocation(0, "Antartica");
  //     assertEq(result1, "Antartica");
  // }

  // function testChangeEventDate() public {
  //     // Event Date is 5 days from present block time stamp
  //     uint256 oneDay = 86400 * 3;
  //     vm.startPrank(ownerWallet);
  //     ticketOffice.createEvent(details, baseUrl);
  //     uint256 result = ticketOffice.getEventDate(0);
  //     assertEq(result, eventDate, "The top Assert Failed");
  //     vm.expectEmit();
  //     emit Event(0,eventName, address(0x104fBc016F4bb334D775a19E8A6510109AC63E00),baseUrl,ticketNames,ticketPrices,ticketCapacities,eventDate + oneDay * 3,location,groups,keywords,categories,eventType);
  //     // add three days to event date 3 + 5 days equals 8 days
  //     uint256 result1 = ticketOffice.changeEventDate(0, eventDate + oneDay * 3);
  //     console.log("initial Date Change value:", result1);
  //     assertEq(result1, eventDate + oneDay * 3, "the Bottom Assert Failed");
  //     // assert Event won't change if date is within 3 days.
  //     // cheat date  to 6 days from present block time stamp, two days before event Date
  //     vm.warp(block.timestamp + oneDay * 6);
  //     vm.expectRevert("Date change within Locked Period");
  //     ticketOffice.changeEventDate(0, block.timestamp + 86400);
  //     //Cheat date back to 5 days from present block time so that event date can be changed
  //     vm.warp(block.timestamp - oneDay * 6);
  //     uint256 timeCheck = ticketOffice.getEventDate(0);
  //     console.log("event date: ", eventDate);
  //     console.log("Time Check: ", timeCheck);
  //     console.log("time Check minus 3 days",timeCheck - 172800);
  //     console.log(timeCheck - 172800, block.timestamp + (oneDay * 4));
  //     vm.warp(block.timestamp + oneDay * 4);
  //     vm.expectEmit();
  //     emit Event(0,eventName, address(0x104fBc016F4bb334D775a19E8A6510109AC63E00),baseUrl,ticketNames,ticketPrices,ticketCapacities,eventDate + oneDay * 4,location,groups,keywords,categories, eventType);
  //      uint256 result2 = ticketOffice.changeEventDate(0, eventDate + oneDay * 4 );
  //     assertEq(result2, eventDate + oneDay * 4);
  //  }

  function testChangeUri() public {
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    string memory result = ticketOffice.getEventName(0);
    assertEq(result, eventName);

    string memory result1 = ticketOffice.changeUri(0, "Cheers Finance");
    assertEq(result1, "Cheers Finance");
    address result2 = ticketOffice.getAddress(0);
    string memory tokenUri = ERC1155Token(result2).uri();
    assertEq(tokenUri, "Cheers Finance");
  }

  function testChangeUriReverts() public {
    // Check Revert if Event not created
    vm.startPrank(address(278));
    vm.expectRevert("Unauthorized user");
    ticketOffice.changeUri(0, "Cheers Finance");
    // set up event
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    vm.stopPrank();
    // Check Revert if not owner
    vm.startPrank(address(278));
    vm.expectRevert("Unauthorized user");
    ticketOffice.changeUri(0, "Cheers Finance");
  }

  function testWithdrawFunds() public {
    // set up event
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    // set up 3 wallets to buy tickets
    deal(address(usdCoin), address(123), 160);
    deal(address(usdCoin), address(456), 160 * 2);
    deal(address(usdCoin), address(789), 160 * 3);
    // approve wallets to spend USDC
    vm.startPrank(address(123));
    usdCoin.approve(contractAddress, 160);
    vm.startPrank(address(456));
    usdCoin.approve(contractAddress, 160 * 2);
    vm.startPrank(address(789));
    usdCoin.approve(contractAddress, 160 * 3);
    // mint tickets
    uint256[] memory ticketIds = new uint256[](3);
    ticketIds[0] = 0;
    ticketIds[1] = 1;
    ticketIds[2] = 2;
    uint256[] memory amounts = new uint256[](3);
    amounts[0] = 1;
    amounts[1] = 1;
    amounts[2] = 1;
    vm.startPrank(address(123));
    ticketOffice.mintMultipleTickets(0, ticketIds, amounts, address(123));
    vm.startPrank(address(456));
    amounts[0] = 2;
    amounts[1] = 2;
    amounts[2] = 2;
    ticketOffice.mintMultipleTickets(0, ticketIds, amounts, address(456));
    vm.startPrank(address(789));
    amounts[0] = 3;
    amounts[1] = 3;
    amounts[2] = 3;
    ticketOffice.mintMultipleTickets(0, ticketIds, amounts, address(789));
    //verify usdc balance on contract
    assertEq(usdCoin.balanceOf(contractAddress), 160 * 6);
    // verify function returns correct amount
    uint256 eventBalance = ticketOffice.getEventFunds(0);
    assertEq(eventBalance, 160 * 6);
    // withdraw funds
    vm.warp(eventDate + 86_400 * 3);
    vm.startPrank(ownerWallet);
    ticketOffice.withdrawFunds(0);
    // verify usdc balance on contract is 0
    assertEq(usdCoin.balanceOf(contractAddress), 0);
    // verify usdc balance transfer correctly
    assertEq(usdCoin.balanceOf(ownerWallet), 160 * 6 * 0.95);
    assertEq(usdCoin.balanceOf(contractOwner), 160 * 6 * 0.05);
  }

  function testWithdrawFunctionReverts() public {
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    vm.stopPrank();
    deal(address(usdCoin), address(123), 160);
    deal(address(usdCoin), address(456), 160 * 2);
    deal(address(usdCoin), address(789), 160 * 3);
    // approve wallets to spend USDC
    vm.startPrank(address(123));
    usdCoin.approve(contractAddress, 160);
    vm.startPrank(address(456));
    usdCoin.approve(contractAddress, 160 * 2);
    vm.startPrank(address(789));
    usdCoin.approve(contractAddress, 160 * 3);
    // mint tickets
    uint256[] memory ticketIds = new uint256[](3);
    ticketIds[0] = 0;
    ticketIds[1] = 1;
    ticketIds[2] = 2;
    uint256[] memory amounts = new uint256[](3);
    amounts[0] = 1;
    amounts[1] = 1;
    amounts[2] = 1;
    vm.startPrank(address(123));
    ticketOffice.mintMultipleTickets(0, ticketIds, amounts, address(123));
    vm.startPrank(address(456));
    amounts[0] = 2;
    amounts[1] = 2;
    amounts[2] = 2;
    ticketOffice.mintMultipleTickets(0, ticketIds, amounts, address(456));
    vm.startPrank(address(789));
    amounts[0] = 3;
    amounts[1] = 3;
    amounts[2] = 3;
    ticketOffice.mintMultipleTickets(0, ticketIds, amounts, address(789));
    //verify usdc balance on contract
    assertEq(usdCoin.balanceOf(contractAddress), 160 * 6);
    // verify function returns correct amount
    uint256 eventBalance = ticketOffice.getEventFunds(0);
    assertEq(eventBalance, 160 * 6);
    vm.startPrank(ownerWallet);
    ticketOffice.lockEvent(0);
    bool results = ticketOffice.eventLocked(0);
    assertTrue(results);
    console.log("Event Locked: ", results);
    vm.expectRevert("Withdraw must be one day after Event");
    ticketOffice.withdrawFunds(0);

    // Check Revert if Event not created
    vm.startPrank(address(123));
    vm.expectRevert();
    ticketOffice.withdrawFunds(1);
    // Check Revert if not owner
    vm.stopPrank();
    vm.startPrank(contractOwner);
    ticketOffice.unLockEvent(0);
    vm.warp(eventDate + 86_400 * 6);
    vm.startPrank(address(123));
    vm.expectRevert("Unauthorized Access");
    ticketOffice.withdrawFunds(0);
  }

  function testRevokeTickets() public {
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    vm.startPrank(address(123));
    deal(address(usdCoin), address(123), 100);
    usdCoin.approve(contractAddress, 100);
    ticketOffice.mintSingleTicket(0, 1, 2, address(123));
    vm.stopPrank();
    vm.startPrank(contractOwner);
    ticketOffice.revokeTickets(address(123), 0, 2, 1);
    address[] memory addressArray = new address[](1);
    addressArray[0] = address(123);
    uint256[] memory ticketIdArray = new uint256[](1);
    ticketIdArray[0] = 2;
    uint256[] memory balanceResult =
      ticketOffice.ticketHoldersBalance(0, addressArray, ticketIdArray);
    // Veryfy ticket is revoked and user balance is 0.
    assertEq(balanceResult[0], 0);
  }

  function testCloseTicketOffice() public {
    vm.startPrank(address(999));
    vm.expectRevert("Unauthorized Access");
    ticketOffice.closeTicketOffice();
    vm.stopPrank();
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    vm.startPrank(address(123));
    deal(address(usdCoin), address(123), 100);
    usdCoin.approve(contractAddress, 100);
    ticketOffice.mintSingleTicket(0, 1, 2, address(123));
    vm.stopPrank();
    vm.startPrank(contractOwner);
    ticketOffice.closeTicketOffice();
    vm.startPrank(address(123));
    // expect mint single reverts
    vm.expectRevert("Ticket Office is Closed");
    ticketOffice.mintSingleTicket(0, 1, 2, address(123));
    // expect mint multiple reverts
    vm.expectRevert("Ticket Office is Closed");
    uint256[] memory ticketIds = new uint256[](3);
    ticketIds[0] = 0;
    ticketIds[1] = 1;
    ticketIds[2] = 2;
    uint256[] memory amounts = new uint256[](3);
    amounts[0] = 1;
    amounts[1] = 1;
    amounts[2] = 1;
    ticketOffice.mintMultipleTickets(0, ticketIds, amounts, address(123));
    //expect create event reverts
    vm.stopPrank();
    vm.startPrank(address(678));
    vm.expectRevert("Ticket Office is Closed");
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    //expect redeem ticket reverts
    vm.expectRevert("Ticket Office is Closed");
    ticketOffice.redeemTicket(0, 2);
    // expect change treasurer reverts
    vm.startPrank(ownerWallet);
    vm.expectRevert("Ticket Office is Closed");
    ticketOffice.approveTreasurer(0, address(123));
    // expect compone reverts
    vm.expectRevert("Ticket Office is Closed");
    ticketOffice.compOne(0, address(123), 2);
    // expect comp many reverts
    vm.expectRevert("Ticket Office is Closed");
    address[] memory CompAddressArray = new address[](4);
    CompAddressArray[0] = address(279);
    CompAddressArray[1] = address(280);
    CompAddressArray[2] = address(281);
    CompAddressArray[3] = address(282);
    ticketOffice.compMany(0, CompAddressArray, 2);
    // expect issue refund reverts
    vm.expectRevert("Ticket Office is Closed");
    ticketOffice.issueRefund(0);
    // expect revoke tickets reverts
    vm.expectRevert("Ticket Office is Closed");
    vm.stopPrank();
    ticketOffice.revokeTickets(address(123), 0, 2, 1);
    // expect withdraw funds reverts
    vm.expectRevert("Ticket Office is Closed");
    vm.startPrank(ownerWallet);
    ticketOffice.withdrawFunds(0);

    // expects add performers reverts
    //vm.expectRevert("Ticket Office is Closed");

    //ticketOffice.addPerformers(0, "The Rolling Stones");
    //expect remove performers reverts
    //vm.expectRevert("Ticket Office is Closed");
    //ticketOffice.removePerformers(0, 1);
    // expect change location reverts
    //vm.expectRevert("Ticket Office is Closed");
    //ticketOffice.changeLocation(0, "Antartica");
    // expect change event date reverts
    //vm.expectRevert("Ticket Office is Closed");
    //ticketOffice.changeEventDate(0, eventDate + 86400 * 3);
    // expect change uri reverts
    vm.expectRevert("Ticket Office is Closed");
    ticketOffice.changeUri(0, "Cheers Finance");
  }

  function testLockEvent() public {
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    vm.startPrank(address(123));
    deal(address(usdCoin), address(123), 100);
    usdCoin.approve(contractAddress, 100);
    ticketOffice.mintSingleTicket(0, 1, 2, address(123));
    vm.stopPrank();
    vm.startPrank(contractOwner);
    ticketOffice.lockEvent(0);
    vm.startPrank(address(123));
    // expect mint single reverts
    vm.expectRevert("Concert Event is Frozen");
    ticketOffice.mintSingleTicket(0, 1, 2, address(123));
    // expect mint multiple reverts
    vm.expectRevert("Concert Event is Frozen");
    uint256[] memory ticketIds = new uint256[](3);
    ticketIds[0] = 0;
    ticketIds[1] = 1;
    ticketIds[2] = 2;
    uint256[] memory amounts = new uint256[](3);
    amounts[0] = 1;
    amounts[1] = 1;
    amounts[2] = 1;
    ticketOffice.mintMultipleTickets(0, ticketIds, amounts, address(123));
    vm.startPrank(address(678));
    //expect redeem ticket reverts
    vm.expectRevert("Comp Ineligible");
    ticketOffice.redeemTicket(0, 2);
    // expect change treasurer reverts
    vm.startPrank(ownerWallet);
    vm.expectRevert("Concert Event is Frozen");
    ticketOffice.approveTreasurer(0, address(123));
    // expect compone reverts
    vm.expectRevert("Concert Event is Frozen");
    ticketOffice.compOne(0, address(123), 2);
    // expect comp many reverts
    vm.expectRevert("Concert Event is Frozen");
    address[] memory CompAddressArray = new address[](4);
    CompAddressArray[0] = address(279);
    CompAddressArray[1] = address(280);
    CompAddressArray[2] = address(281);
    CompAddressArray[3] = address(282);
    ticketOffice.compMany(0, CompAddressArray, 2);
    // Expect Lock To work for contract owner
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    vm.startPrank(contractOwner);
    ticketOffice.lockEvent(1);
    vm.startPrank(address(123));
    vm.expectRevert("Concert Event is Frozen");
    ticketOffice.mintSingleTicket(1, 1, 2, address(123));
  }

  function testLockEventReverts() public {
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    vm.stopPrank();
    vm.startPrank(address(567));
    vm.expectRevert("Unauthorized Access");
    ticketOffice.lockEvent(0);
  }

  function testUnlockEvent() public {
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    console.log("INITIAL WITHDRAW", usdCoin.balanceOf(ownerWallet));
    vm.startPrank(address(123));
    deal(address(usdCoin), address(123), 1000);
    usdCoin.approve(contractAddress, 1000);
    ticketOffice.mintSingleTicket(0, 1, 2, address(123));
    // fund amount is 100
    vm.stopPrank();
    vm.startPrank(contractOwner);
    ticketOffice.lockEvent(0);
    vm.startPrank(address(123));
    // expect mint single reverts
    vm.expectRevert("Concert Event is Frozen");
    ticketOffice.mintSingleTicket(0, 1, 2, address(123));
    // expect mint multiple reverts
    vm.expectRevert("Concert Event is Frozen");
    uint256[] memory ticketIds = new uint256[](3);
    ticketIds[0] = 0;
    ticketIds[1] = 1;
    ticketIds[2] = 2;
    uint256[] memory amounts = new uint256[](3);
    amounts[0] = 1;
    amounts[1] = 1;
    amounts[2] = 1;
    ticketOffice.mintMultipleTickets(0, ticketIds, amounts, address(123));

    // unlock event
    vm.startPrank(contractOwner);
    ticketOffice.unLockEvent(0);

    // expect mint single works
    vm.startPrank(address(123));
    ticketOffice.mintSingleTicket(0, 1, 2, address(123));
    // event funds are 200 now.
    // expect mint multiple works
    uint256[] memory newAmounts = new uint256[](3);
    newAmounts[0] = 1;
    newAmounts[1] = 1;
    newAmounts[2] = 1;
    ticketOffice.mintMultipleTickets(0, ticketIds, newAmounts, address(123));
    console.log("EVENT VALUE", ticketOffice.getEventFunds(0));
    // 200 + 100 + 50 + 10 = 360
    // 360 * 0.95 = 342

    // expect withdraw funds works
    vm.startPrank(ownerWallet);
    vm.warp(eventDate + 86_400 * 3);
    ticketOffice.withdrawFunds(0);
    console.log("WITHDRAW AMOUNT", usdCoin.balanceOf(ownerWallet));
  }

  function testunlockEventReverts() public {
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(details, ticketDetails, baseUrl);
    vm.stopPrank();
    vm.startPrank(address(567));
    vm.expectRevert("Unauthorized Access");
    ticketOffice.unLockEvent(0);
    // Check Revert if Event not created
    vm.startPrank(contractOwner);
    vm.expectRevert("Event Does Not Exist");
    ticketOffice.unLockEvent(4);
  }
}
