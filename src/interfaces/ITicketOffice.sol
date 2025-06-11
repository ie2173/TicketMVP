// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../libraries/TicketStructs.sol";

interface ITicketOffice {
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
    address indexed buyer,
    uint256 indexed eventId,
    uint256 indexed ticketTierIndexId,
    uint256 quantity
  );

  function getEventName(uint256 eventId) external view returns (string memory);
  function getTicketNames(uint256 eventId) external view returns (string[] memory);
  function isEventOwner(uint256 eventId, address userAddress) external view returns (bool);
  function getAddress(uint256 eventId) external view returns (address);
  function getTicketPrice(uint256 eventId, uint256 ticketId) external view returns (uint256);
  function getTicketPrices(uint256 eventId) external view returns (uint256[] memory);
  function getEventCapacity(uint256 eventId, uint256 ticketId) external view returns (uint256);
  function getEventCapacities(uint256 eventId) external view returns (uint256[] memory);
  function getTicketsSold(uint256 eventId) external returns (uint256[] memory);
  function getEventDate(uint256 eventId) external view returns (uint256);
  function getEventLocation(uint256 eventId)
    external
    view
    returns (TicketStructs.LocationDetails memory);
  function getEventPerformers(uint256 eventId) external view returns (string[] memory);
  function ticketHoldersBalance(
    uint256 eventId,
    address[] memory users,
    uint256[] memory ticketIds
  )
    external
    view
    returns (uint256[] memory);
  function getEventOwner(uint256 eventId) external view returns (address);
  function isTicketHolder(
    uint256 eventId,
    address ownerAddress,
    uint256 ticketId
  )
    external
    view
    returns (bool);
  function issuedComp(uint256 eventId, address user, uint256 ticketId) external view returns (bool);
  function getTreasurer(uint256 eventId) external view returns (address);
  function getEventFunds(uint256 eventId) external view returns (uint256);
  function createEvent(
    TicketStructs.Ticketdetails calldata ticketDetails,
    TicketStructs.Tickets calldata ticketInformation,
    string memory baseURL
  )
    external;
  function mintSingleTicket(
    uint256 eventId,
    uint256 quantity,
    uint256 ticketId,
    address to
  )
    external;
  function mintMultipleTickets(
    uint256 eventId,
    uint256[] memory ticketIds,
    uint256[] memory amounts,
    address to
  )
    external;
  function redeemTicket(uint256 eventId, uint256 ticketId) external;
  function issueRefund(uint256 eventId) external;
  function lockEvent(uint256 eventId) external;
  function unLockEvent(uint256 eventId) external;
  function approveTreasurer(uint256 eventId, address treasurer) external returns (address);
  function compOne(uint256 eventId, address user, uint256 ticketId) external;
  function compMany(uint256 eventId, address[] memory users, uint256 ticketId) external;
  function editEvent(uint256 eventId, TicketStructs.Ticketdetails calldata ticketDetails) external;
  //function addPerformers(uint256 eventId, string memory newPerformer) external returns (string[] memory);
  //function removePerformers(uint256 eventId, uint256 _index) external returns (string[] memory);
  //function changeLocation(uint256 eventId, string memory newLocation) external returns (string memory);
  //function changeEventDate(uint256 eventId, uint256 newDate) external returns (uint256);
  function changeUri(uint256 eventId, string memory newUri) external returns (string memory);
  function withdrawFunds(uint256 eventId) external;
  function revokeTickets(address user, uint256 eventId, uint8 tokenId, uint256 value) external;
}
