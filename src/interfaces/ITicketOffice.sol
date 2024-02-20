// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.20;

interface ITicketOffice {

    event Event(uint256 indexed eventIdCounter, string name, address contractAddress, uint256 generalPrice,uint256 vipPrice, uint256 generalSupply,
    uint256 vipSupply , uint256 eventDate, string concertLocation, string[] performers);

    event TicketPurchased(address indexed buyer, uint256 indexed eventId, uint256 quantity);

    // View Functions 
    function name() external returns (string memory );

    function contractOwner() external returns (address);


    function getEventName(uint256 eventId) external returns (string memory);

    function isEventOwner(uint256 eventId, address userAddress) external returns (bool);

    function getAddress(uint256 eventId) external returns (address);

    function getEventGeneralPrice(uint256 eventId) external returns (uint256);

    function getEventVipPrice(uint256 eventId) external returns(uint256);

    function getEventGeneralCapacity(uint256 eventId) external returns(uint256);

    function getEventVipCapacity(uint256 eventId) external returns (uint256);

    function getEventDate(uint256 eventId) external returns (uint256);

    function getEventLocation(uint256 eventId) external returns (string memory);

    function getEventPerformers(uint256 eventId) external returns (string[] memory);

    function ticketHolderBalance(uint256 eventId, address user) external returns (uint256[] memory);
    
    function getEventOwner(uint256 eventId) external returns(address);

    function isTicketHolder(uint256 eventId, address user) external returns (bool);

    function issuedComp(uint256 eventId, address user) external returns (bool);

    // User Functions
    
    function createEvent(string memory newName, string memory baseURL, uint256 generalSupply, uint256 vipSupply, uint256 generalPrice, uint256 vipPrice, uint256 eventDate, string memory eventLocation, string[] memory performers) external;

    function mintTicketGeneral(uint256 eventId, uint256 quantity, address to) external;

    function mintTicketVip(uint256 eventId, uint256 quantity, address to) external;

    function redeemTicket(uint256 eventId) external;

    function issueRefund(uint256 eventId, uint256 tokenId) external;

 // Admin Functions

    function lockEvent(uint256 eventId) external;

    function unLockEvent(uint256 eventId) external;

    function approveTreasurer(uint256 eventId, address treasurer) external returns (address);

    function compOne(uint256 eventId, address user) external;

    function compMany(uint256 eventId, address[] memory users ) external;

    function addPerformers (uint256 eventId, string memory newPerformer) external returns(string[] memory);

    function removePerformers(uint256 eventId, uint256 index) external returns(string[] memory);

    function changeLocation(uint256 eventId, string memory newLocation) external returns (string memory);

    function changeEventDate(uint256 eventId, uint256 newDate) external returns (uint256);

    function withdrawFunds(uint256 eventId) external; 

    



    

}