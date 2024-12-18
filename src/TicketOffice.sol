// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.20;

import "src/interfaces/IERC20.sol";
import "src/interfaces/IERC1155.sol";
import "src/tokens/ERC1155Base.sol";
import "src/interfaces/ITicketOffice.sol";

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
    struct TicketDetails {
        string[] ticketNames;
        uint256[] ticketCapacities;
        uint256[] ticketPrices;
        uint256[] ticketsSold;
        string name;
        address owner;
        uint256 eventDate;
        string concertLocation;
        string[] performers;
    }
    
    IERC20 internal _usdc;
    string internal _name;
    address internal _contractOwner;
    uint256 internal _eventIdCounter = 0;
    mapping(uint256 => address) public eventTicketAddress;
    mapping(uint256 => mapping(address => mapping(uint256 => bool))) public freeTicketVoucher;
    mapping(uint256 => TicketDetails) public eventDetails;
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
        require(ticketOfficeOpen, "Ticket Office Closed");
        _;
    }

    function name() public view returns(string memory) {
        return _name;
    }

    function contractOwner() public view returns (address) {
        return _contractOwner;
    }
    
    function getEventName(uint256 eventId) public view returns (string memory) {
        return eventDetails[eventId].name;
    }

    function getTicketNames(uint256 eventId) public view returns (string[] memory) {
        return eventDetails[eventId].ticketNames;
    }
    
    function isEventOwner(uint256 eventId, address userAddress) public view returns (bool) {
        return eventDetails[eventId].owner == userAddress ? true : false;
    }

    function getAddress(uint256 eventId) public view returns(address) {
        return eventTicketAddress[eventId];
    }

    function getEventPrice(uint256 eventId, uint256 ticketId) public view returns (uint256) {
        return eventDetails[eventId].ticketPrices[ticketId];
    }
    

    function getEventCapacity(uint256 eventId, uint256 ticketId) public view returns(uint256) {
        return eventDetails[eventId].ticketCapacities[ticketId];
    }

    function getEventDate(uint256 eventId) public view returns (uint256) {
        return eventDetails[eventId].eventDate;
    }

    function getEventLocation(uint256 eventId) public view returns (string memory ) {
        return eventDetails[eventId].concertLocation;
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
        return freeTicketVoucher[eventId][user][ticketId];
    }
    
    function getTreasurer (uint256 eventId) public view returns (address) {
        return withdrawlApproval[eventId];
    }
    
    function getEventFunds(uint256 eventId) public view returns (uint256) {
        return eventBalance[eventId];
    }

    function createEvent(
            string memory newName, 
            string memory baseURL, 
            string[] memory ticketNames, 
            uint256[] memory ticketPrices, 
            uint256[] memory ticketCapacities, 
            uint256 eventDate, 
            string memory eventLocation, 
            string[] memory performers
            ) public openOffice(){

        require(block.timestamp + 86400 * 3 < eventDate, "Event Must be created at least 3 days in advance");
        
        ERC1155Token ticketNft = new ERC1155Token(baseURL, newName);
        address eventAddress = address(ticketNft);
        require(eventAddress != address(0));
        eventTicketAddress[_eventIdCounter] = eventAddress;
        eventDetails[_eventIdCounter] = TicketDetails(ticketNames,ticketCapacities,ticketPrices,new uint256[](ticketNames.length),newName,msg.sender,eventDate,eventLocation,performers);
        withdrawlApproval[_eventIdCounter] = msg.sender;
        emit Event(_eventIdCounter, newName,eventAddress, ticketNames,ticketPrices, ticketCapacities,eventDate, eventLocation, performers);
        _eventIdCounter++;
    }

    function mintSingleTicket(uint256 eventId, uint256 quantity, uint256 ticketId ,  address to) public openOffice() {
        require(eventTicketAddress[eventId] != address(0), "Event Does Not Exist");
        require(!eventLocked[eventId], "Concert Event is Frozen" );
        address id = eventTicketAddress[eventId];
        uint256 grossCost = getEventPrice(eventId, ticketId) * quantity;
        require(_usdc.balanceOf(msg.sender) == grossCost,"Insufficient Funds HIT FUNCTION CHECK");
        _usdc.transferFrom(msg.sender, address(this), grossCost);
        eventBalance[eventId] += grossCost;
        ERC1155Token(id).mint(to,ticketId,quantity);
        eventDetails[eventId].ticketsSold[ticketId] += quantity;
        emit TicketPurchased(to, eventId, ticketId,quantity);
    }

    function mintMultipleTickets(uint256 eventId, uint256[] memory ticketIds, uint256[] memory amounts, address to) public openOffice() {
        require(eventTicketAddress[eventId] != address(0), "Event Does Not Exist");
        require(!eventLocked[eventId], "Concert Event is Frozen" );
        address id = eventTicketAddress[eventId];
        uint256 grossCost =0;
        for (uint256 i = 0; i < ticketIds.length; i++) {
            grossCost += getEventPrice(eventId, ticketIds[i]) * amounts[i];
        }
        require(_usdc.balanceOf(msg.sender) >= grossCost,"Insufficient Funds HIT FUNCTION CHECK");
        _usdc.transferFrom(msg.sender, address(this), grossCost);
        eventBalance[eventId] += grossCost;
        ERC1155Token(id).mintBatchTickets(to, ticketIds, amounts);
        for (uint256 i = 0; i < ticketIds.length; i++) {
            eventDetails[eventId].ticketsSold[ticketIds[i]] += amounts[i];
        }
        for (uint256 i = 0; i < ticketIds.length; i++) {
            emit TicketPurchased(to, eventId, ticketIds[i],amounts[i]);
        }
        
    }
    
    function redeemTicket(uint256 eventId,uint256 ticketId) public openOffice() {
        require(freeTicketVoucher[eventId][msg.sender][ticketId], "Ineligible for Comped Ticket");
        address id = eventTicketAddress[eventId];
        freeTicketVoucher[eventId][msg.sender][ticketId] = false;
        ERC1155Token(id).mint(msg.sender,ticketId,1);
    }

    function issueRefund(uint256 eventId, uint256 tokenId) public {
        require(eventLocked[eventId], "Ineligible for Refund");
        address id = eventTicketAddress[eventId];
        uint256 userBalance = ERC1155Token(id).balanceOf(msg.sender, tokenId);
        require(userBalance > 0,"Insufficient Balance");
        ERC1155Token(id).burn(msg.sender, tokenId, 1);
        eventBalance[eventId] -= eventDetails[eventId].ticketPrices[tokenId]; 
        uint256 userBalanceAfter = ERC1155Token(id).balanceOf(msg.sender, tokenId);
        require(userBalanceAfter == userBalance - 1, "Token Burn Failed" );
        _usdc.transfer(msg.sender, eventDetails[eventId].ticketPrices[tokenId]);
        
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
            withdrawlApproval[eventId] = treasurer;
            return treasurer;
    }
    
    function compOne(uint256 eventId, address user, uint256 ticketId) public okAdmin(eventId) openOffice() {
        freeTicketVoucher[eventId][user][ticketId] = true;
    }

    function compMany(uint256 eventId, address[] memory users, uint256 ticketId) public okAdmin(eventId) openOffice() {
            for (uint i = 0; i < users.length; i++) {
                freeTicketVoucher[eventId][users[i]][ticketId] = true;
            }
    }
    
    function addPerformers (uint256 eventId, string memory newPerformer) public okAdmin(eventId) openOffice() returns(string[] memory){
        
        eventDetails[eventId].performers.push(newPerformer);
        emit Event(eventId, eventDetails[eventId].name, getAddress(eventId), eventDetails[eventId].ticketNames ,eventDetails[eventId].ticketPrices, eventDetails[eventId].ticketCapacities,
      eventDetails[eventId].eventDate, eventDetails[eventId].concertLocation, eventDetails[eventId].performers) ;
    }
    
    function removePerformers (uint256 eventId, uint256 _index) public okAdmin(eventId) openOffice() returns(string[] memory) {
        require(_index < eventDetails[eventId].performers.length, "Out of bounds");
        for (uint256 i = _index; i < eventDetails[eventId].performers.length - 1; i++) {
            eventDetails[eventId].performers[i] = eventDetails[eventId].performers[i + 1];
        }
        eventDetails[eventId].performers.pop();
        emit Event(eventId, eventDetails[eventId].name, getAddress(eventId), eventDetails[eventId].ticketNames ,eventDetails[eventId].ticketPrices, eventDetails[eventId].ticketCapacities,
      eventDetails[eventId].eventDate, eventDetails[eventId].concertLocation, eventDetails[eventId].performers);
        return eventDetails[eventId].performers;
    }
    
    function changeLocation (uint256 eventId, string memory newLocation) public okAdmin(eventId) openOffice() returns(string memory){
        eventDetails[eventId].concertLocation = newLocation;
        emit Event(eventId, eventDetails[eventId].name, getAddress(eventId), eventDetails[eventId].ticketNames ,eventDetails[eventId].ticketPrices, eventDetails[eventId].ticketCapacities,
      eventDetails[eventId].eventDate, eventDetails[eventId].concertLocation, eventDetails[eventId].performers);
        return eventDetails[eventId].concertLocation;
    }
    
    function changeEventDate(uint256 eventId, uint256 newDate) public okAdmin(eventId) openOffice() returns(uint256){
        require(eventDetails[eventId].eventDate - 172800 >= block.timestamp, "Date change within Locked Period");

        require(newDate > block.timestamp,"Invalid Date");

        eventDetails[eventId].eventDate = newDate;
        emit Event(eventId, eventDetails[eventId].name, getAddress(eventId), eventDetails[eventId].ticketNames ,eventDetails[eventId].ticketPrices, eventDetails[eventId].ticketCapacities,
      eventDetails[eventId].eventDate, eventDetails[eventId].concertLocation, eventDetails[eventId].performers);
        return newDate;
    }

    function changeUri(uint256 eventId, string memory newUri) public okAdmin(eventId) openOffice() returns(string memory){
        address iD = eventTicketAddress[eventId];
        ERC1155Token(iD).updateTicketUri(newUri);
        return newUri;
    }
    
    function withdrawFunds(uint256 eventId) public {
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

    function revokeTickets(address user, uint256 eventId, uint8 tokenId, uint256 value ) public {
        require(msg.sender == _contractOwner, "Unauthorized Access");
        address iD = eventTicketAddress[eventId];
        ERC1155Token(iD).burn(user, tokenId, value);
    }
    

    function closeTicketOffice() public {
        require(_contractOwner == msg.sender, "Unauthorized Access");
        ticketOfficeOpen = false;
    }
}