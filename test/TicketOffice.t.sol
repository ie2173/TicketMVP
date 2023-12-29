// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "lib/forge-std/src/Test.sol";
import "src/TicketOffice.sol";
import "src/tokens/ERC721Base.sol";

contract TicketOfficeTest is Test {

    TicketOffice public ticketOffice;
    address public contractOwner;
    string public name = "Cheers Finance";
    address public ownerWallet = address(1);
    string public eventName = "Monster Energy Drink Presents LollaPalooza 2023";
    string public symbol = "lolla";
    string public baseUrl = "ipfs:/demoBase";
    uint256 public totalSupply = 1000;
    uint256 public  price = 1 ether;

    event EventCreated(string name, address contractAddress);

    function setUp() public {
        ticketOffice = new TicketOffice(name, address(0x00));
        contractOwner = address(this);
    }
    // Get name of Contract - TEST COMPLETED
    // Get owner of contract - TEST COMPLETED
    // Create an Event - TEST COMPLETED
    // get Event name - TEST COMPLETED
    // Get Event Owner - TEST COMPLETED
    // GET Event Address - TEST COMPLETED
    // get Event Location - FUNCTION IN CONSTRUCTION
    // get ticket price - FUNCTION IN CONSTRUCTION
    // Get Totaly Supply - TEST COPLETED
    // get Tickets Available - FUNCTION IN CONSTRUCTION
    // Get Event Date - NEEDS TEST WRITTEN
    // Get Performers - FUNCTION IN CONSTRUCTION
    // create Ticket - FUNCTION IN CONSTRUCTION
    // Stop Ticket Sales - FUNCTION IN CONSTRUCTION
    // create Ticket Comp - NEEDS TESTS WRITTEN
    // redeem ticket - NEEDS TEST WRITTEN
    // issue refunds - FUNCTION IN CONSTRUCTION
    // Change Performers - FUNCTION IN CONSTRUCTION
        // Add Performers
        // Remove Performers
    // approve treasurer - FUNCTION IN CONSTRUCTION
    // Withdraw Funds - FUNCTION IN CONSTRUCTION
    // Get is Ticket Holder - NEEDS TEST WRITTEN

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
        emit EventCreated(eventName, address(0x104fBc016F4bb334D775a19E8A6510109AC63E00));
        //ticketOffice.createEvent(eventName, symbol, baseUrl, totalSupply, price);
    }

    function testGetEventName() public {
        vm.startPrank(ownerWallet);
        //ticketOffice.createEvent(eventName, symbol, baseUrl, totalSupply, price);
        //string memory result = ticketOffice.geteventName(0);
        //assertEq(result, eventName);
    }

    function testIsEventOwner() public {
        vm.startPrank(ownerWallet);
        //ticketOffice.createEvent(eventName, symbol, baseUrl, totalSupply, price);
        //bool result1 = ticketOffice.isEventOwner(0, ownerWallet);
        //assertTrue(result1);
        //bool result2 = ticketOffice.isEventOwner(0, address(3));
        //assertFalse(result2);
    }

    function testGetAddress() public {
        vm.startPrank(ownerWallet);
        //ticketOffice.createEvent(eventName, symbol, baseUrl, totalSupply, price);
        //address result = ticketOffice.getAddress(0);
        //assertEq(result, address(0x104fBc016F4bb334D775a19E8A6510109AC63E00));
    }

    function testGetEventprice() public {
        vm.startPrank(ownerWallet);
        //ticketOffice.createEvent(eventName, symbol, baseUrl, totalSupply, price);
        //uint256 result = ticketOffice.getEventprice(0);
        //assertEq(result, price);
    }

    function testGetEventCapacity() public {
        vm.startPrank(ownerWallet);
       // ticketOffice.createEvent(eventName, symbol, baseUrl, totalSupply, price);
        //uint256 result = ticketOffice.getEventCapacity(0);
        //assertEq(result, totalSupply);
    }

    function testGetEventOwner() public {
         vm.startPrank(ownerWallet);
        //ticketOffice.createEvent(eventName, symbol, baseUrl, totalSupply, price);
       //address result = ticketOffice.getEventOwner(0);
       //assertEq(ownerWallet, result);
    }

    function testMint() public {
        vm.deal(ownerWallet, 20 ether);
        vm.startPrank(ownerWallet);
        //ticketOffice.createEvent(eventName, symbol, baseUrl, totalSupply, price);
        //assertEq(address(ownerWallet).balance, 20 ether);
        //ticketOffice.mintTicket{value: 1 ether}(0, 1, ownerWallet);
        

        //uint256 nftResult =  ERC721Tickets(ticketOffice.eventTicketAddress(0)).balanceOf(ownerWallet);
        //assertEq(nftResult, 1);

        //ticketOffice.mintTicket{value:2 ether}(0, 2, ownerWallet);

        //uint256 nftResult2 = ERC721Tickets(ticketOffice.eventTicketAddress(0)).balanceOf(ownerWallet);
        //assertEq(nftResult2, 3);

        //vm.expectRevert("Insufficient Funds");
        //ticketOffice.mintTicket{value:10 ether}(0, 2, ownerWallet);

        //vm.expectRevert("Event Does Not Exist");
        //ticketOffice.mintTicket(1, 1, ownerWallet);

    }
}