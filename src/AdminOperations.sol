// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "src/interfaces/IERC20.sol";
import { EventData } from "src/EventData.sol";
import { ERC1155Token } from "src/ERC1155Token.sol";

interface IFactory {
  function owner() external view returns (address);
  function getEventData(uint256) external view returns (address);
  function usdc() external view returns (IERC20);
}

/// @title AdminOperations - Admin functions for event management
/// @notice Handles refunds, withdrawals, comp tickets, and event modifications
contract AdminOperations {
  address public factory;  // Upgradeable by protocol owner
  
  event RefundIssued(uint256 indexed eventId, address indexed user, uint256 ticketType, uint256 quantity, uint256 amount);
  event FundsWithdrawn(uint256 indexed eventId, address indexed recipient, uint256 amount);
  event CompTicketAdded(uint256 indexed eventId, address indexed user, uint256 ticketType);
  event EventLocked(uint256 indexed eventId);
  event TicketAdded(uint256 indexed eventId, string ticketName, uint256 price);
  event PerformerAdded(uint256 indexed eventId, string performer);
  event EventDetailsUpdated(uint256 indexed eventId);
  event FactoryUpdated(address indexed oldFactory, address indexed newFactory);
  
  modifier onlyFactoryOwner() {
    require(msg.sender == IFactory(factory).owner(), "!A");
    _;
  }
  
  modifier onlyEventAdmin(uint256 _eventId) {
    address eventDataAddr = IFactory(factory).getEventData(_eventId);
    EventData eventData = EventData(eventDataAddr);
    require(
      msg.sender == eventData.eventOwner() || 
      msg.sender == IFactory(factory).owner() ||
      eventData.withdrawlApproval(msg.sender),
      "!U"
    );
    _;
  }
  
  constructor(address _factory) {
    factory = _factory;
  }
  
  // ============ FACTORY UPGRADE ============
  
  function setFactory(address _newFactory) external {
    require(msg.sender == IFactory(factory).owner(), "!A");
    require(_newFactory != address(0), "!0");
    emit FactoryUpdated(factory, _newFactory);
    factory = _newFactory;
  }
  
  // ============ REFUND FUNCTIONS ============
  
  function issueRefund(
    uint256 _eventId,
    address _user,
    uint256 _ticketType,
    uint256 _quantity
  ) external onlyEventAdmin(_eventId) {
    address eventDataAddr = IFactory(factory).getEventData(_eventId);
    EventData eventData = EventData(eventDataAddr);
    
    require(eventData.locked(), "!L"); // Must be locked to issue refunds
    
    uint256 price = eventData.getTicketPrice(_ticketType);
    uint256 refundAmount = price * _quantity;
    
    require(eventData.eventBalance() >= refundAmount, "!B");
    
    // Burn tickets
    ERC1155Token ticketToken = ERC1155Token(eventData.ticketToken());
    ticketToken.burn(_user, _ticketType, _quantity);
    
    // Update state
    eventData.decrementTicketsSold(_ticketType, _quantity);
    eventData.subtractFromBalance(refundAmount);
    
    // Transfer USDC refund from EventData to user
    eventData.transferUSDC(_user, refundAmount);
    
    emit RefundIssued(_eventId, _user, _ticketType, _quantity, refundAmount);
  }
  
  // ============ FUND WITHDRAWAL ============
  
  function withdrawFunds(uint256 _eventId) external onlyEventAdmin(_eventId) {
    address eventDataAddr = IFactory(factory).getEventData(_eventId);
    EventData eventData = EventData(eventDataAddr);
    
    // Check event date
    uint256 eventDate = eventData.getEventDate();
    require(block.timestamp >= eventDate, "!D"); // Can't withdraw before event
    
    uint256 balance = eventData.eventBalance();
    require(balance > 0, "!B");
    
    // Calculate fees
    uint256 totalRevenue = 0;
    uint256 totalFees = 0;
    uint256 ticketCount = eventData.getTicketCount();
    
    for (uint256 i = 0; i < ticketCount; i++) {
      uint256 ticketsSold = eventData.getTicketsSold(i);
      uint256 price = eventData.getTicketPrice(i);
      uint256 feePercentage = eventData.getTicketFeePercentage(i);
      
      uint256 revenue = ticketsSold * price;
      uint256 fee = (revenue * feePercentage) / 100;
      
      totalRevenue += revenue;
      totalFees += fee;
    }
    
    uint256 eventOwnerAmount = totalRevenue - totalFees;
    
    // Update state
    eventData.subtractFromBalance(balance);
    
    // Transfer fees to factory owner from EventData
    if (totalFees > 0) {
      eventData.transferUSDC(IFactory(factory).owner(), totalFees);
    }
    
    // Transfer remaining to event owner from EventData
    if (eventOwnerAmount > 0) {
      eventData.transferUSDC(eventData.eventOwner(), eventOwnerAmount);
    }
    
    emit FundsWithdrawn(_eventId, eventData.eventOwner(), eventOwnerAmount);
  }
  
  // ============ COMP TICKET MANAGEMENT ============
  
  function addCompTicket(
    uint256 _eventId,
    address _user,
    uint256 _ticketType
  ) external onlyEventAdmin(_eventId) {
    address eventDataAddr = IFactory(factory).getEventData(_eventId);
    EventData eventData = EventData(eventDataAddr);
    
    require(!eventData.locked(), "!L");
    eventData.setFreeTicketVoucher(_user, _ticketType, true);
    
    emit CompTicketAdded(_eventId, _user, _ticketType);
  }
  
  // ============ EVENT MODIFICATION ============
  
  function lockEvent(uint256 _eventId) external onlyEventAdmin(_eventId) {
    address eventDataAddr = IFactory(factory).getEventData(_eventId);
    EventData eventData = EventData(eventDataAddr);
    
    eventData.lockEvent();
    emit EventLocked(_eventId);
  }
  
  function addTicket(
    uint256 _eventId,
    string memory _ticketName,
    uint256 _ticketPrice,
    uint256 _ticketCapacity,
    uint256 _feePercentage
  ) external onlyEventAdmin(_eventId) {
    address eventDataAddr = IFactory(factory).getEventData(_eventId);
    EventData eventData = EventData(eventDataAddr);
    
    require(!eventData.locked(), "!L");
    eventData.addTicket(_ticketName, _ticketPrice, _ticketCapacity, _feePercentage);
    
    emit TicketAdded(_eventId, _ticketName, _ticketPrice);
  }
  
  function addPerformer(uint256 _eventId, string memory _performer) external onlyEventAdmin(_eventId) {
    address eventDataAddr = IFactory(factory).getEventData(_eventId);
    EventData eventData = EventData(eventDataAddr);
    
    require(!eventData.locked(), "!L");
    eventData.addPerformer(_performer);
    
    emit PerformerAdded(_eventId, _performer);
  }
  
  function updateEventDetails(
    uint256 _eventId,
    string memory _eventName,
    string memory _venue,
    uint256 _eventDate
  ) external onlyEventAdmin(_eventId) {
    address eventDataAddr = IFactory(factory).getEventData(_eventId);
    EventData eventData = EventData(eventDataAddr);
    
    require(!eventData.locked(), "!L");
    eventData.updateEventDetails(_eventName, _venue, _eventDate);
    
    emit EventDetailsUpdated(_eventId);
  }
  
  function setWithdrawlApproval(
    uint256 _eventId,
    address _user,
    bool _approved
  ) external onlyEventAdmin(_eventId) {
    address eventDataAddr = IFactory(factory).getEventData(_eventId);
    EventData eventData = EventData(eventDataAddr);
    
    eventData.setWithdrawlApproval(_user, _approved);
  }
}
