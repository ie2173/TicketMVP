// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.20;

import "../libraries/TicketStructs.sol";

interface ITicketOffice {

    event Event(uint256 indexed eventIdCounter, string name, address nftAddress,string ticketUri,  TicketStructs.TicketData ticketData, address owner,
      uint256 eventDate, TicketStructs.Location location, string[] performers, string[] keywords, string[] categories, string eventType);

    event TicketPurchased(address indexed buyer, uint256 indexed eventId, uint256 indexed ticketTierIndexId, uint256 quantity);

  
    function contractOwner() external view returns (address);
    function getEventName(uint256 eventId) external view returns (string memory);
    function getTicketNames(uint256 eventId) external view returns (string[] memory);
    function isEventOwner(uint256 eventId, address userAddress) external view returns (bool);
    function getAddress(uint256 eventId) external view returns (address);
    function getTicketPrice(uint256 eventId, uint256 ticketId) external view returns (uint256);
    function getTicketPrices(uint256 eventId) external view returns (uint256[] memory);
    function getEventCapacity(uint256 eventId, uint256 ticketId) external view returns (uint256);
    function getEventCapacities(uint256 eventId) external view returns (uint256[] memory);
    function getEventDate(uint256 eventId) external view returns (uint256);
    function getEventLocation(uint256 eventId) external view returns (TicketStructs.Location memory);
    function getEventPerformers(uint256 eventId) external view returns (string[] memory);
    function ticketHoldersBalance(uint256 eventId, address[] memory users, uint256[] memory ticketIds) external view returns (uint256[] memory);
    function getEventOwner(uint256 eventId) external view returns (address);
    function isTicketHolder(uint256 eventId, address ownerAddress, uint256 ticketId) external view returns (bool);
    function issuedComp(uint256 eventId, address user, uint256 ticketId) external view returns (bool);
    function getTreasurer(uint256 eventId) external view returns (address);
    function getEventFunds(uint256 eventId) external view returns (uint256);
    function createEvent(
            TicketStructs.Ticketdetails memory ticketDetails, 
            string memory baseURL
            
            ) external;
    function mintTickets(uint256 eventId, uint256[] memory ticketIds, uint256[] memory amounts, address to) external;
    function redeemTicket(uint256 eventId, uint256 ticketId) external;
    function issueRefund(uint256 eventId, uint256 tokenId) external;
    function lockEvent(uint256 eventId) external;
    function unLockEvent(uint256 eventId) external;
    function approveTreasurer(uint256 eventId, address treasurer) external returns (address);
    
    function compTickets(uint256 eventId, address[] memory users, uint256 ticketId) external;
    function addPerformers(uint256 eventId, string memory newPerformer) external returns (string[] memory);
    function removePerformers(uint256 eventId, uint256 _index) external returns (string[] memory);
    function changeLocation(uint256 eventId, string memory newLocation, string memory newLatLong) external returns (TicketStructs.Location memory);
    function changeEventDate(uint256 eventId, uint256 newDate) external returns (uint256);
    function changeUri(uint256 eventId, string memory newUri) external returns (string memory);
    function withdrawFunds(uint256 eventId) external;
    function revokeTickets(address user, uint256 eventId, uint8 tokenId, uint256 value) external;
}