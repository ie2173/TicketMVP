// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Initializable } from "@openzeppelin-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { OwnableUpgradeable } from "@openzeppelin-upgradeable/access/OwnableUpgradeable.sol";

import { IERC20 } from "./interfaces/IERC20.sol";
import { ITicketOffice } from "./interfaces/ITicketOffice.sol";
import { TicketStructs } from "./libraries/TicketStructs.sol";
import { ERC1155Token } from "./TicketOffice.sol";

/**
 * @title TicketOfficeUpgradeable
 * @dev Upgradeable ticket office implementation with UUPS proxy pattern
 */
contract TicketOfficeUpgradeable is 
  Initializable,
  UUPSUpgradeable,
  OwnableUpgradeable,
  ITicketOffice 
{
  using TicketStructs for TicketStructs.Ticketdetails;

  // Storage - use gaps to allow for future upgrades
  string internal _name;
  address internal _usdcAddress;
  uint256 internal _eventIdCounter;
  bool public ticketOfficeOpen;
  
  mapping(uint256 => address) public eventTicketAddress;
  mapping(uint256 => mapping(uint256 => uint256)) public ticketPurchasedCounter;
  mapping(address => mapping(uint256 => mapping(uint256 => bool))) public freeTicketVoucher;
  mapping(address => mapping(uint256 => mapping(uint256 => bool))) public ticketComped;
  mapping(uint256 => bytes) internal eventDetailsEncoded;
  mapping(uint256 => uint256) internal eventBalance;
  mapping(uint256 => address) public withdrawlApproval;
  mapping(uint256 => bool) public eventLocked;

  // Events
  event EventCreated(uint256 indexed eventId, address indexed owner, address nftAddress);
  event TicketPurchased(address indexed buyer, uint256 indexed eventId, uint256 indexed ticketId, uint256 quantity);

  // Constants
  uint256 private constant MAX_TICKETS_PER_PURCHASE = 10;

  // Storage gap for future upgrades
  uint256[50] private __gap;

  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() {
    _disableInitializers();
  }

  /**
   * @dev Initialize the contract (replaces constructor)
   */
  function initialize(
    string memory name_,
    address usdcAddress,
    address owner
  ) external initializer {
    require(usdcAddress != address(0), "Invalid USDC address");
    
    __Ownable_init(owner);
    
    _name = name_;
    _usdcAddress = usdcAddress;
    ticketOfficeOpen = true;
  }

  /**
   * @dev Create a new event - core functionality
   */
  function createEvent(
    TicketStructs.Ticketdetails calldata details,
    TicketStructs.Tickets calldata ticketInformation,
    string memory baseUri
  ) external override {
    require(ticketOfficeOpen, "Ticket Office is Closed");
    require(details.owner == msg.sender, "Invalid event owner");
    require(details.eventDate > block.timestamp, "Event date in past");
    require(ticketInformation.ticketNames.length > 0, "No tickets defined");

    uint256 eventId = _eventIdCounter++;
    
    // Create NFT contract
    ERC1155Token ticketNft = new ERC1155Token(baseUri, details.name);
    eventTicketAddress[eventId] = address(ticketNft);
    
    // Store event details
    eventDetailsEncoded[eventId] = abi.encode(details, ticketInformation);
    
    emit EventCreated(eventId, details.owner, address(ticketNft));
  }

  /**
   * @dev Purchase a single ticket type
   */
  function mintSingleTicket(
    uint256 eventId,
    uint256 ticketId,
    uint256 quantity
  ) external {
    require(ticketOfficeOpen, "Ticket Office is Closed");
    require(eventId < _eventIdCounter, "Invalid event ID");
    require(quantity > 0 && quantity <= MAX_TICKETS_PER_PURCHASE, "Invalid quantity");
    
    _processPurchase(eventId, _singleArray(ticketId), _singleArray(quantity));
  }

  /**
   * @dev Purchase multiple ticket types
   */
  function mintMultipleTickets(
    uint256 eventId,
    uint256[] calldata ticketIds,
    uint256[] calldata quantities
  ) external {
    require(ticketOfficeOpen, "Ticket Office is Closed");
    require(eventId < _eventIdCounter, "Invalid event ID");
    require(ticketIds.length == quantities.length, "Array length mismatch");
    require(ticketIds.length <= MAX_TICKETS_PER_PURCHASE, "Too many ticket types");
    
    _processPurchase(eventId, ticketIds, quantities);
  }

  // View functions
  function getEventName(uint256 eventId) external view override returns (string memory) {
    (TicketStructs.Ticketdetails memory details,) = _decodeEventData(eventId);
    return details.name;
  }

  function getEventOwner(uint256 eventId) public view override returns (address) {
    (TicketStructs.Ticketdetails memory details,) = _decodeEventData(eventId);
    return details.owner;
  }

  function getTicketNames(uint256 eventId) external view override returns (string[] memory) {
    (, TicketStructs.Tickets memory ticketInfo) = _decodeEventData(eventId);
    return ticketInfo.ticketNames;
  }

  function getTicketPrices(uint256 eventId) external view override returns (uint256[] memory) {
    (, TicketStructs.Tickets memory ticketInfo) = _decodeEventData(eventId);
    return ticketInfo.ticketPrices;
  }

  function getAddress(uint256 eventId) external view override returns (address) {
    return eventTicketAddress[eventId];
  }

  function isEventOwner(uint256 eventId, address userAddress) external view override returns (bool) {
    return getEventOwner(eventId) == userAddress;
  }

  function getEventFunds(uint256 eventId) external view returns (uint256) {
    return eventBalance[eventId];
  }

  // Admin functions
  function lockEvent(uint256 eventId) external {
    require(getEventOwner(eventId) == msg.sender, "Only event owner");
    eventLocked[eventId] = true;
  }

  function closeTicketOffice() external onlyOwner {
    ticketOfficeOpen = false;
  }

  function openTicketOffice() external onlyOwner {
    ticketOfficeOpen = true;
  }

  // Internal functions
  function _processPurchase(
    uint256 eventId,
    uint256[] memory ticketIds,
    uint256[] memory quantities
  ) internal {
    (TicketStructs.Ticketdetails memory details, TicketStructs.Tickets memory ticketInfo) = 
      _decodeEventData(eventId);
    
    // Calculate total cost
    uint256 totalCost = 0;
    for (uint256 i = 0; i < ticketIds.length; i++) {
      require(ticketIds[i] < ticketInfo.ticketPrices.length, "Invalid ticket ID");
      totalCost += ticketInfo.ticketPrices[ticketIds[i]] * quantities[i];
      
      // Check availability
      uint256 available = ticketInfo.ticketCapacities[ticketIds[i]] - ticketInfo.ticketsSold[ticketIds[i]];
      require(available >= quantities[i], "Insufficient tickets");
      
      // Update sold count
      ticketInfo.ticketsSold[ticketIds[i]] += quantities[i];
    }
    
    // Process payment
    if (totalCost > 0) {
      IERC20 usdc = IERC20(_usdcAddress);
      require(usdc.transferFrom(msg.sender, address(this), totalCost), "Payment failed");
      eventBalance[eventId] += totalCost;
    }
    
    // Update storage
    eventDetailsEncoded[eventId] = abi.encode(details, ticketInfo);
    
    // Mint NFTs
    if (ticketIds.length == 1) {
      ERC1155Token(eventTicketAddress[eventId]).mint(msg.sender, ticketIds[0], quantities[0]);
    } else {
      ERC1155Token(eventTicketAddress[eventId]).mintBatchTickets(msg.sender, ticketIds, quantities);
    }
    
    // Emit events
    for (uint256 i = 0; i < ticketIds.length; i++) {
      emit TicketPurchased(msg.sender, eventId, ticketIds[i], quantities[i]);
    }
  }

  function _decodeEventData(uint256 eventId) internal view returns (
    TicketStructs.Ticketdetails memory details,
    TicketStructs.Tickets memory ticketInfo
  ) {
    bytes memory encoded = eventDetailsEncoded[eventId];
    require(encoded.length > 0, "Event not found");
    return abi.decode(encoded, (TicketStructs.Ticketdetails, TicketStructs.Tickets));
  }

  function _singleArray(uint256 value) internal pure returns (uint256[] memory) {
    uint256[] memory array = new uint256[](1);
    array[0] = value;
    return array;
  }

  function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

  // Placeholder functions for compatibility - implement in future versions
  function getTicketPrice(uint256, uint256) external pure override returns (uint256) { return 0; }
  function getEventCapacity(uint256, uint256) external pure override returns (uint256) { return 0; }
  function getEventCapacities(uint256) external pure override returns (uint256[] memory) { 
    return new uint256[](0); 
  }
  function getTicketsSold(uint256) external pure override returns (uint256[] memory) { 
    return new uint256[](0); 
  }
  function getEventDate(uint256) external pure override returns (uint256) { return 0; }
  function getLocationDetails(uint256) external pure override returns (TicketStructs.LocationDetails memory) {
    return TicketStructs.LocationDetails("", "");
  }
  function getEventPerformers(uint256) external pure override returns (string[] memory) { 
    return new string[](0); 
  }
  function getEventKeywords(uint256) external pure override returns (string[] memory) { 
    return new string[](0); 
  }
  function getEventCategories(uint256) external pure override returns (string[] memory) { 
    return new string[](0); 
  }
}