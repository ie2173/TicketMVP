// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { TicketStructs } from "src/libraries/TicketStructs.sol";
import { IERC20 } from "src/interfaces/IERC20.sol";

/// @title EventData - Pure storage contract for event information
/// @notice This contract ONLY stores data, contains NO logic
/// @dev Only the factory can create these contracts
contract EventData {
  using TicketStructs for TicketStructs.Ticketdetails;

  // Immutable references
  address public factory;  // Upgradeable by owner
  address public immutable ticketToken;
  address public immutable eventOwner;
  uint256 public immutable eventId;
  IERC20 public immutable usdc;
  
  // Event details
  TicketStructs.Ticketdetails public details;
  uint256 public eventBalance;
  bool public locked;
  
  // Ticket vouchers and comps
  mapping(address => mapping(uint256 => bool)) public freeTicketVoucher;
  mapping(address => mapping(uint256 => bool)) public ticketComped;
  mapping(address => bool) public withdrawlApproval;
  
  // Events for detailed info
  event EventDetailsSet(
    uint256 indexed eventId,
    string eventName,
    string tokenURI,
    string venueLocation,
    uint256 eventDate,
    uint256 ticketTypeCount
  );
  event FactoryUpdated(address indexed oldFactory, address indexed newFactory);
  
  // Modifier to restrict access to operation contracts only
  modifier onlyOperations() {
    require(
      msg.sender == factory || 
      IFactory(factory).isOperationContract(msg.sender),
      "!OP"
    );
    _;
  }
  
  modifier onlyOwner() {
    require(msg.sender == eventOwner, "!A");
    _;
  }
  
  constructor(
    address _factory,
    address _ticketToken,
    address _eventOwner,
    uint256 _eventId,
    address _usdc,
    TicketStructs.Ticketdetails memory _details
  ) {
    factory = _factory;
    ticketToken = _ticketToken;
    eventOwner = _eventOwner;
    eventId = _eventId;
    usdc = IERC20(_usdc);
    details = _details;
    
    // Emit detailed event info including tokenURI from the token contract
    emit EventDetailsSet(
      _eventId,
      _details.name,
      IERC1155Token(_ticketToken).uri(),
      _details.locationDetails.venue,
      _details.eventDate,
      _details.ticketInformation.ticketPrices.length
    );
  }
  
  // ============ STATE MODIFICATION FUNCTIONS ============
  // Only callable by authorized operation contracts
  
  function incrementTicketsSold(uint256 ticketType, uint256 quantity) external onlyOperations {
    details.ticketInformation.ticketsSold[ticketType] += quantity;
  }
  
  function decrementTicketsSold(uint256 ticketType, uint256 quantity) external onlyOperations {
    details.ticketInformation.ticketsSold[ticketType] -= quantity;
  }
  
  // ============ FACTORY UPGRADE ============
  
  function setFactory(address _newFactory) external onlyOwner {
    require(_newFactory != address(0), "!0");
    emit FactoryUpdated(factory, _newFactory);
    factory = _newFactory;
  }
  
  // ============ STATE MODIFICATION FUNCTIONS ============
  // Only callable by authorized operation contracts
  
  function addToBalance(uint256 amount) external onlyOperations {
    eventBalance += amount;
  }
  
  function subtractFromBalance(uint256 amount) external onlyOperations {
    eventBalance -= amount;
  }
  
  function transferUSDC(address to, uint256 amount) external onlyOperations {
    require(usdc.transfer(to, amount), "!T");
  }
  
  function setFreeTicketVoucher(address user, uint256 ticketType, bool status) external onlyOperations {
    freeTicketVoucher[user][ticketType] = status;
  }
  
  function setTicketComped(address user, uint256 ticketType, bool status) external onlyOperations {
    ticketComped[user][ticketType] = status;
  }
  
  function setWithdrawlApproval(address user, bool status) external onlyOperations {
    withdrawlApproval[user] = status;
  }
  
  function lockEvent() external onlyOperations {
    locked = true;
  }
  
  function updateEventDetails(
    string memory _eventName,
    string memory _venue,
    uint256 _eventDate
  ) external onlyOperations {
    details.name = _eventName;
    details.locationDetails.venue = _venue;
    details.eventDate = _eventDate;
  }
  
  function addTicket(
    string memory ticketName,
    uint256 ticketPrice,
    uint256 ticketCapacity,
    uint256 feePercentage
  ) external onlyOperations {
    details.ticketInformation.ticketNames.push(ticketName);
    details.ticketInformation.ticketPrices.push(ticketPrice);
    details.ticketInformation.ticketCapacities.push(ticketCapacity);
    details.ticketInformation.ticketsSold.push(0);
    details.ticketInformation.feePercentages.push(feePercentage);
  }
  
  function addPerformer(string memory performer) external onlyOperations {
    details.performers.push(performer);
  }
  
  // ============ VIEW/GETTER FUNCTIONS ============
  
  function getEventDate() external view returns (uint256) {
    return details.eventDate;
  }
  
  function getTicketPrice(uint256 ticketType) external view returns (uint256) {
    return details.ticketInformation.ticketPrices[ticketType];
  }
  
  function getTicketCapacity(uint256 ticketType) external view returns (uint256) {
    return details.ticketInformation.ticketCapacities[ticketType];
  }
  
  function getTicketsSold(uint256 ticketType) external view returns (uint256) {
    return details.ticketInformation.ticketsSold[ticketType];
  }
  
  function getTicketFeePercentage(uint256 ticketType) external view returns (uint256) {
    return details.ticketInformation.feePercentages[ticketType];
  }
  
  function getTicketCount() external view returns (uint256) {
    return details.ticketInformation.ticketPrices.length;
  }
  
  function getTotalTicketsSold() external view returns (uint256) {
    uint256 total = 0;
    for (uint256 i = 0; i < details.ticketInformation.ticketsSold.length; i++) {
      total += details.ticketInformation.ticketsSold[i];
    }
    return total;
  }
  
  // ============ ARRAY/NESTED DATA GETTERS ============
  
  function getEventName() external view returns (string memory) {
    return details.name;
  }
  
  function getTicketNames() external view returns (string[] memory) {
    return details.ticketInformation.ticketNames;
  }
  
  function getTicketName(uint256 ticketType) external view returns (string memory) {
    return details.ticketInformation.ticketNames[ticketType];
  }
  
  function getVenue() external view returns (string memory) {
    return details.locationDetails.venue;
  }
  
  function getPerformers() external view returns (string[] memory) {
    return details.performers;
  }
  
  function getKeywords() external view returns (string[] memory) {
    return details.keywords;
  }
  
  function getCategories() external view returns (string[] memory) {
    return details.categories;
  }
  
  function getEventDescription() external view returns (string memory) {
    return details.eventDescription;
  }
  
  function getEventType() external view returns (string memory) {
    return details.eventType;
  }
}

interface IFactory {
  function isOperationContract(address) external view returns (bool);
}

interface IERC1155Token {
  function uri() external view returns (string memory);
}
