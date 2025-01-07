// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "lib/forge-std/src/Test.sol";
import "src/TicketOffice.sol";
import "src/interfaces/IERC20.sol";

contract TicketOfficeTest2 is Test {
    TicketOffice public ticketOffice;
    ERC1155Token public ERC1155ConcertToken; 
    IERC20 public usdCoin;
    address public contractOwner;
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
    uint256 public eventDate = block.timestamp + 432000;
    string public location = "The Astrodome";
    string[] public groups = ["the Beasty Boys", "Mc5"]; 
    string[] public keywords = ["music", "festival", "rock"];

    // Ticket Office Events
     event Event(uint256 indexed eventIdCounter, string name, address contractAddress, string[] ticketNames ,uint256[] ticketPrices, uint256[] ticketCapacities,
      uint256 eventDate, string concertLocation, string[] performers, string[] keywords);

     event TicketPurchased(address indexed buyer, uint256 indexed eventId, uint256 indexed ticketId, uint256 quantity);

    // ERC20 (USDCOIN) Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // ERC1155 Events
    event TransferSingle (address operator, address from, address to, uint256 id, uint256 value);
    event TransferBatch (address operator, address from, address to, uint256[] ids, uint256[] values);

    function setUp() public {
        ticketOffice = new TicketOffice(name,0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        usdCoin = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        contractOwner = address(this);
        contractAddress = address(ticketOffice);
    }
    
    function testGetContractName() public {
        string memory resultName = ticketOffice.name();
        assertEq(resultName, name);
    }

    function testGetContractOwner() public {
        address resultAddress = ticketOffice.contractOwner();
        assertEq(resultAddress, contractOwner);
    }

    function testCreateEvent() public {
        vm.startPrank(ownerWallet);
        vm.expectEmit();
        emit Event(0,name, address(0x104fBc016F4bb334D775a19E8A6510109AC63E00),ticketNames,ticketPrices,ticketCapacities,eventDate,location,groups,keywords);
        ticketOffice.createEvent(name, baseUrl, ticketNames, ticketPrices, ticketCapacities, eventDate, location, groups, keywords);
        vm.stopPrank();
        
    }

    function testGetEventName() public {
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, ticketNames, ticketPrices, ticketCapacities, eventDate, location, groups, keywords);
        string memory result = ticketOffice.getEventName(0);
        assertEq(result, name);
    }

    function testGetIsEventOwner() public {
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, ticketNames, ticketPrices, ticketCapacities, eventDate, location, groups, keywords);
        bool trueResult = ticketOffice.isEventOwner(0, ownerWallet);
        assertTrue(trueResult);
        bool falseResult = ticketOffice.isEventOwner(0, address(2));
        assertFalse(falseResult);
    }

    function testGetEvent1155Address() public {
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, ticketNames, ticketPrices, ticketCapacities, eventDate, location, groups, keywords);
        address result = ticketOffice.getAddress(0);
        assertEq(result, address(0x104fBc016F4bb334D775a19E8A6510109AC63E00));
        address result2 = ticketOffice.getAddress(1);
        assertEq(result2, address(0));
    }

    function testGetTicketNames() public {
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, ticketNames, ticketPrices, ticketCapacities, eventDate, location, groups, keywords);
        string[] memory result = ticketOffice.getTicketNames(0);
        assertEq(result[0], ticketNames[0]);
        assertEq(result[1], ticketNames[1]);
        assertEq(result[2], ticketNames[2]);
    }

    function testGetTicketPrices() public {
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, ticketNames, ticketPrices, ticketCapacities, eventDate, location, groups, keywords);
        uint256[] memory result = ticketOffice.getTicketPrices(0);
        assertEq(result[0], ticketPrices[0]);
        assertEq(result[1], ticketPrices[1]);
        assertEq(result[2], ticketPrices[2]);
    }

    function testGetTicketPrice() public {
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, ticketNames, ticketPrices, ticketCapacities, eventDate, location, groups, keywords);
        uint256 result = ticketOffice.getTicketPrice(0, 0);
        assertEq(result, ticketPrices[0]);
    }

    function testGetTicketCapacities() public {
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, ticketNames, ticketPrices, ticketCapacities, eventDate, location, groups, keywords);
        uint256[] memory result = ticketOffice.getEventCapacities(0);
        assertEq(result[0], ticketCapacities[0]);
        assertEq(result[1], ticketCapacities[1]);
        assertEq(result[2], ticketCapacities[2]);
    }
    function testGetTicketCapacity() public {
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, ticketNames, ticketPrices, ticketCapacities, eventDate, location, groups, keywords);
        uint256 result = ticketOffice.getEventCapacity(0, 0);
        assertEq(result, ticketCapacities[0]);
    }

    function testGetEventOwner() public {
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, ticketNames, ticketPrices, ticketCapacities, eventDate, location, groups, keywords);
        address result = ticketOffice.getEventOwner(0);
        assertEq(result, ownerWallet);
    }

    function testSingleMintTicketPasses() public {
    // set up event, Set up wallets with USDC, and approve the contract to spend the USDC
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(name, baseUrl, ticketNames, ticketPrices, ticketCapacities, eventDate, location, groups, keywords);
    vm.stopPrank();
    deal(address(usdCoin),address(278),50);
    assertEq(usdCoin.balanceOf(address(278)),50);
    vm.startPrank(address(278));
    usdCoin.approve(address(ticketOffice),50);
    assertEq(usdCoin.allowance(address(278),address(ticketOffice)),50);
    // Mint a ticket verify event logs
    vm.expectEmit();
    emit Transfer(address(278), contractAddress, 10);
    emit TransferSingle(contractAddress, address(0), address(278), 0, 1);
    emit TicketPurchased(address(278), 0, 0, 1);
    ticketOffice.mintSingleTicket(0, 1, 0, address(278));
    // Verify UsdcBalance
    assertEq(usdCoin.balanceOf(address(278)),40);
    assertEq(usdCoin.balanceOf(address(ticketOffice)),10);
    // Verify Ticket Balance
    address[] memory addressArray = new address[](1);
    addressArray[0] = address(278);
    uint256[] memory ticketIdArray = new uint256[](1);
    ticketIdArray[0] = 0;
    uint256[] memory balanceResult = ticketOffice.ticketHoldersBalance(0, addressArray, ticketIdArray);
    assertEq(balanceResult[0], 1);
    // Purchase 4 more tickets
    vm.expectEmit();
    emit Transfer(address(278), contractAddress, 40);
    emit TransferSingle(contractAddress, address(0), address(278), 0, 4);
    emit TicketPurchased(address(278), 0, 0, 4);
    ticketOffice.mintSingleTicket(0, 4, 0, address(278));
    uint256[] memory balanceResult1 = ticketOffice.ticketHoldersBalance(0, addressArray, ticketIdArray);
    assertEq(balanceResult1[0], 5);
    assertEq(usdCoin.balanceOf(address(278)),0);
    assertEq(usdCoin.balanceOf(address(ticketOffice)),50);
    }

    function testSingleMintTicketReverts() public {
    // Check Revert if Event not created
    vm.startPrank(address(278));
    vm.expectRevert("Event Does Not Exist");
    ticketOffice.mintSingleTicket(0, 1, 0, address(278));
    // set up event, Set up wallets with USDC, and approve the contract to spend the USDC
     vm.startPrank(ownerWallet);
    ticketOffice.createEvent(name, baseUrl, ticketNames, ticketPrices, ticketCapacities, eventDate, location, groups, keywords);
    vm.stopPrank();
    deal(address(usdCoin),address(278),10*101);
    vm.startPrank(address(278));
    // Check revert if approve fails
    vm.expectRevert();
    ticketOffice.mintSingleTicket(0, 1, 0, address(278));
    // check Revert if insufficient funds
    deal(address(usdCoin),address(279),1);
    vm.startPrank(address(279));
    usdCoin.approve(address(ticketOffice),1);
    vm.expectRevert();
    ticketOffice.mintSingleTicket(0, 1, 0, address(279));
    // Expect Revert if Tickets sold out
    deal(address(usdCoin),address(280),10);
    vm.startPrank(address(278));
    usdCoin.approve(address(ticketOffice),10*100);
    ticketOffice.mintSingleTicket(0, 100, 0, address(278));
    vm.startPrank(address(280));
    usdCoin.approve(address(ticketOffice),10);
    vm.expectRevert("Event is Sold out");
    ticketOffice.mintSingleTicket(0, 1, 0, address(280));
    // Expect Revert if Ticket ID does not exist

    // Expect Revert if Event is Locked

    // Expect Revert if Ticket Office is Locked
    
    }

    function testMultipleMintTicketsPasses() public {
        // set up event, Set up wallets with USDC, and approve the contract to spend the USDC
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, ticketNames, ticketPrices, ticketCapacities, eventDate, location, groups, keywords);
        vm.stopPrank();
        deal(address(usdCoin),address(278),160);
        assertEq(usdCoin.balanceOf(address(278)),160);
        vm.startPrank(address(278));
        usdCoin.approve(address(ticketOffice),160);
        assertEq(usdCoin.allowance(address(278),address(ticketOffice)),160);
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
        assertEq(usdCoin.balanceOf(address(278)),0);
        assertEq(usdCoin.balanceOf(address(ticketOffice)),160);
        // Verify Ticket Balance
        address[] memory addressArray = new address[](3);
        addressArray[0] = address(278);
        addressArray[1] = address(278);
        addressArray[2] = address(278);
        uint256[] memory ticketIdArray = new uint256[](3);
        ticketIdArray[0] = 0;
        ticketIdArray[1] = 1;
        ticketIdArray[2] = 2;
        uint256[] memory balanceResult = ticketOffice.ticketHoldersBalance(0, addressArray, ticketIdArray);
        assertEq(balanceResult[0], 1);
        assertEq(balanceResult[1], 1);
        assertEq(balanceResult[2], 1);
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
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(name, baseUrl, ticketNames, ticketPrices, ticketCapacities, eventDate, location, groups, keywords);
    vm.stopPrank();
    deal(address(usdCoin),address(278),10 + 50 + 100);
    vm.startPrank(address(278));
    vm.expectRevert();
    ticketOffice.mintMultipleTickets(0, ticketIds, amounts, address(278));
    deal(address(usdCoin),address(278),0);
    vm.startPrank(address(278));
    usdCoin.approve(address(ticketOffice),10 * 100 + 50 * 50 + 100 * 10);
    vm.expectRevert();
    ticketOffice.mintMultipleTickets(0, ticketIds, amounts, address(278));
    deal(address(usdCoin),address(278),10 * 100 + 50 * 50 + 100 * 10);
    amounts[0] = 100;
    amounts[1] = 50;
    amounts[2] = 10;
    ticketOffice.mintMultipleTickets(0, ticketIds, amounts, address(278));
    deal(address(usdCoin),address(279),10 + 50 + 100);
    amounts[0] = 1;
    amounts[1] = 1;
    amounts[2] = 1;
    vm.startPrank(address(279));
    usdCoin.approve(address(ticketOffice),10 + 50 + 100);
    vm.expectRevert("Event is Sold out");
    ticketOffice.mintMultipleTickets(0, ticketIds, amounts, address(279));
     // Expect Revert if Ticket ID does not exist

    // Expect Revert if Event is Locked

    // Expect Revert if Ticket Office is Locked
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
    deal(address(usdCoin),address(123), 50);
    deal(address(usdCoin),address(456), 100);
    vm.startPrank(ownerWallet);
   ticketOffice.createEvent(name, baseUrl, ticketNames, ticketPrices, ticketCapacities, eventDate, location, groups, keywords);
    vm.stopPrank();
    ticketOffice.lockEvent(0);
    vm.startPrank(address(123));
    usdCoin.approve(address(ticketOffice),20000);
    vm.expectRevert("Concert Event is Frozen");
    ticketOffice.mintSingleTicket(0, 1, 0, address(123));
    vm.expectRevert("Concert Event is Frozen");
    ticketOffice.mintMultipleTickets(0, ticketIds, amounts, address(123));
    vm.stopPrank();
    ticketOffice.unLockEvent(0);
    vm.startPrank(address(123));
    vm.expectEmit();
    emit TicketPurchased(address(123), 0, 0, 1);
    ticketOffice.mintSingleTicket(0, 1, 0, address(123));
    }

    function testIssueRefund() public {
        uint256[] memory ticketIds = new uint256[](1);
        ticketIds[0] = 0;
        address[] memory addressArray = new address[](1);
        addressArray[0] = address(123);
        // Test mintSingle refund works
        deal(address(usdCoin),address(123), 10);
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, ticketNames, ticketPrices, ticketCapacities, eventDate, location, groups, keywords);
        vm.startPrank(address(123));
        usdCoin.approve(contractAddress, 10);
        ticketOffice.mintSingleTicket(0, 1, 0, address(123));
        uint256[] memory balanceOfInit = ticketOffice.ticketHoldersBalance(0, addressArray, ticketIds);
        assertEq(balanceOfInit[0], 1);
        uint256 usdcBalanceInit = usdCoin.balanceOf(address(123));
        assertEq(usdcBalanceInit,0 );
        vm.stopPrank();
        ticketOffice.lockEvent(0);
        vm.startPrank(address(123));
        ticketOffice.issueRefund(0, 0);
        uint256[] memory balanceofResult = ticketOffice.ticketHoldersBalance(0,addressArray, ticketIds);
        assertEq(balanceofResult[0], 0);
        uint256 usdcBalanceOfResult = usdCoin.balanceOf(address(123));
        assertEq(usdcBalanceOfResult, 10);
        vm.stopPrank();
        ticketOffice.unLockEvent(0);
        
        // Test VIP Refund Works
        deal(address(usdCoin),address(456),160);
        vm.startPrank(address(456));
        usdCoin.approve(contractAddress, 160);
        uint256[] memory ticketIds2 = new uint256[](3);
        ticketIds2[0] = 0;
        ticketIds2[1] = 1;
        ticketIds2[2] = 2;
        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 1;
        amounts[1] = 1;
        amounts[2] = 1;
        ticketOffice.mintMultipleTickets(0, ticketIds2, amounts, address(456));
        address[] memory addressArray2 = new address[](3);
        addressArray2[0] = address(456);
        addressArray2[1] = address(456);
        addressArray2[2] = address(456);
        uint256[] memory mintMultipleRefundBalanceInit = ticketOffice.ticketHoldersBalance(0, addressArray2, ticketIds2);
        assertEq(mintMultipleRefundBalanceInit[0], 1);
        assertEq(mintMultipleRefundBalanceInit[1], 1);
        assertEq(mintMultipleRefundBalanceInit[2], 1);
        uint256 usdcVipBalanceOfInit = usdCoin.balanceOf(address(456));
        assertEq(usdcVipBalanceOfInit, 0);
        vm.stopPrank();
        ticketOffice.lockEvent(0);
        vm.startPrank(address(456));
        ticketOffice.issueRefund(0, 1);
        uint256[] memory mintMultipleRefundBalanceofResults = ticketOffice.ticketHoldersBalance(0,addressArray2, ticketIds2);
        assertEq(mintMultipleRefundBalanceofResults[1], 0);
        uint256 usdcBalanceOfResult1 = usdCoin.balanceOf(address(456));
        assertEq(usdcBalanceOfResult1, 50);
        // Expect Revert 
        vm.startPrank(address(678));
        vm.expectRevert("Insufficient Balance");
        ticketOffice.issueRefund(0, 0);
        vm.expectRevert("Insufficient Balance");
        ticketOffice.issueRefund(0, 1);
        vm.stopPrank();
        ticketOffice.unLockEvent(0);
        vm.startPrank(address(789));
        vm.expectRevert("Ineligible for Refund");
        ticketOffice.issueRefund(0, 1);
    }

    function testCompTickets() public {
        // set up event
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, ticketNames, ticketPrices, ticketCapacities, eventDate, location, groups, keywords);
        // Set Up Comp One Ticket
        ticketOffice.compOne(0, address(278), 0);
        // Verify issedComp works
        bool result = ticketOffice.issuedComp(0, address(278), 0);
        assertTrue(result);
        // Test Comp One Ticket Refund
        vm.expectEmit();
        emit TransferSingle(contractAddress, address(0), address(278), 0, 1);
        emit TicketPurchased(address(278), 0, 0, 1);
        vm.startPrank(address(278));
        ticketOffice.redeemTicket(0,0);
        address[] memory addressArray = new address[](1);
        addressArray[0] = address(278);
        uint256[] memory ticketIdArray = new uint256[](1);
        ticketIdArray[0] = 0;
        uint256[] memory balanceResult = ticketOffice.ticketHoldersBalance(0, addressArray, ticketIdArray);
        assertEq(balanceResult[0], 1);
        // verify can't double redeem ticket
        vm.expectRevert("Ineligible for Comped Ticket");
        ticketOffice.redeemTicket(0, 0);
        vm.stopPrank();        
        // Test Comp Many Ticket 
        vm.startPrank(ownerWallet);
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
    function testRedeemTicketReverts() public {
        // test redeem reverts if no ticket comp
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, ticketNames, ticketPrices, ticketCapacities, eventDate, location, groups, keywords);
        vm.startPrank(address(278));
        bool issuedResult = ticketOffice.issuedComp(0, address(278), 0);
        assertFalse(issuedResult);
        vm.expectRevert("Ineligible for Comped Ticket");
        ticketOffice.redeemTicket(0, 0);
    }

    function testAddTreasurer() public {
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(name, baseUrl, ticketNames, ticketPrices, ticketCapacities, eventDate, location, groups, keywords);
    ticketOffice.approveTreasurer(0, address(123));
    address treasurer = ticketOffice.getTreasurer(0);
    assertEq(treasurer, address(123));
    }

    function testAddPerformers() public {
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, ticketNames, ticketPrices, ticketCapacities, eventDate, location, groups, keywords);
        vm.expectEmit();
        string[] memory newGroups = new string[](3);
        newGroups[0] = "the Beasty Boys";
        newGroups[1] = "Mc5";
        newGroups[2] = "The Rolling Stones";
        emit Event(0,name, address(0x104fBc016F4bb334D775a19E8A6510109AC63E00),ticketNames,ticketPrices,ticketCapacities,eventDate,location,newGroups,keywords);
        string[] memory results = ticketOffice.addPerformers(0, "The Rolling Stones");
        assertEq(results[0], "the Beasty Boys");
        assertEq(results[1], "Mc5");
        assertEq(results[2], "The Rolling Stones");
    }

    function testRemovePerformers() public {
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, ticketNames, ticketPrices, ticketCapacities, eventDate, location, groups, keywords);
        vm.expectEmit();
        string[] memory newGroups = new string[](1);
        newGroups[0] = "the Beasty Boys";
        emit Event(0,name, address(0x104fBc016F4bb334D775a19E8A6510109AC63E00),ticketNames,ticketPrices,ticketCapacities,eventDate,location,newGroups,keywords);
        string[] memory results = ticketOffice.removePerformers(0, 1);
        assertEq(results[0],"the Beasty Boys");
        
    }

    function testChangeLocation() public {
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, ticketNames, ticketPrices, ticketCapacities, eventDate, location, groups, keywords);
        string memory result = ticketOffice.getEventLocation(0);
        assertEq(result, location);
        vm.expectEmit();
        emit Event(0,name, address(0x104fBc016F4bb334D775a19E8A6510109AC63E00),ticketNames,ticketPrices,ticketCapacities,eventDate,"Antartica",groups,keywords);
        string memory result1 = ticketOffice.changeLocation(0, "Antartica");
        assertEq(result1, "Antartica");
    }

    function testChangeEventDate() public {
        // Event Date is 5 days from present block time stamp
        uint256 oneDay = 86400 * 3;
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, ticketNames, ticketPrices, ticketCapacities, eventDate, location, groups, keywords);
        uint256 result = ticketOffice.getEventDate(0);
        assertEq(result, eventDate, "The top Assert Failed");
        vm.expectEmit();
        emit Event(0,name, address(0x104fBc016F4bb334D775a19E8A6510109AC63E00),ticketNames,ticketPrices,ticketCapacities,eventDate + oneDay * 3,location,groups,keywords);
        // add three days to event date 3 + 5 days equals 8 days
        uint256 result1 = ticketOffice.changeEventDate(0, eventDate + oneDay * 3);
        console.log("initial Date Change value:", result1);
        assertEq(result1, eventDate + oneDay * 3, "the Bottom Assert Failed");
        // assert Event won't change if date is within 3 days.
        // cheat date  to 6 days from present block time stamp, two days before event Date
        vm.warp(block.timestamp + oneDay * 6);
        vm.expectRevert("Date change within Locked Period");
        ticketOffice.changeEventDate(0, block.timestamp + 86400);
        //Cheat date back to 5 days from present block time so that event date can be changed
        vm.warp(block.timestamp - oneDay * 6);
        uint256 timeCheck = ticketOffice.getEventDate(0);
        console.log("event date: ", eventDate);
        console.log("Time Check: ", timeCheck);
        console.log("time Check minus 3 days",timeCheck - 172800);
        console.log(timeCheck - 172800, block.timestamp + (oneDay * 4));
        vm.warp(block.timestamp + oneDay * 4);
        vm.expectEmit();
        emit Event(0,name, address(0x104fBc016F4bb334D775a19E8A6510109AC63E00),ticketNames,ticketPrices,ticketCapacities,eventDate + oneDay * 4,location,groups,keywords);
         uint256 result2 = ticketOffice.changeEventDate(0, eventDate + oneDay * 4 );
        assertEq(result2, eventDate + oneDay * 4);
     }

    function testChangeUri() public {
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, ticketNames, ticketPrices, ticketCapacities, eventDate, location, groups, keywords);
        string memory result = ticketOffice.getEventName(0);
        assertEq(result, name);
       
        string memory result1 = ticketOffice.changeUri(0, "Cheers Finance");
        assertEq(result1, "Cheers Finance");
        address result2 = ticketOffice.getAddress(0);
        string memory tokenUri = ERC1155Token(result2).uri();
        assertEq(tokenUri, "Cheers Finance");

    }

    function testEventFunds() public {}

    function testWithdrawFunds() public {
    // set up event
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(name, baseUrl, ticketNames, ticketPrices, ticketCapacities, eventDate, location, groups, keywords);
    // set up 3 wallets to buy tickets
    deal(address(usdCoin),address(123), 160);
    deal(address(usdCoin),address(456), 160 * 2);
    deal(address(usdCoin),address(789), 160 * 3);
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
    vm.warp(eventDate + 86400 * 3);
    vm.startPrank(ownerWallet);
    ticketOffice.withdrawFunds(0);
    // verify usdc balance on contract is 0
    assertEq(usdCoin.balanceOf(contractAddress), 0);
    // verify usdc balance transfer correctly
    assertEq(usdCoin.balanceOf(ownerWallet), 160 * 6 * .95);
    assertEq(usdCoin.balanceOf(contractOwner), 160 * 6 * .05);
    }

    function testRevokeTickets() public {
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, ticketNames, ticketPrices, ticketCapacities, eventDate, location, groups, keywords);
        vm.startPrank(address(123));
        deal(address(usdCoin),address(123), 100);
        usdCoin.approve(contractAddress, 100);
        ticketOffice.mintSingleTicket(0, 1, 2, address(123));
        vm.stopPrank();
        ticketOffice.revokeTickets(address(123), 0, 2, 1);
        address[] memory addressArray = new address[](1);
        addressArray[0] = address(123);
        uint256[] memory ticketIdArray = new uint256[](1);
        ticketIdArray[0] = 2;
        uint256[] memory balanceResult = ticketOffice.ticketHoldersBalance(0, addressArray, ticketIdArray);
        // Veryfy ticket is revoked and user balance is 0.
        assertEq(balanceResult[0], 0);
    }

    function testCloseTicketOffice() public {
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, ticketNames, ticketPrices, ticketCapacities, eventDate, location, groups, keywords);
        vm.startPrank(address(123));
        deal(address(usdCoin),address(123), 100);
        usdCoin.approve(contractAddress, 100);
        ticketOffice.mintSingleTicket(0, 1, 2, address(123));
        vm.stopPrank();
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
        ticketOffice.createEvent(name, baseUrl, ticketNames, ticketPrices, ticketCapacities, eventDate, location, groups, keywords);
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
        // expects add performers reverts
        //expect remove performers reverts
        // expect change location reverts
        // expect change event date reverts
        // expect change uri reverts


    }


}