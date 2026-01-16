// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ITicketOffice } from "./interfaces/ITicketOffice.sol";
import { TicketOfficeFactory } from "./TicketOfficeFactory.sol";
import { TicketStructs } from "./libraries/TicketStructs.sol";
import { EventContract } from "./EventContract.sol";
import { IERC1155 } from "./interfaces/IERC1155.sol";

contract CompatibilityAdapter is ITicketOffice {
  TicketOfficeFactory public factory;

  constructor(address factoryAddr) {
    factory = TicketOfficeFactory(factoryAddr);
  }

  // --- Read helpers ---
  function getEventName(uint256 eventId) external view returns (string memory) {
    TicketStructs.BasicEventInfo memory info = factory.getEventInfo(eventId);
    return info.name;
  }

  function getTicketNames(uint256 eventId) external view returns (string[] memory) {
    address ev = factory.getEventContract(eventId);
    EventContract e = EventContract(ev);
    return e.getTicketNames();
  }

  function isEventOwner(uint256 eventId, address userAddress) external view returns (bool) {
    TicketStructs.BasicEventInfo memory info = factory.getEventInfo(eventId);
    return (info.owner == userAddress);
  }

  function getAddress(uint256 eventId) external view returns (address) {
    return factory.getEventContract(eventId);
  }

  function getTicketPrice(uint256 eventId, uint256 ticketId) external view returns (uint256) {
    address ev = factory.getEventContract(eventId);
    return EventContract(ev).getTicketPrice(ticketId);
  }

  function getTicketPrices(uint256 eventId) external view returns (uint256[] memory) {
    address ev = factory.getEventContract(eventId);
    return EventContract(ev).getTicketPrices();
  }

  function getEventCapacity(uint256 eventId, uint256 ticketId) external view returns (uint256) {
    address ev = factory.getEventContract(eventId);
    return EventContract(ev).getTicketCapacities()[ticketId];
  }

  function getEventCapacities(uint256 eventId) external view returns (uint256[] memory) {
    address ev = factory.getEventContract(eventId);
    return EventContract(ev).getTicketCapacities();
  }

  function getTicketsSold(uint256 eventId) external returns (uint256[] memory) {
    address ev = factory.getEventContract(eventId);
    return EventContract(ev).getTicketsSoldAll();
  }

  function getEventDate(uint256 eventId) external view returns (uint256) {
    TicketStructs.BasicEventInfo memory info = factory.getEventInfo(eventId);
    return info.eventDate;
  }

  function getEventLocation(uint256 eventId) external view returns (TicketStructs.LocationDetails memory) {
    address ev = factory.getEventContract(eventId);
    return EventContract(ev).getLocation();
  }

  function getEventPerformers(uint256 eventId) external view returns (string[] memory) {
    address ev = factory.getEventContract(eventId);
    return EventContract(ev).getPerformers();
  }

  function ticketHoldersBalance(
    uint256 eventId,
    address[] memory users,
    uint256[] memory ticketIds
  ) external view returns (uint256[] memory balances) {
    require(users.length == ticketIds.length, "Array mismatch");
    address ev = factory.getEventContract(eventId);
    address token = EventContract(ev).ticketNftAddress();
    balances = new uint256[](users.length);
    for (uint256 i = 0; i < users.length; ++i) {
      balances[i] = IERC1155(token).balanceOf(users[i], ticketIds[i]);
    }
  }

  function getEventOwner(uint256 eventId) external view returns (address) {
    TicketStructs.BasicEventInfo memory info = factory.getEventInfo(eventId);
    return info.owner;
  }

  function isTicketHolder(
    uint256 eventId,
    address ownerAddress,
    uint256 ticketId
  ) external view returns (bool) {
    address ev = factory.getEventContract(eventId);
    address token = EventContract(ev).ticketNftAddress();
    return IERC1155(token).balanceOf(ownerAddress, ticketId) > 0;
  }

  function issuedComp(uint256 eventId, address user, uint256 ticketId) external view returns (bool) {
    address ev = factory.getEventContract(eventId);
    return EventContract(ev).ticketComped(user, ticketId);
  }

  function getTreasurer(uint256 eventId) external view returns (address) {
    address ev = factory.getEventContract(eventId);
    return EventContract(ev).treasurerAddress();
  }

  function getEventFunds(uint256 eventId) external view returns (uint256) {
    address ev = factory.getEventContract(eventId);
    return EventContract(ev).getEventBalance();
  }

  // --- Create Event (adapts the old signature) ---
  function createEvent(
    TicketStructs.Ticketdetails calldata ticketDetails,
    TicketStructs.Tickets calldata ticketInformation,
    string memory baseURL
  ) external {
    // adapt TicketStructs.Tickets -> TicketStructs.TicketInformation
    TicketStructs.TicketInformation memory info = TicketStructs.TicketInformation({
      ticketNames: ticketInformation.ticketNames,
      ticketCapacities: ticketInformation.ticketCapacities,
      ticketPrices: ticketInformation.ticketPrices
    });

    factory.createEvent(ticketDetails, info, baseURL);
  }

  // --- Write functions: NOT proxied (users must call event contract directly) ---
  function mintSingleTicket(uint256,uint256,uint256,address) external {
    revert("Write operations must call EventContract directly");
  }
  function mintMultipleTickets(uint256,uint256[] memory,uint256[] memory,address) external {
    revert("Write operations must call EventContract directly");
  }
  function redeemTicket(uint256,uint256) external {
    revert("Write operations must call EventContract directly");
  }
  function issueRefund(uint256) external {
    revert("Write operations must call EventContract directly");
  }
  function lockEvent(uint256) external {
    revert("Admin operations must call EventContract directly");
  }
  function unLockEvent(uint256) external {
    revert("Admin operations must call EventContract directly");
  }
  function approveTreasurer(uint256,address) external returns (address) {
    revert("Admin operations must call EventContract directly");
  }
  function compOne(uint256,address,uint256) external {
    revert("Admin operations must call EventContract directly");
  }
  function compMany(uint256,address[] memory,uint256) external {
    revert("Admin operations must call EventContract directly");
  }
  function editEvent(uint256,TicketStructs.Ticketdetails calldata) external {
    revert("Admin operations must call EventContract directly");
  }
  function changeUri(uint256,string memory) external returns (string memory) {
    revert("Admin operations must call EventContract directly");
  }
  function withdrawFunds(uint256) external {
    revert("Admin operations must call EventContract directly");
  }
  function revokeTickets(address,uint256,uint8,uint256) external {
    revert("Admin operations must call EventContract directly");
  }
}
