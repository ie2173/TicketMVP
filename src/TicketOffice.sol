// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.20;

import "src/interfaces/IERC20.sol";
import "src/interfaces/IERC721.sol";
import "src/tokens/ERC721Base.sol";
import "src/interfaces/ITicketOffice.sol";

contract ERC721Tickets is ERC721Base {
    address public owner;
    uint256 public totalSupply;
    uint256 public tokenId = 0;

    constructor(string memory _name, string memory _symbol, string memory _baseURL, uint256 _totalSupply) {
        __name = _name;
        __symbol = _symbol;
        __baseURL = _baseURL;
        totalSupply = _totalSupply;
        owner = msg.sender;

        }

    function mint(address _to) public {
        require(msg.sender == owner, "Required to use Cheers Finance ticket booth to create ticket");
        require(tokenId < totalSupply, "Event Sold Out");
        _mint(_to, tokenId);
        tokenId++;
    }

}

contract TicketOffice {
    struct TicketDetails {
        uint256 price;
        uint256 totalSupply;
        string name;
        address owner;
        uint256 eventDate;
        string concertLocation;
        string[] performers;
    }
    
    IERC20 public USDC;
    ERC721Tickets public ticketNft;
    string internal __name;
    address internal ContractOwner;
    uint256 internal eventIdCounter = 0;
    mapping(uint256 => address) public eventTicketAddress;
    mapping(uint256 => mapping(address => bool)) public freeTicketVoucher;
    mapping(uint256 => TicketDetails) public eventDetails;
    mapping(uint256 => uint256) public eventBalance;
    mapping(uint256 => address) public withdrawlApproval;
    mapping(uint256 => bool) public EventLocked; 
    bool public TicketOfficeOpen = true;
    
    event EventCreated(string name, address ContractAddress);

    event TicketPurchased(string name, address ContractAddress, address ticketOwner);

    constructor(string memory  _name, address _USDCAddress) {
        ContractOwner = msg.sender;
        __name = _name;
        USDC = IERC20(_USDCAddress);
        TicketOfficeOpen = true;

    }

    modifier okAdmin(uint256 _EventId) {
        require(getEventOwner(_EventId) == msg.sender, "Unauthorized user");
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
        return __name;
    }

    function contractOwner() public view returns (address) {
        return ContractOwner;
    }

    function createEvent(string memory _name, string memory _symbol, string calldata _baseURL, uint256 _totalSupply, uint256 _ticketPrice, uint256 _eventDate, string memory _eventLocation, string[] memory _performers) public {
        require(TicketOfficeOpen, "Ticket Office is Closed");
        ticketNft = new ERC721Tickets(_name,_symbol,_baseURL,_totalSupply);
        address eventAddress = address(ticketNft);
        eventTicketAddress[eventIdCounter] = eventAddress;
        eventDetails[eventIdCounter] = TicketDetails(_ticketPrice,_totalSupply,_name,msg.sender,_eventDate,_eventLocation,_performers);
        emit EventCreated(_name, eventAddress);
        eventIdCounter++;

    }

    function getEventName(uint256 _EventId) public view returns (string memory) {
        return eventDetails[_EventId].name;
    }

    function isEventOwner(uint256 _EventId, address _address) public view returns (bool) {
        return eventDetails[_EventId].owner == _address ? true : false;
    }

    function getAddress(uint256 _EventId) public view returns(address) {
        return eventTicketAddress[_EventId];

    }

    function getEventPrice(uint256 _EventId) public view returns (uint256) {
        return eventDetails[_EventId].price;
    }

    function getEventCapacity(uint256 _EventId) public view returns (uint256) {
        return eventDetails[_EventId].totalSupply;

    }

    function getEventDate(uint256 _EventId) public view returns (uint256) {
        return eventDetails[_EventId].eventDate;
    }

    function getEventLocation(uint256 _EventId) public view returns (string memory ) {
        return eventDetails[_EventId].concertLocation;
    }

    function getEventPerformers(uint256 _EventId) public view returns (string[] memory ) {
        return eventDetails[_EventId].performers;
    }

    function isTicketOwner (uint256 _EventId, address _User) public view returns (uint256) {
        address ID = eventTicketAddress[_EventId];
        return ERC721Tickets(ID).balanceOf(_User);
    }

    function getEventOwner(uint256 _EventId) public view returns(address) {
            return eventDetails[_EventId].owner;
        }
    function getTicketBalance(uint256 _EventId, address _ownerAddress) public view returns(uint256) {
        address ID = eventTicketAddress[_EventId];
        return ERC721Tickets(ID).balanceOf(_ownerAddress);
    }


    function mintTicket(uint256 _EventId, uint256 _quantity, address _to) public {
        require(!EventLocked[_EventId], "Concert Event is Frozen" );
        require(TicketOfficeOpen, "Ticket Office is Closed");
        uint256 grossCost = getEventPrice(_EventId * _quantity);
        require(USDC.balanceOf(msg.sender) >= grossCost,"Insufficient Funds");
        require(eventTicketAddress[_EventId] != address(0), "Event Does Not Exist");
        eventBalance[_EventId] += grossCost;
        USDC.approve(address(this), grossCost);
        (bool success) = USDC.transferFrom(msg.sender, address(this), grossCost);
        require(success, "USDC Transfer Failed");
        for (uint256 i=0; i < _quantity; i++) {
            ERC721Tickets(eventTicketAddress[_EventId]).mint(_to);
        }
    }

    function withdrawFunds(uint256 _EventId) public {
        require(block.timestamp + 86400 >= eventDetails[_EventId].eventDate, "Withdraw must be one day after Event");
        if (EventLocked[_EventId]) {
            // Refund Event Here
        }
        require(msg.sender == eventDetails[_EventId].owner ||  msg.sender == withdrawlApproval[_EventId], "Unauthorized Access");
        USDC.transfer(eventDetails[_EventId].owner, eventBalance[_EventId]);

    }
    

    function RedeemTicket(uint256 _EventId) public {
        require(TicketOfficeOpen, "Ticket Office is Closed");
        require(freeTicketVoucher[_EventId][msg.sender] == true, "Not Qualified to Redeem Ticket");
        freeTicketVoucher[_EventId][msg.sender] = false;
        ERC721Tickets(getAddress(_EventId)).mint(msg.sender);
    }

    function compOne(uint256 _EventId, address _address) public okAdmin(_EventId) {
        freeTicketVoucher[_EventId][_address] = true;

    }

    function compMany(uint256 _EventId, address[] memory _addresses) public okAdmin(_EventId) {
            for (uint i = 0; i < _addresses.length; i++) {
                freeTicketVoucher[_EventId][_addresses[i]] = true;
            }
    }

    function _callRefund(uint256 _EventId) public {
        require(ContractOwner == msg.sender, "Unauthorized Access");
        require(EventLocked[_EventId] == true, "Event Not Eligible for Refund");
        address ID = eventTicketAddress[_EventId];
        uint256 Tickets = ERC721Tickets(ID).tokenId();
        for (uint i = 0; i < Tickets; i++) {
            USDC.transfer(ERC721Tickets(ID).ownerOf(i), eventDetails[_EventId].price);
        }


    }

    function lockEvent(uint256 _EventId) public  {
        require(ContractOwner == msg.sender, "Unauthorized Access");
        EventLocked[_EventId] = true;

    }

    function unLockEvent(uint256 _EventId) public {
        require(ContractOwner == msg.sender, "Unauthorized Access");
        EventLocked[_EventId] = false;
    }

    function approveWithdrawl(uint256 _EventId, address _Treasurer) public okAdmin(_EventId) {
        withdrawlApproval[_EventId] = _Treasurer;


    }

    // Add Performers
    function addPerformers (uint256 _EventId, string memory _NewPerformer) public okAdmin(_EventId){
        eventDetails[_EventId].performers.push(_NewPerformer);

    }

    // Remove Performers
    function removePerformers (uint256 _EventId, uint256 _index) public {
        require(_index < eventDetails[_EventId].performers.length, "Out of bounds");
        for (uint256 i = _index; i < eventDetails[_EventId].performers.length - 1; i++) {
            eventDetails[_EventId].performers[i] = eventDetails[_EventId].performers[i + 1];
        }
        eventDetails[_EventId].performers.pop();
    }

    // change Location
    function changeLocation (uint256 _EventId, string memory _NewLocation) public {
        eventDetails[_EventId].concertLocation = _NewLocation;
    }

    // close ticketOffice
    function closeTicketOffice() public {
        require(ContractOwner == msg.sender, "Unauthorized Access");
        TicketOfficeOpen = false;

    }
}