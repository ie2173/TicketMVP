// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title TicketOfficeStorage
 * @dev Shared storage layout for proxy pattern
 */
contract TicketOfficeStorage {
  // Core state variables
  string internal _name;
  address internal _contractOwner;
  address internal _usdcAddress;
  uint256 internal _eventIdCounter;
  bool public ticketOfficeOpen;
  
  // Mappings
  mapping(uint256 => address) public eventTicketAddress;
  mapping(uint256 => mapping(uint256 => uint256)) public ticketPurchasedCounter;
  mapping(address => mapping(uint256 => mapping(uint256 => bool))) public freeTicketVoucher;
  mapping(address => mapping(uint256 => mapping(uint256 => bool))) public ticketComped;
  mapping(uint256 => bytes) internal eventDetailsEncoded; // Store encoded data to save space
  mapping(uint256 => uint256) internal eventBalance;
  mapping(uint256 => address) public withdrawlApproval;
  mapping(uint256 => bool) public eventLocked;

  // Events
  event Initialized(address owner, address usdc);
  event EventCreated(uint256 indexed eventId, address indexed owner, address nftAddress);
  event TicketPurchased(address indexed buyer, uint256 indexed eventId, uint256 indexed ticketId, uint256 quantity);
  event EventLocked(uint256 indexed eventId);
  event EventUnlocked(uint256 indexed eventId);
  event RefundIssued(address indexed recipient, uint256 indexed eventId, uint256 amount);
  event FundsWithdrawn(address indexed recipient, uint256 indexed eventId, uint256 amount);
}