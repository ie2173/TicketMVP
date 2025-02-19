// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.20;

import {IERC20} from "src/interfaces/IERC20.sol";
import {IERC1155} from "src/interfaces/IERC1155.sol";
import {ITicketOffice} from "src/interfaces/ITicketOffice.sol";
import {ERC1155} from "src/tokens/ERC1155Base.sol";

import {TicketStructs} from "src/libraries/TicketStructs.sol";


contract ERC1155Token is ERC1155 { 
    address public owner;
    string public name;
    

    constructor(string memory newUri, string memory newName)  {

        owner = msg.sender;
        name = newName;
        _setBaseURI(newUri); 
    }

    function mint(address to, uint256 id,uint256 amount) public {
        require(msg.sender == owner, "Required to use cheers finance to mint tickets");
        _mint(to, id, amount, "");
    }

    function mintBatchTickets(address to, uint256[] memory ids, uint256[] memory amounts) public {
        require(msg.sender == owner, "Required to use cheers finance to mint tickets");
        
        _mintBatch(to, ids, amounts, "");
    }

    function burn(address from, uint256 id, uint256 value) public {
        require(msg.sender == owner, "Required to use cheers finance to burn tickets");
        _burn(from, id, value);
    }

    function updateTicketUri(string memory newUri) public {
        require(msg.sender == owner, "Unauthorized Access");
        _setBaseURI(newUri);
    }
}

contract TicketOffice is ITicketOffice{
    using TicketStructs for TicketStructs.Ticketdetails;
    
    IERC20 internal _usdc;
    string internal _name;
    address internal _contractOwner;
    uint256 internal _eventIdCounter = 0;
    mapping(uint256 => address) public eventTicketAddress;
    mapping(uint256=>mapping(uint256 => uint256)) public ticketPurchasedCounter;
    mapping(address => mapping(uint256 => mapping(uint256 =>bool))) public freeTicketVoucher;
    mapping(address=>mapping(uint256 => mapping(uint256 => bool))) public compedTicket;
    mapping(uint256 => TicketStructs.Ticketdetails) public eventDetails;
    mapping(uint256 => uint256) private eventBalance;
    mapping(uint256 => address) public withdrawlApproval;
    mapping(uint256 => bool) public eventLocked; 
    bool public ticketOfficeOpen;
    

    constructor(string memory  __name, address usdcAddress) {
        _contractOwner = msg.sender;
        _name = __name;
        _usdc = IERC20(usdcAddress);
        ticketOfficeOpen = true;

    }

    modifier okAdmin(uint256 eventId) {
        require(getEventOwner(eventId) == msg.sender || withdrawlApproval[eventId] == msg.sender , "Unauthorized user");
        _;

    }

    modifier openOffice() {
        require(ticketOfficeOpen, "Ticket Office is Closed");
        _;
    }



    function contractOwner() public view returns (address) {
        return _contractOwner;
    }
    
    function getEventName(uint256 eventId) public view returns (string memory) {
        return eventDetails[eventId].name;
    }

    function getTicketNames(uint256 eventId) public view returns (string[] memory) {
        return eventDetails[eventId].ticketData.ticketNames;
    }
    
    function isEventOwner(uint256 eventId, address userAddress) public view returns (bool) {
        return eventDetails[eventId].owner == userAddress ? true : false;
    }

    function getAddress(uint256 eventId) public view returns(address) {
        return eventTicketAddress[eventId];
    }

    function getTicketPrices(uint256 eventId) public view returns (uint256[] memory) {
        return eventDetails[eventId].ticketData.ticketPrices;
    }

    function getTicketPrice(uint256 eventId, uint256 ticketId) public view returns(uint256) {
        return eventDetails[eventId].ticketData.ticketPrices[ticketId];
    }
    

    function getEventCapacity(uint256 eventId, uint256 ticketId) public view returns(uint256) {
        return eventDetails[eventId].ticketData.ticketCapacities[ticketId];
    }

    function getEventCapacities(uint256 eventId) public view returns (uint256[] memory) {
        return eventDetails[eventId].ticketData.ticketCapacities;
    }

    function getEventDate(uint256 eventId) public view returns (uint256) {
        return eventDetails[eventId].eventDate;
    }

    function getEventLocation(uint256 eventId) public view returns ( TicketStructs.Location memory) {
        return eventDetails[eventId].location;
    }

    function getEventPerformers(uint256 eventId) public view returns (string[] memory ) {
        return eventDetails[eventId].performers;
    }
    
    function ticketHoldersBalance (uint256 eventId, address[] memory users, uint256[] memory ticketIds) public view returns (uint256[] memory) {
       
        address iD = eventTicketAddress[eventId];
        return ERC1155Token(iD).balanceOfBatch(users,ticketIds);
        
    }
    
    function getEventOwner(uint256 eventId) public view returns(address) {
            return eventDetails[eventId].owner;
        }
        
    function isTicketHolder(uint256 eventId, address ownerAddress, uint256 ticketId) public view returns(bool) {
        address iD = eventTicketAddress[eventId];
        return ERC1155(iD).balanceOf(ownerAddress,ticketId) != 0;
    }
    
    function issuedComp(uint256 eventId, address user, uint256 ticketId) public view returns(bool) {
        return freeTicketVoucher[user][eventId][ticketId];
    }
    
    function getTreasurer (uint256 eventId) public view returns (address) {
        return withdrawlApproval[eventId];
    }
    
    function getEventFunds(uint256 eventId) public view returns (uint256) {
        return eventBalance[eventId];
    }

    function createEvent(
            TicketStructs.Ticketdetails memory details, 
            string memory baseURL 
            
            ) public openOffice(){

        require(block.timestamp + 86400 * 3 < details.eventDate, "Event Must be created at least 3 days in advance");
        
        ERC1155Token ticketNft = new ERC1155Token(baseURL, details.name);
        address eventAddress = address(ticketNft);
        require(eventAddress != address(0));
        eventTicketAddress[_eventIdCounter] = eventAddress;
        eventDetails[_eventIdCounter] = TicketStructs.Ticketdetails(
        details.ticketData, // ticket data - ticketNames, ticketPrices, ticketCapacities, ticketsSold
        details.name, // ticket name
        msg.sender, // owner
        details.eventDate, // date
        details.location, // location struct - venu, location
        details.performers, //performers
        details.keywords, // keywords
        details.categories, // categories
        details.eventType // event Type
        );
        withdrawlApproval[_eventIdCounter] = msg.sender;
        emitEvent(_eventIdCounter);
        _eventIdCounter++;
    }

    

    function mintTickets(uint256 eventId, uint256[] memory ticketIds, uint256[] memory amounts, address to) public openOffice() {
        require(eventTicketAddress[eventId] != address(0), "Event Does Not Exist");
        require(!eventLocked[eventId], "Concert Event is Frozen" );
        address id = eventTicketAddress[eventId];
        uint length = ticketIds.length;
        for (uint256 i = 0; i < length; i++) {
            require(eventDetails[eventId].ticketData.ticketCapacities[ticketIds[i]] >= amounts[i] + eventDetails[eventId].ticketData.ticketsSold[ticketIds[i]], "Event is Sold out" );
        }
        uint256 grossCost =0;
        for (uint256 i = 0; i < length; i++) {
            grossCost += getTicketPrice(eventId, ticketIds[i]) * amounts[i];
        }
        bool success = _usdc.transferFrom(msg.sender, address(this), grossCost);
        require(success);
        eventBalance[eventId] += grossCost;
        ERC1155Token(id).mintBatchTickets(to, ticketIds, amounts);
        for (uint256 i = 0; i < length; i++) {
            eventDetails[eventId].ticketData.ticketsSold[ticketIds[i]] += amounts[i];
            emit TicketPurchased(to, eventId, ticketIds[i],amounts[i]);
        }
    }
    
    function redeemTicket(uint256 eventId,uint256 ticketId) public openOffice() {
        require(freeTicketVoucher[msg.sender][eventId][ticketId], "Comp Ineligible");
        require(!eventLocked[eventId], "Concert Event is Frozen" );
        address id = eventTicketAddress[eventId];
        compedTicket[msg.sender][eventId][ticketId] = true;
        freeTicketVoucher[msg.sender][eventId][ticketId] = false;
        ERC1155Token(id).mint(msg.sender,ticketId,1);
    }

    function issueRefund(uint256 eventId, uint256 tokenId) public openOffice() {
        require(eventLocked[eventId], "Refund Ineligible" );
        require(!compedTicket[msg.sender][eventId][tokenId], "Refund Ineligible");
        address id = eventTicketAddress[eventId];
        uint256 userBalance = ERC1155Token(id).balanceOf(msg.sender, tokenId);
        require(userBalance > 0,"Insufficient Balance");
        ERC1155Token(id).burn(msg.sender, tokenId, 1);
        eventBalance[eventId] -= eventDetails[eventId].ticketData.ticketPrices[tokenId]; 
        uint256 userBalanceAfter = ERC1155Token(id).balanceOf(msg.sender, tokenId);
        require(userBalanceAfter == userBalance - 1, "Token Burn Failed" );
        _usdc.transfer(msg.sender, eventDetails[eventId].ticketData.ticketPrices[tokenId]);
        
    }
    
    function lockEvent(uint256 eventId) public   {
        require(_contractOwner == msg.sender, "Unauthorized Access");
        eventLocked[eventId] = true;
    }

    function unLockEvent(uint256 eventId) public {
        require(_contractOwner == msg.sender, "Unauthorized Access");
        eventLocked[eventId] = false;
    }
    
    function approveTreasurer(uint256 eventId, address treasurer) public okAdmin(eventId) openOffice() returns(address){
        require(!eventLocked[eventId],"Concert Event is Frozen" );
            withdrawlApproval[eventId] = treasurer;
            return treasurer;
    }
    

    function compTickets(uint256 eventId, address[] memory users, uint256 ticketId) public okAdmin(eventId) openOffice() {
        require(!eventLocked[eventId], "Concert Event is Frozen" );
            uint length = users.length;
            for (uint i = 0; i < length; i++) {
                freeTicketVoucher[users[i]][eventId][ticketId] = true;
            }
    }
    
    function addPerformers (uint256 eventId, string memory newPerformer) public okAdmin(eventId) openOffice() returns(string[] memory){
        
        eventDetails[eventId].performers.push(newPerformer);
        emitEvent(eventId);
        return eventDetails[eventId].performers;
    }
    
    function removePerformers (uint256 eventId, uint256 _index) public okAdmin(eventId) openOffice() returns(string[] memory) {
        require(_index < eventDetails[eventId].performers.length, "Out of bounds");
        uint length = eventDetails[eventId].performers.length;
        for (uint256 i = _index; i < length - 1; i++) {
            eventDetails[eventId].performers[i] = eventDetails[eventId].performers[i + 1];
        }
        eventDetails[eventId].performers.pop();
        emitEvent(eventId);
        return eventDetails[eventId].performers;
    }
    
    function changeLocation (uint256 eventId, string memory newLocation, string memory newLatLng) public okAdmin(eventId) openOffice() returns(TicketStructs.Location memory) {
        eventDetails[eventId].location.name = newLocation;
        eventDetails[eventId].location.location = newLatLng;
       emitEvent(eventId);
        return eventDetails[eventId].location;
    }
    
    function changeEventDate(uint256 eventId, uint256 newDate) public okAdmin(eventId) openOffice() returns(uint256){
        require(eventDetails[eventId].eventDate - 172800 >= block.timestamp, "Date change within Locked Period");

        require(newDate > block.timestamp,"Invalid Date");

        eventDetails[eventId].eventDate = newDate;
       emitEvent(eventId);
        return newDate;
    }

    function changeUri(uint256 eventId, string memory newUri) public okAdmin(eventId) openOffice() returns(string memory){
        address iD = eventTicketAddress[eventId];
        ERC1155Token(iD).updateTicketUri(newUri);
        emitEvent(eventId);
        return newUri;
    }
    
    function withdrawFunds(uint256 eventId) public openOffice(){
        require(block.timestamp - 86400 >= eventDetails[eventId].eventDate, "Withdraw must be one day after Event");
        if (eventLocked[eventId]) {
            revert("Funds are locked for refunds");
        }
        require(eventBalance[eventId] > 0, "No Funds to Withdraw");
        require(msg.sender == eventDetails[eventId].owner ||  msg.sender == withdrawlApproval[eventId], "Unauthorized Access");
        uint256 payOut= eventBalance[eventId] * 95 / 100;
        uint256 fee = eventBalance[eventId] * 5 / 100;
        eventBalance[eventId] = 0;
        eventLocked[eventId] = true;
        _usdc.transfer(_contractOwner, fee);
        _usdc.transfer(eventDetails[eventId].owner, payOut);
    }

    function revokeTickets(address user, uint256 eventId, uint8 tokenId, uint256 value ) public openOffice() {
        require(msg.sender == _contractOwner, "Unauthorized Access");
        address iD = eventTicketAddress[eventId];
        ERC1155Token(iD).burn(user, tokenId, value);
    }
    

    function closeTicketOffice() public {
        require(_contractOwner == msg.sender, "Unauthorized Access");
        ticketOfficeOpen = false;
    }

    function emitEvent(uint256  eventId) internal {
    TicketStructs.Ticketdetails storage details = eventDetails[eventId];
        emit Event(
            eventId, //id
            eventDetails[eventId].name,  //name
            getAddress(eventId), // nft address
            ERC1155Token(getAddress(eventId)).uri(), // image uri
            details.ticketData, // ticket data
            getEventOwner(eventId), // owner
            details.eventDate,  // date
            details.location,  // location struct
            details.performers,  // performers
            details.keywords, // keywords
            details.categories,  // categories
            details.eventType); // event type
    }
}