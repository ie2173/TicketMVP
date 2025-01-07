// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "lib/forge-std/src/Test.sol";
import "lib/forge-std/src/StdUtils.sol";
import "src/TicketOffice.sol";
import "src/interfaces/IERC20.sol";

contract TicketOfficeTest is Test {

    TicketOffice public ticketOffice;
    ERC1155Token public ERC1155; 
    IERC20 public usdCoin;
    address public contractOwner;
    address public contractAddress;
    string public name = "Cheers Finance";
    address public ownerWallet = address(1);
    string public eventName = "Monster Energy Drink Presents LollaPalooza 2023";
    string public symbol = "lolla";
    string public baseUrl = "ipfs:/demoBase";
    uint256 public genSupply = 100;
    uint256 public vSupply = 50;
    uint256 public genPrice = 50;
    uint256 public vPrice = 100;
    uint256 public eventDate = block.timestamp + 432000;
    string public location = "The Astrodome";
    string[] groups = ["the Beasty Boys", "Mc5"]; 

    event Event(uint256 indexed eventIdCounter, string name, address contractAddress, uint256 generalPrice,uint256 vipPrice, uint256 generalSupply,
    uint256 vipSupply , uint256 eventDate, string concertLocation, string[] performers);

    event TicketPurchased(address indexed buyer, uint256 indexed eventId, uint8 tokenId);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    event TransferSingle (address operator, address from, address to, uint256 id, uint256 value);
    
    event Transfer(address indexed from, address indexed to, uint256 value);

    function setUp() public {
         usdCoin= IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        ticketOffice = new TicketOffice(name, 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        contractOwner = address(this);
        contractAddress = address(ticketOffice);
    }
    

    function testName() public {
        string memory result = ticketOffice.name();
        assertEq(result,name);

    }

    function testcontractOwner() public {
        address result = ticketOffice.contractOwner();
        assertEq(result, contractOwner);
    }

    function testCreateEvent() public {
        vm.startPrank(ownerWallet);
        vm.expectEmit();
        emit Event(0, name, 0x104fBc016F4bb334D775a19E8A6510109AC63E00,  genPrice, vPrice,  genSupply,
        vSupply , eventDate, location, groups);
        ticketOffice.createEvent(name, baseUrl, genSupply, vSupply, genPrice, vPrice, eventDate, location, groups);
        vm.expectEmit();
        address treasurerResults = ticketOffice.getTreasurer(0);
        assertEq(treasurerResults, ownerWallet);
        emit Event(1, name, 0x037eDa3aDB1198021A9b2e88C22B464fD38db3f3,  genPrice, vPrice,  genSupply,
        vSupply , eventDate, location, groups);
        ticketOffice.createEvent(name, baseUrl, genSupply, vSupply, genPrice, vPrice, eventDate, location, groups);
        
    }

    function testGetEventName() public {
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, genSupply, vSupply, genPrice, vPrice, eventDate, location, groups);
        string memory result = ticketOffice.getEventName(0);
        assertEq(result, name);
    }

    function testIsEventOwner() public {
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, genSupply, vSupply, genPrice, vPrice, eventDate, location, groups);
        bool result1 = ticketOffice.isEventOwner(0, ownerWallet);
        assertTrue(result1);
        bool result2 = ticketOffice.isEventOwner(0, address(3));
        assertFalse(result2);
    }

    function testGetAddress() public {
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, genSupply, vSupply, genPrice, vPrice, eventDate, location, groups);
        address result = ticketOffice.getAddress(0);
        assertEq(result, address(0x104fBc016F4bb334D775a19E8A6510109AC63E00));
        address result1 = ticketOffice.getAddress(1);
        assertEq(result1, address(0));
    }

    function testGetEventGeneralPrice() public {
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, genSupply, vSupply, genPrice, vPrice, eventDate, location, groups);
        uint256 result = ticketOffice.getEventGeneralPrice(0);
        assertEq(result, 50);
    }

    function testGetEventVipPrice() public {
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, genSupply, vSupply, genPrice, vPrice, eventDate, location, groups);
        uint256 result = ticketOffice.getEventVipPrice(0);
        assertEq(result, 100);
    }

    function testGetGeneralSupply() public {
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, genSupply, vSupply, genPrice, vPrice, eventDate, location, groups);
        uint256 result = ticketOffice.getEventGeneralCapacity(0);
        assertEq(result, genSupply);
    }

    function testGetEventOwner() public {
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, genSupply, vSupply, genPrice, vPrice, eventDate, location, groups);
        address result = ticketOffice.getEventOwner(0);
        assertEq(ownerWallet, result);
    }

    function testGeneralMint() public {
        //initialize everything
        deal(address(usdCoin),ownerWallet, 50 );
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, genSupply, vSupply, genPrice, vPrice, eventDate, location, groups);
        usdCoin.approve(contractAddress, 50);
       // Start mint on contract
       vm.expectEmit();
       emit Transfer(ownerWallet, address(ticketOffice), 50);
       emit TransferSingle(address(ticketOffice), address(0), ownerWallet, 0, 1);
       emit TicketPurchased(ownerWallet, 0, 1);
        ticketOffice.mintTicketGeneral(0,1, ownerWallet);
        uint256 contractValueResult = ticketOffice.getEventFunds(0);
        assertEq(contractValueResult, 50);
        uint256 aftBalance = usdCoin.balanceOf(ownerWallet);
        assertEq(aftBalance, 0);
        uint256 contractBalance = usdCoin.balanceOf(contractAddress);
        assertEq(contractBalance, 50);
        address ticketAddress = ticketOffice.getAddress(0);
        uint256 ticketBalance = ERC1155Token(ticketAddress).balanceOf(ownerWallet, 0);
        assertEq(ticketBalance, 1);
        vm.startPrank(address(9));
        vm.expectRevert("Insufficient Funds HIT FUNCTION CHECK");
        ticketOffice.mintTicketGeneral(0, 1, address(9));
        // Test purchasing ten tickets
        deal(address(usdCoin),address(123), 4950);
        vm.startPrank(address(123));
        usdCoin.approve(contractAddress, 4950);
        ticketOffice.mintTicketGeneral(0, 98, address(123));
        ticketOffice.mintTicketGeneral(0, 1, address(123));
        vm.stopPrank();
        uint256 ticketBalanceResult1 = ERC1155Token(ticketAddress).balanceOf(address(123), 0);
        assertEq(ticketBalanceResult1, 99);
        uint256 contractBalanceResult1 = usdCoin.balanceOf(contractAddress);
        console.log(contractBalanceResult1);
        assertEq(contractBalanceResult1, 5000);
         //assert Event sold out.
        deal(address(usdCoin),address(124), 5050);
        console.log("USD BALANCE", usdCoin.balanceOf(address(124)));
        vm.startPrank(address(124));
        usdCoin.approve(contractAddress, 5050);
        vm.expectRevert("Tickets sold out");
        ticketOffice.mintTicketGeneral(0, 101, address(1));
        ticketOffice.createEvent(name, baseUrl, genSupply, vSupply, genPrice, vPrice, eventDate, location, groups);
        deal(address(usdCoin),address(345),2500);
        deal(address(usdCoin),address(678), 2550);
        vm.startPrank(address(345));
        usdCoin.approve(contractAddress, 2500);
        ticketOffice.mintTicketGeneral(1, 50, address(1));
        vm.startPrank(address(678)); 
        usdCoin.approve(contractAddress, 2550);
        vm.expectRevert("Tickets sold out");
        ticketOffice.mintTicketGeneral(1, 51, address(1));
    }

    function testVipMint() public {
        deal(address(usdCoin),ownerWallet, 100 );
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, genSupply, vSupply, genPrice, vPrice, eventDate, location, groups);
        usdCoin.approve(contractAddress, 100);
        vm.expectEmit();
       emit Transfer(ownerWallet, address(ticketOffice), 100);
       emit TransferSingle(address(ticketOffice), address(0), ownerWallet, 1, 1);
       emit TicketPurchased(ownerWallet, 0, 1);
        ticketOffice.mintTicketVip(0,1, ownerWallet);
        uint256 contractValueResult = ticketOffice.getEventFunds(0);
        assertEq(contractValueResult, 100);
        uint256 aftBalance = usdCoin.balanceOf(ownerWallet);
        assertEq(aftBalance, 0);
        uint256 contractBalance = usdCoin.balanceOf(contractAddress);
        assertEq(contractBalance, 100);
        address ticketAddress = ticketOffice.getAddress(0);
        uint256 ticketBalance = ERC1155Token(ticketAddress).balanceOf(ownerWallet, 1);
        assertEq(ticketBalance, 1);
        vm.startPrank(address(9));
        vm.expectRevert("Insufficient Funds HIT FUNCTION CHECK");
        ticketOffice.mintTicketVip(0, 2, address(9));
        deal(address(usdCoin),address(123), 4900);
        vm.startPrank(address(123));
        usdCoin.approve(contractAddress, 4900);
        ticketOffice.mintTicketVip(0,49, ownerWallet);
        uint256 contractBalanceResult1 = usdCoin.balanceOf(contractAddress);
        console.log(contractBalanceResult1);
        assertEq(contractBalanceResult1, 5000);
        deal(address(usdCoin),address(56),200);
        vm.startPrank(address(56));
        usdCoin.approve(contractAddress, 200);
        vm.expectRevert("Tickets sold out");
        ticketOffice.mintTicketVip(0, 2, address(56));
    }

    function testEventLocked() public {
    deal(address(usdCoin),address(123), 50);
    deal(address(usdCoin),address(456), 100);
    vm.startPrank(ownerWallet);
    ticketOffice.createEvent(name, baseUrl, genSupply, vSupply, genPrice, vPrice, eventDate, location, groups);
    vm.stopPrank();
    ticketOffice.lockEvent(0);
    vm.startPrank(address(123));
    vm.expectRevert("Concert Event is Frozen");
    ticketOffice.mintTicketGeneral(0, 1, address(123));
    vm.expectRevert("Concert Event is Frozen");
    ticketOffice.mintTicketVip(0, 1, address(123));
    vm.stopPrank();
    ticketOffice.unLockEvent(0);
    vm.startPrank(address(123));
    }

    function testIssueRefund() public {
        // Test General Refund Works
        deal(address(usdCoin),address(123), 50);
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, genSupply, vSupply, genPrice, vPrice, eventDate, location, groups);
        vm.startPrank(address(123));
        usdCoin.approve(contractAddress, 50);
        ticketOffice.mintTicketGeneral(0, 1, address(123));
        uint256[] memory balanceOfInit = ticketOffice.ticketHolderBalance(0, address(123));
        assertEq(balanceOfInit[0], 1);
        uint256 usdcBalanceInit = usdCoin.balanceOf(address(123));
        assertEq(usdcBalanceInit,0 );
        vm.stopPrank();
        ticketOffice.lockEvent(0);
        vm.startPrank(address(123));
        ticketOffice.issueRefund(0, 0);
        uint256[] memory balanceofResult = ticketOffice.ticketHolderBalance(0, address(123));
        assertEq(balanceofResult[0], 0);
        uint256 usdcBalanceOfResult = usdCoin.balanceOf(address(123));
        assertEq(usdcBalanceOfResult, 50);
        vm.stopPrank();
        ticketOffice.unLockEvent(0);
        // Test VIP Refund Works
        deal(address(usdCoin),address(456),100);
        vm.startPrank(address(456));
        usdCoin.approve(contractAddress, 100);
        ticketOffice.mintTicketVip(0, 1, address(456));
        uint256[] memory vipRefundBalanceInit = ticketOffice.ticketHolderBalance(0, address(456));
        assertEq(vipRefundBalanceInit[1], 1);
        uint256 usdcVipBalanceOfInit = usdCoin.balanceOf(address(456));
        assertEq(usdcVipBalanceOfInit, 0);
        vm.stopPrank();
        ticketOffice.lockEvent(0);
        vm.startPrank(address(456));
        ticketOffice.issueRefund(0, 1);
        uint256[] memory viprefundBalanceofResults = ticketOffice.ticketHolderBalance(0, address(456));
        assertEq(viprefundBalanceofResults[1], 0);
        uint256 usdcVipBalanceOfResult = usdCoin.balanceOf(address(456));
        assertEq(usdcVipBalanceOfResult, 100);
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

    function testRedeemTicket() public {
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, genSupply, vSupply, genPrice, vPrice, eventDate, location, groups);
        ticketOffice.compOne(0, address(123));
        bool compResult = ticketOffice.issuedComp(0,address(123));
        assertTrue(compResult);
        vm.startPrank(address(123));
        ticketOffice.redeemTicket(0);
        uint256[] memory balanceOfResult = ticketOffice.ticketHolderBalance(0, address(123));
        assertEq(balanceOfResult[0], 1);
        // Expect Revert
        vm.startPrank(address(456));
        vm.expectRevert("Ineligible for Comped Ticket");
        ticketOffice.redeemTicket(0);
        vm.startPrank(ownerWallet);
        address[] memory CompArray = new address[](4);
        CompArray[0] = address(7);
        CompArray[1] = address(8);
        CompArray[2] = address(9);
        CompArray[3] = address(10);
        ticketOffice.compMany(0, CompArray);
        bool CompResultAddress1 = ticketOffice.issuedComp(0,address(7));
        assertTrue(CompResultAddress1 );
        bool CompResultAddress2 = ticketOffice.issuedComp(0,address(8));
        assertTrue(CompResultAddress2 );
        bool CompResultAddress3 = ticketOffice.issuedComp(0,address(9));
        assertTrue(CompResultAddress3 );
        bool CompResultAddress4 = ticketOffice.issuedComp(0,address(10));
        assertTrue(CompResultAddress4 );
        vm.startPrank(address(10));
        ticketOffice.redeemTicket(0);
        uint256[] memory BalanceOfCompManyResult = ticketOffice.ticketHolderBalance(0, address(10));
        assertEq(BalanceOfCompManyResult[0], 1);
    }

    function testNewTreasurer() public {
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, genSupply, vSupply, genPrice, vPrice, eventDate, location, groups);
        address initTreasurer = ticketOffice.getTreasurer(0);
        assertEq(initTreasurer, ownerWallet);
        ticketOffice.approveTreasurer(0, address(1));
        address treasurer = ticketOffice.getTreasurer(0);
        assertEq(treasurer, address(1));
    }

    function testEventFunds() public {
        deal(address(usdCoin),address(1),genPrice * 2);
        deal(address(usdCoin),address(2),genPrice * 2);
        deal(address(usdCoin),address(3),genPrice * 2);
        deal(address(usdCoin),address(4),genPrice * 2);
        deal(address(usdCoin),address(5),genPrice * 2);
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, genSupply, vSupply, genPrice, vPrice, eventDate, location, groups);
        vm.startPrank(address(1));
        usdCoin.approve(contractAddress, genPrice * 2);
        ticketOffice.mintTicketGeneral(0, 2, address(9));
        vm.startPrank(address(2));
        usdCoin.approve(contractAddress, genPrice * 2);
        ticketOffice.mintTicketGeneral(0, 2, address(9));
        vm.startPrank(address(3));
        usdCoin.approve(contractAddress, genPrice * 2);
        ticketOffice.mintTicketGeneral(0, 2, address(9));
        vm.startPrank(address(4));
        usdCoin.approve(contractAddress, genPrice * 2);
        ticketOffice.mintTicketGeneral(0, 2, address(9));
        vm.startPrank(address(5));
        usdCoin.approve(contractAddress, genPrice * 2);
        ticketOffice.mintTicketGeneral(0, 2, address(9));
        uint256 AmountResult = ticketOffice.getEventFunds(0);
        uint256 USDAmount = usdCoin.balanceOf(contractAddress);
        assertEq(AmountResult, USDAmount);
    }

    function testAddRemovePerformers() public {
        string[] memory eventPerformerCheck = new string[](1);
        eventPerformerCheck[0] = "Mc5";
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, genSupply, vSupply, genPrice, vPrice, eventDate, location, groups);
        string[] memory performersInitResult = ticketOffice.getEventPerformers(0);
        assertEq(performersInitResult[0], "the Beasty Boys");
        vm.expectEmit();
       emit Event(0, name, 0x104fBc016F4bb334D775a19E8A6510109AC63E00,  genPrice, vPrice,  genSupply,
     vSupply , eventDate, location, eventPerformerCheck);
        ticketOffice.removePerformers(0, 0);
        string[] memory perfomersRemoveResult = ticketOffice.getEventPerformers(0);
        string memory  result1 = perfomersRemoveResult[0];
        assertNotEq(result1, "the Beasty Boys");
        vm.expectEmit();
        string[] memory eventPerformerCheck1 = new string[](2);
        eventPerformerCheck1[0]="Mc5";
        eventPerformerCheck1[1]="Smashing Pumpkins";
        emit Event(0, name, 0x104fBc016F4bb334D775a19E8A6510109AC63E00,  genPrice, vPrice,  genSupply,
     vSupply , eventDate, location, eventPerformerCheck1);
        ticketOffice.addPerformers(0, "Smashing Pumpkins");
        string[] memory performersAddResult1 = ticketOffice.getEventPerformers(0);
        assertEq(performersAddResult1[1], "Smashing Pumpkins");
        vm.expectEmit();
        string[] memory eventPerformerCheck2 = new string[](3);
        eventPerformerCheck2[0]="Mc5";
        eventPerformerCheck2[1]="Smashing Pumpkins";
        eventPerformerCheck2[2]="Black Flag";
        emit Event(0, name, 0x104fBc016F4bb334D775a19E8A6510109AC63E00,  genPrice, vPrice,  genSupply,
     vSupply , eventDate, location, eventPerformerCheck2);
        ticketOffice.addPerformers(0, "Black Flag");
        string[] memory performersAddResult2 = ticketOffice.getEventPerformers(0);
        uint256 additionResult = performersAddResult2.length;
        assertEq(additionResult, 3);
        console.log(performersAddResult2[2]); 
        ticketOffice.removePerformers(0, 1);
        string[] memory performersRemoveResult2 = ticketOffice.getEventPerformers(0);
        assertEq(performersRemoveResult2[1],"Black Flag");
        vm.stopPrank();
        vm.startPrank(address(2));
        console.log(tx.origin);
        vm.expectRevert("Unauthorized user");
        ticketOffice.addPerformers(0, "Streetlight Manifesto");
        vm.expectRevert("Unauthorized user");
        ticketOffice.removePerformers(0, 0);
    }

    function testWithdrawFunds() public {
        deal(address(usdCoin),address(2),genPrice * 2);
        deal(address(usdCoin),address(3),genPrice * 2);
        deal(address(usdCoin),address(4),genPrice * 2);
        deal(address(usdCoin),address(5),genPrice * 2);
        deal(address(usdCoin),address(6),genPrice * 2);
        vm.startPrank(address(66));
        ticketOffice.createEvent(name, baseUrl, genSupply, vSupply, genPrice, vPrice, eventDate, location, groups);
        vm.startPrank(address(2));
        usdCoin.approve(contractAddress, genPrice * 2);
        ticketOffice.mintTicketGeneral(0, 2, address(9));
        vm.startPrank(address(3));
        usdCoin.approve(contractAddress, genPrice * 2);
        ticketOffice.mintTicketGeneral(0, 2, address(9));
        vm.startPrank(address(4));
        usdCoin.approve(contractAddress, genPrice * 2);
        ticketOffice.mintTicketGeneral(0, 2, address(9));
        vm.startPrank(address(5));
        usdCoin.approve(contractAddress, genPrice * 2);
        ticketOffice.mintTicketGeneral(0, 2, address(9));
        vm.startPrank(address(6));
        usdCoin.approve(contractAddress, genPrice * 2);
        ticketOffice.mintTicketGeneral(0, 2, address(9));
        console.log(block.timestamp);
        console.log("init Timestamp",block.timestamp);
        vm.warp(eventDate+ 86405);
        vm.startPrank(address(256));
        vm.expectRevert("Unauthorized Access");
        ticketOffice.withdrawFunds(0);
        vm.startPrank(address(66));
        console.log("cheated block Timestamp", block.timestamp);
        console.log("initial Value of Wallet",usdCoin.balanceOf(address(66)));
        ticketOffice.withdrawFunds(0);
        uint256 ownerNewBalance = usdCoin.balanceOf(address(66));
        assertEq(genPrice * 10 * 95 / 100, ownerNewBalance);
        uint256 ContractOwnerNewBalance = usdCoin.balanceOf(address(ticketOffice.contractOwner()));
        assertEq(genPrice * 10 * 5 / 100, ContractOwnerNewBalance);
        
    }

    function testIsTicketHolder() public {
        // Test if isTicketHolder Function will work
        deal(address(usdCoin),address(11),100);
        deal(address(usdCoin), address(22),100);
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, genSupply, vSupply, genPrice, vPrice, eventDate, location, groups);
        vm.startPrank(address(11));
        usdCoin.approve(contractAddress, 100);
        ticketOffice.mintTicketGeneral(0, 1, address(99));
        bool mintResult = ticketOffice.isTicketHolder(0, address(99));
        assertTrue(mintResult);
        bool falseMintResult = ticketOffice.isTicketHolder(0, address(11));
        assertFalse(falseMintResult);
        vm.startPrank(address(22));
        usdCoin.approve(contractAddress, 100);
        ticketOffice.mintTicketVip(0, 1, address(88));
        bool vipMintResult = ticketOffice.isTicketHolder(0, address(88));
        assertTrue(vipMintResult);
    }

    function testChangeEventDate() public {
        // Test if we can change the date, and make sure it doesn't interfere with withdrawl funds
        uint256 timeStamper = block.timestamp + 432000;
        deal(address(usdCoin),address(7),100);
        vm.startPrank(ownerWallet);

        ticketOffice.createEvent(name, baseUrl, genSupply, vSupply, genPrice, vPrice, timeStamper + 172800, location, groups); // four days ahead of current time stamp, 
        console.log("Event Date",ticketOffice.getEventDate(0));
        console.log("Current Date",timeStamper);
        console.log("Difference Between the Two",ticketOffice.getEventDate(0) - (timeStamper ));
        vm.startPrank(address(7));
        usdCoin.approve(contractAddress, 100);
        ticketOffice.mintTicketGeneral(0, 1, address(7));
        vm.startPrank(ownerWallet);
        vm.warp(timeStamper - 1); // Timestamp -1 second; out of exclusion zone;
        vm.expectEmit();
        emit Event(0, name,0x104fBc016F4bb334D775a19E8A6510109AC63E00,genPrice, vPrice,  genSupply,
        vSupply , timeStamper+ 172800, location, groups);
        ticketOffice.changeEventDate(0, timeStamper + 172800); // 
        uint256 timestampResults = ticketOffice.getEventDate(0);
        assertEq(timeStamper + 172800, timestampResults);
        vm.warp(timeStamper); //Timestamp; equal to exclusion zone threshold:
        vm.expectEmit();
        emit Event(0, name,0x104fBc016F4bb334D775a19E8A6510109AC63E00,genPrice, vPrice,  genSupply,
        vSupply , timeStamper+ 172800, location, groups);
        ticketOffice.changeEventDate(0, timeStamper+ 172800); // 
        uint256 timestampResults1 = ticketOffice.getEventDate(0);
        assertEq(timeStamper + 172800, timestampResults1);
        vm.warp(timeStamper + 1); // Timestamp + 1, within exclusion zone
        vm.expectRevert("Date change within Locked Period");
        ticketOffice.changeEventDate(0, timeStamper + 8000);
        vm.warp(timeStamper - 500);
        vm.startPrank(address(567));
        vm.expectRevert("Unauthorized user");
        ticketOffice.changeEventDate(0, timeStamper + 90000);
    }

    function testChangeEventLocation() public {
        // test to see if changing the event messes with anything.
        vm.startPrank(ownerWallet);
        ticketOffice.createEvent(name, baseUrl, genSupply, vSupply, genPrice, vPrice, eventDate, location, groups);
        vm.expectEmit();
        emit Event(0, name,0x104fBc016F4bb334D775a19E8A6510109AC63E00,genPrice, vPrice,  genSupply,
        vSupply , eventDate, "The warsaw", groups);
        ticketOffice.changeLocation(0, "The warsaw");
        string memory LocationResult = ticketOffice.getEventLocation(0);
        assertEq(LocationResult, "The warsaw");
        vm.startPrank(address(6));
        vm.expectRevert("Unauthorized user");
        ticketOffice.changeLocation(0, "House of Blues");
    }


    function testBurnFails() public {
        // test if burning a 1155 ticket from outside wallet fails
        vm.startPrank(ownerWallet);
        deal(address(usdCoin),address(1), 100);
        ticketOffice.createEvent(name, baseUrl, genSupply, vSupply, genPrice, vPrice, eventDate, location, groups);
        vm.startPrank(address(1));
        usdCoin.approve(contractAddress, 100);
        ticketOffice.mintTicketGeneral(0, 1, address(1));
        vm.startPrank(address(2));
        vm.expectRevert("Required to use cheers finance to burn tickets");
        ERC1155Token(0x104fBc016F4bb334D775a19E8A6510109AC63E00).burn(address(1),0,1);
    }

    function testCloseTicketOffice() public {
        // Test if close ticket office will cause openOffice modifier to revert functions
        vm.startPrank(address(5));
        ticketOffice.createEvent(name, baseUrl, genSupply, vSupply, genPrice, vPrice, eventDate, location, groups);
        vm.startPrank(contractOwner);
        ticketOffice.closeTicketOffice();
        vm.startPrank(address(2));
        vm.expectRevert("Ticket Office Closed");
        ticketOffice.createEvent(name, baseUrl, genSupply, vSupply, genPrice, vPrice, eventDate, location, groups);
        vm.expectRevert("Ticket Office Closed");
        ticketOffice.mintTicketGeneral(0, 1, address(1));
        vm.expectRevert("Ticket Office Closed");
        ticketOffice.mintTicketVip(0, 1, address(1));
        vm.expectRevert("Ticket Office Closed");
        ticketOffice.redeemTicket(0);
        vm.expectRevert("Ticket Office Closed");
        vm.startPrank(address(5));
        ticketOffice.compOne(0, address(1));
        vm.expectRevert("Ticket Office Closed");
        address[] memory CompArray = new address[](4);
        CompArray[0] = address(7);
        CompArray[1] = address(8);
        CompArray[2] = address(9);
        CompArray[3] = address(10);
        ticketOffice.compMany(0, CompArray);
        vm.expectRevert("Ticket Office Closed");
        ticketOffice.addPerformers(0, "The Beatles");
        vm.expectRevert("Ticket Office Closed");
        ticketOffice.removePerformers(0, 0);
        vm.expectRevert("Ticket Office Closed");
        ticketOffice.changeLocation(0, "The Astrodome");
        vm.expectRevert("Ticket Office Closed");
        ticketOffice.changeEventDate(0, eventDate);
    }

    function testBurnTicket() public {
        // Test if burning a 1155 ticket succceeds and if someone else attempts, test fails
        vm.startPrank(ownerWallet);
        deal(address(usdCoin),address(888), 200);
        ticketOffice.createEvent(name, baseUrl, genSupply, vSupply, genPrice, vPrice, eventDate, location, groups);
        vm.startPrank(address(888));
        usdCoin.approve(contractAddress, 100);
        ticketOffice.mintTicketGeneral(0, 2, address(888));
        vm.startPrank(contractOwner);
        ticketOffice.revokeTickets(address(888),0,0, 1);
        vm.expectRevert();
        ticketOffice.revokeTickets(address(888),0,0, 3);
        vm.startPrank(address(899));
        vm.expectRevert("Unauthorized Access");
        ticketOffice.revokeTickets(address(888),0,0, 1);
    }
}