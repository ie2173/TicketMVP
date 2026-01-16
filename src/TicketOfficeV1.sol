// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "./interfaces/IERC20.sol";
import { ITicketOffice } from "./interfaces/ITicketOffice.sol";
import { TicketStructs } from "./libraries/TicketStructs.sol";
import { TicketValidationLib } from "./libraries/TicketValidationLib.sol";
import { PaymentLib } from "./libraries/PaymentLib.sol";
import { TicketOfficeStorage } from "./TicketOfficeStorage.sol";
import { ERC1155Token } from "./TicketOffice.sol"; // Import the ERC1155Token from original file
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title TicketOfficeV1
 * @dev Modular implementation of ticket office with proxy support
 */
contract TicketOfficeV1 is ITicketOffice, TicketOfficeStorage, ReentrancyGuard {
  using TicketStructs for TicketStructs.Ticketdetails;
  using TicketStructs for TicketStructs.LocationDetails;
  using TicketValidationLib for TicketStructs.Ticketdetails;
  using PaymentLib for IERC20;

  // Constants to save gas
  uint256 private constant MAX_TICKETS_PER_PURCHASE = 10;
  
  modifier onlyOwner() {
    require(msg.sender == _contractOwner, "Only owner");
    _;
  }

  modifier onlyEventOwner(uint256 eventId) {
    require(getEventOwner(eventId) == msg.sender, "Only event owner");
    _;
  }

  modifier openOffice() {
    require(ticketOfficeOpen, "Ticket Office is Closed");
    _;
  }

  modifier validEventId(uint256 eventId) {
    require(eventId < _eventIdCounter, "Invalid event ID");
    _;
  }

  /**
   * @dev Initialize the contract (replaces constructor for proxy)
   */
  function initialize(string memory name_, address usdcAddress, address owner) external {
    require(_contractOwner == address(0), "Already initialized");
    require(owner != address(0), "Invalid owner");
    require(usdcAddress != address(0), "Invalid USDC address");
    
    _name = name_;
    _usdcAddress = usdcAddress;
    _contractOwner = owner;
    ticketOfficeOpen = true;
    
    emit Initialized(owner, usdcAddress);
  }

  /**
   * @dev Create a new event with optimized storage
   */
  function createEvent(
    TicketStructs.Ticketdetails calldata details,
    TicketStructs.Tickets calldata ticketInformation,
    string memory baseUri
  ) external openOffice {
    require(details.owner == msg.sender, "Invalid event owner");
    require(details.eventDate > block.timestamp, "Event date in past");
    require(ticketInformation.ticketNames.length > 0, "No tickets defined");
    require(ticketInformation.ticketNames.length == ticketInformation.ticketPrices.length, "Mismatched arrays");

    uint256 eventId = _eventIdCounter++;
    
    // Create NFT contract
    ERC1155Token ticketNft = new ERC1155Token(baseUri, details.name);
    eventTicketAddress[eventId] = address(ticketNft);
    
    // Store event details efficiently
    eventDetailsEncoded[eventId] = abi.encode(details, ticketInformation);
    
    emit EventCreated(eventId, details.owner, address(ticketNft));
  }

  /**
   * @dev Purchase tickets with optimized validation
   */
  function mintSingleTicket(
    uint256 eventId,
    uint256 ticketId,
    uint256 quantity
  ) external openOffice validEventId(eventId) nonReentrant {
    require(quantity > 0 && quantity <= MAX_TICKETS_PER_PURCHASE, "Invalid quantity");
    
    (TicketStructs.Ticketdetails memory details, TicketStructs.Tickets memory ticketInfo) = 
      _decodeEventData(eventId);
    
    uint256 totalCost = ticketInfo.ticketPrices[ticketId] * quantity;
    IERC20 usdc = IERC20(_usdcAddress);
    
    // Validate purchase using library
    TicketValidationLib.validateTicketPurchase(
      details,
      ticketId,
      quantity,
      totalCost,
      usdc.balanceOf(msg.sender)
    );
    
    // Process payment
    PaymentLib.processPayment(
      usdc,
      msg.sender,
      address(this),
      totalCost,
      eventBalance,
      eventId
    );
    
    // Update ticket counts
    ticketInfo.ticketsSold[ticketId] += quantity;
    eventDetailsEncoded[eventId] = abi.encode(details, ticketInfo);
    
    // Mint NFT
    ERC1155Token(eventTicketAddress[eventId]).mint(msg.sender, ticketId, quantity);
    
    emit TicketPurchased(msg.sender, eventId, ticketId, quantity);
  }

  /**
   * @dev Purchase multiple ticket types
   */
  function mintMultipleTickets(
    uint256 eventId,
    uint256[] calldata ticketIds,
    uint256[] calldata quantities
  ) external openOffice validEventId(eventId) nonReentrant {
    require(ticketIds.length == quantities.length && ticketIds.length > 0, "Invalid arrays");
    require(ticketIds.length <= MAX_TICKETS_PER_PURCHASE, "Too many ticket types");
    
    (TicketStructs.Ticketdetails memory details, TicketStructs.Tickets memory ticketInfo) = 
      _decodeEventData(eventId);
    
    uint256 totalCost = TicketValidationLib.calculateTotalCost(ticketInfo, ticketIds, quantities);
    IERC20 usdc = IERC20(_usdcAddress);
    
    // Process payment
    PaymentLib.processPayment(
      usdc,
      msg.sender,
      address(this),
      totalCost,
      eventBalance,
      eventId
    );
    
    // Update ticket counts
    TicketValidationLib.updateTicketsSold(ticketInfo, ticketIds, quantities);
    eventDetailsEncoded[eventId] = abi.encode(details, ticketInfo);
    
    // Mint NFTs
    ERC1155Token(eventTicketAddress[eventId]).mintBatchTickets(msg.sender, ticketIds, quantities);
    
    for (uint256 i = 0; i < ticketIds.length; i++) {
      emit TicketPurchased(msg.sender, eventId, ticketIds[i], quantities[i]);
    }
  }

  // Simplified view functions
  function getEventOwner(uint256 eventId) public view validEventId(eventId) returns (address) {
    (TicketStructs.Ticketdetails memory details,) = _decodeEventData(eventId);
    return details.owner;
  }

  function getEventName(uint256 eventId) external view validEventId(eventId) returns (string memory) {
    (TicketStructs.Ticketdetails memory details,) = _decodeEventData(eventId);
    return details.name;
  }

  function getTicketPrices(uint256 eventId) external view validEventId(eventId) returns (uint256[] memory) {
    (, TicketStructs.Tickets memory ticketInfo) = _decodeEventData(eventId);
    return ticketInfo.ticketPrices;
  }

  function getTicketNames(uint256 eventId) external view validEventId(eventId) returns (string[] memory) {
    (, TicketStructs.Tickets memory ticketInfo) = _decodeEventData(eventId);
    return ticketInfo.ticketNames;
  }

  function getAddress(uint256 eventId) external view validEventId(eventId) returns (address) {
    return eventTicketAddress[eventId];
  }

  function getEventFunds(uint256 eventId) external view validEventId(eventId) returns (uint256) {
    return eventBalance[eventId];
  }

  // Admin functions
  function lockEvent(uint256 eventId) external onlyEventOwner(eventId) {
    eventLocked[eventId] = true;
    emit EventLocked(eventId);
  }

  function unlockEvent(uint256 eventId) external onlyEventOwner(eventId) {
    eventLocked[eventId] = false;
    emit EventUnlocked(eventId);
  }

  function closeTicketOffice() external onlyOwner {
    ticketOfficeOpen = false;
  }

  function openTicketOffice() external onlyOwner {
    ticketOfficeOpen = true;
  }

  // Internal helper to decode event data
  function _decodeEventData(uint256 eventId) internal view returns (
    TicketStructs.Ticketdetails memory details,
    TicketStructs.Tickets memory ticketInfo
  ) {
    bytes memory encoded = eventDetailsEncoded[eventId];
    require(encoded.length > 0, "Event not found");
    return abi.decode(encoded, (TicketStructs.Ticketdetails, TicketStructs.Tickets));
  }

  // Emergency functions
  function emergencyWithdraw(address token, uint256 amount) external onlyOwner {
    IERC20(token).transfer(_contractOwner, amount);
  }
}