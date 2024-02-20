// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.20;

import "src/interfaces/IERC20.sol";
import "src/interfaces/IERC1155.sol";
import "src/tokens/ERC1155Base.sol";
import "src/interfaces/ITicketOffice.sol";

contract ERC1155Token is ERC1155 { 
    address public owner;
    string public name;
    uint256 public totalGeneralSupply;
    uint256 public totalVipSupply;
    uint256 public generalTokenId = 0;
    uint256 public vipTokenId = 0;
    

    constructor(string memory newUri, string memory newName, uint256 generalSupply, uint256 vipSupply)  {

        owner = msg.sender;
        name = newName;
        totalGeneralSupply = generalSupply;
        totalVipSupply = vipSupply;
        _setBaseURI(newUri); 
    }

    function mintGeneralTicket(address to,uint256 amount) public {
        require(msg.sender == owner, "Required to use Cheers Finance to Mint Tickets");
        generalTokenId += amount;
        require(generalTokenId < totalGeneralSupply  + 1 , "Tickets Sold Out");
        _mint(to, 0, amount, "");
    }

    function mintVipTicket(address to, uint256 amount) public {
        require(msg.sender == owner, "Required to use Cheers Finance to Mint Tickets");
        vipTokenId += amount;
        require(vipTokenId <= totalVipSupply, "Tickets Sold Out");
        _mint(to, 1, amount,"");
    }

    function mintBatchTickets(address to, uint256[] memory ids, uint256[] memory amounts) public {
        require(msg.sender == owner, "Required to use Cheers Finance to mint tickets");
        require(ids.length == amounts.length,"Ids and Amounts must be equal");
        for (uint256 i; i < ids.length; ++i) {
            if (ids[i] == 0) {
                require(generalTokenId + amounts[i] <= totalGeneralSupply,"General Tickets are over capacity");

            } 
            if (ids[i]==1){
                require(vipTokenId + amounts[i] <= totalVipSupply, "Vip Tickets are over capacity");

            }
        }
        _mintBatch(to, ids, amounts, "");
    }

    function burn(address from, uint256 id, uint256 value) public {
        require(msg.sender == owner, "Required to use Cheers Finance to mint tickets");
        _burn(from, id, value);
    }
}

contract TicketOffice is ITicketOffice{
    struct TicketDetails {
        uint256 generalPrice;
        uint256 vipPrice;
        uint256 generalSupply;
        uint256 vipSupply;
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
    mapping(uint256 => mapping(address => bool)) public freeTicketVoucher;
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

    // Get name of Contract - check
    // Get owner of contract - check
    // Create an Event - check
    // get Event name - check
    // Get Event Owner - check
    // get Event Location - check
    // Get Event Performers - check
    // Get Event Address - check
    // get ticket price - check
    // Get Totaly Supply - check
    // get Tickets Available - check
    // Get Event Date - check
    // create Ticket - ADAPT FOR USDC
    // Stop Ticket Sales - check
    // create Ticket Comp - check
    // redeem ticket - check
    // issue refunds - check
    // Change Performers - check
        // Add Performers
        // Remove Performers
    // approve treasurer - check
    // Withdraw Funds - TO DO
    // Get is Ticket Holder - check

    function name() public view returns(string memory) {
        return _name;
    }

    function contractOwner() public view returns (address) {
        return _contractOwner;
    }

    function createEvent(string memory newName, string memory baseURL, uint256 generalSupply, uint256 vipSupply, uint256 generalPrice,uint256 vipPrice, uint256 eventDate, string memory eventLocation, string[] memory performers) public openOffice(){

        require(block.timestamp + 86400 * 3 < eventDate, "Event Must be created at least 3 days in advance");
        
        ERC1155Token ticketNft = new ERC1155Token(baseURL, newName, generalSupply, vipSupply);
        address eventAddress = address(ticketNft);
        require(eventAddress != address(0));
        eventTicketAddress[_eventIdCounter] = eventAddress;
        eventDetails[_eventIdCounter] = TicketDetails(generalPrice,vipPrice,generalSupply,vipSupply,newName,msg.sender,eventDate,eventLocation,performers);
        withdrawlApproval[_eventIdCounter] = msg.sender;
        emit Event(_eventIdCounter, newName,eventAddress,  generalPrice, vipPrice, generalSupply, vipSupply, eventDate, eventLocation, performers);
        _eventIdCounter++;


    }

    function getEventName(uint256 eventId) public view returns (string memory) {
        return eventDetails[eventId].name;
    }

    function isEventOwner(uint256 eventId, address userAddress) public view returns (bool) {
        return eventDetails[eventId].owner == userAddress ? true : false;
    }

    function getAddress(uint256 eventId) public view returns(address) {
        return eventTicketAddress[eventId];

    }

    function getEventGeneralPrice(uint256 eventId) public view returns (uint256) {
        return eventDetails[eventId].generalPrice;
    }

    function getEventVipPrice(uint256 eventId) public view returns(uint256) {
        return eventDetails[eventId].vipPrice;
    }

    function getEventGeneralCapacity(uint256 eventId) public view returns (uint256) {
        return eventDetails[eventId].generalSupply;

    }

    function getEventVipCapacity(uint256 eventId) public view returns(uint256) {
        return eventDetails[eventId].vipSupply;
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

    function ticketHolderBalance (uint256 eventId, address user) public view returns (uint256[] memory) {
        address[] memory accountArray = new address[](2);
        uint256[] memory idArray = new uint256[](2);
        accountArray[0] = user;
        accountArray[1] = user;
        idArray[0] = 0;
        idArray[1] = 1; 
        address iD = eventTicketAddress[eventId];
         uint256[] memory returnValue = ERC1155Token(iD).balanceOfBatch(accountArray,idArray);
         return returnValue;
    }

    function getEventOwner(uint256 eventId) public view returns(address) {
            return eventDetails[eventId].owner;
        }

    function isTicketHolder(uint256 eventId, address ownerAddress) public view returns(bool) {
        address iD = eventTicketAddress[eventId];
        return ERC1155(iD).balanceOf(ownerAddress,0) != 0 || ERC1155(iD).balanceOf(ownerAddress,1) != 0;
    }


    function mintTicketGeneral(uint256 eventId, uint256 quantity,  address to) public openOffice() {
        require(eventTicketAddress[eventId] != address(0), "Event Does Not Exist");
        require(!eventLocked[eventId], "Concert Event is Frozen" );
        address id = eventTicketAddress[eventId];
        uint256 grossCost = getEventGeneralPrice(eventId) * quantity;
        require(_usdc.balanceOf(msg.sender) >= grossCost,"Insufficient Funds HIT FUNCTION CHECK");
        _usdc.transferFrom(msg.sender, address(this), grossCost);
        eventBalance[eventId] += grossCost;
        ERC1155Token(id).mintGeneralTicket(to,quantity);
        
        emit TicketPurchased(to, eventId, quantity);
        
    }

    function mintTicketVip(uint256 eventId, uint256 quantity,  address to) public openOffice() {
        require(eventTicketAddress[eventId] != address(0), "Event Does Not Exist");
        require(!eventLocked[eventId], "Concert Event is Frozen" );
        address id = eventTicketAddress[eventId];
        uint256 grossCost = getEventVipPrice(eventId) * quantity;
        require(_usdc.balanceOf(msg.sender) >= grossCost,"Insufficient Funds HIT FUNCTION CHECK");
        _usdc.transferFrom(msg.sender, address(this), grossCost);
        eventBalance[eventId] += grossCost;
        ERC1155Token(id).mintVipTicket(to,quantity);
        emit TicketPurchased(to, eventId, 1);
        
    }

    function issueRefund(uint256 eventId, uint256 tokenId) public {
        require(eventLocked[eventId], "Ineligible for Refund");
        address id = eventTicketAddress[eventId];
        uint256 userBalance = ERC1155Token(id).balanceOf(msg.sender, tokenId);
        require(userBalance > 0,"Insufficient Balance");
        ERC1155Token(id).burn(msg.sender, tokenId, 1);
        if (tokenId == 1) {
           eventBalance[eventId] -= eventDetails[eventId].vipPrice; 
           uint256 userBalanceAfter = ERC1155Token(id).balanceOf(msg.sender, tokenId);
        require(userBalanceAfter == userBalance - 1, "Token Burn Failed" );
        _usdc.transfer(msg.sender, eventDetails[eventId].vipPrice);
        }
        else {
            eventBalance[eventId] -= eventDetails[eventId].generalPrice; 
           uint256 userBalanceAfter = ERC1155Token(id).balanceOf(msg.sender, tokenId);
        require(userBalanceAfter == userBalance - 1, "Token Burn Failed" );
        _usdc.transfer(msg.sender, eventDetails[eventId].generalPrice);

        }
        
        

    }

    function withdrawFunds(uint256 eventId) public {
        require(block.timestamp - 86400 >= eventDetails[eventId].eventDate, "Withdraw must be one day after Event");
        if (eventLocked[eventId]) {
            revert("Funds are locked for refunds");
        }
        require(msg.sender == eventDetails[eventId].owner ||  msg.sender == withdrawlApproval[eventId], "Unauthorized Access");
        uint256 payOut= eventBalance[eventId] * 95 / 100;
        _usdc.transfer(_contractOwner, eventBalance[eventId] * 5 / 100);
        _usdc.transfer(eventDetails[eventId].owner, payOut);
        eventBalance[eventId] = 0;
        eventLocked[eventId] = true;
        

    }
    

    function redeemTicket(uint256 eventId) public {
        require(freeTicketVoucher[eventId][msg.sender], "Ineligible for Comped Ticket");
        address id = eventTicketAddress[eventId];
        freeTicketVoucher[eventId][msg.sender] = false;
        ERC1155Token(id).mintGeneralTicket(msg.sender,1);
    }

    function compOne(uint256 eventId, address user) public okAdmin(eventId) {
        freeTicketVoucher[eventId][user] = true;

    }

    function compMany(uint256 eventId, address[] memory users) public okAdmin(eventId) {
            for (uint i = 0; i < users.length; i++) {
                freeTicketVoucher[eventId][users[i]] = true;
            }
    }

    

    function lockEvent(uint256 eventId) public   {
        require(_contractOwner == msg.sender, "Unauthorized Access");
        eventLocked[eventId] = true;

    }

    function unLockEvent(uint256 eventId) public {
        require(_contractOwner == msg.sender, "Unauthorized Access");
        eventLocked[eventId] = false;
    }

    function approveTreasurer(uint256 eventId, address treasurer) public okAdmin(eventId) returns(address){
        withdrawlApproval[eventId] = treasurer;
        return treasurer;


    }

    // Add Performers
    function addPerformers (uint256 eventId, string memory newPerformer) public okAdmin(eventId) returns(string[] memory){
        
        eventDetails[eventId].performers.push(newPerformer);
        emit Event(eventId, eventDetails[eventId].name, getAddress(eventId), eventDetails[eventId].generalPrice, eventDetails[eventId].vipPrice, eventDetails[eventId].generalSupply, eventDetails[eventId].vipSupply, eventDetails[eventId].eventDate, eventDetails[eventId].concertLocation, eventDetails[eventId].performers);
        return eventDetails[eventId].performers;

    }

    function getTreasurer (uint256 eventId) public view returns (address) {
        return withdrawlApproval[eventId];
    }

    function getEventFunds(uint256 eventId) public view returns (uint256) {
        return eventBalance[eventId];
    }

    // Remove Performers
    function removePerformers (uint256 eventId, uint256 _index) public okAdmin(eventId) returns(string[] memory) {
        require(_index < eventDetails[eventId].performers.length, "Out of bounds");
        for (uint256 i = _index; i < eventDetails[eventId].performers.length - 1; i++) {
            eventDetails[eventId].performers[i] = eventDetails[eventId].performers[i + 1];
        }
        eventDetails[eventId].performers.pop();
        emit Event(eventId, eventDetails[eventId].name, getAddress(eventId), eventDetails[eventId].generalPrice, eventDetails[eventId].vipPrice, eventDetails[eventId].generalSupply, eventDetails[eventId].vipSupply, eventDetails[eventId].eventDate, eventDetails[eventId].concertLocation, eventDetails[eventId].performers);
        return eventDetails[eventId].performers;
    }

    // change Location
    function changeLocation (uint256 eventId, string memory newLocation) public okAdmin(eventId) returns(string memory){
        eventDetails[eventId].concertLocation = newLocation;
        emit Event(eventId, eventDetails[eventId].name, getAddress(eventId), eventDetails[eventId].generalPrice, eventDetails[eventId].vipPrice, eventDetails[eventId].generalSupply, eventDetails[eventId].vipSupply, eventDetails[eventId].eventDate, eventDetails[eventId].concertLocation, eventDetails[eventId].performers);
        return eventDetails[eventId].concertLocation;
    }

    // close ticketOffice
    function closeTicketOffice() public {
        require(_contractOwner == msg.sender, "Unauthorized Access");
        ticketOfficeOpen = false;

    }

    function issuedComp(uint256 eventId, address user) public view returns(bool) {
        return freeTicketVoucher[eventId][user];
    }

    function changeEventDate(uint256 eventId, uint256 newDate) public okAdmin(eventId) returns(uint256){
        require(eventDetails[eventId].eventDate - 172800 >= block.timestamp, "Date change within Locked Period");

        require(newDate > block.timestamp,"Invalid Date");

        eventDetails[eventId].eventDate = newDate;
        emit Event(eventId, eventDetails[eventId].name, getAddress(eventId), eventDetails[eventId].generalPrice, eventDetails[eventId].vipPrice, eventDetails[eventId].generalSupply, eventDetails[eventId].vipSupply, eventDetails[eventId].eventDate, eventDetails[eventId].concertLocation, eventDetails[eventId].performers);
        return newDate;

    }
}