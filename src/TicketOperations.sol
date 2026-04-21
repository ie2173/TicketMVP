// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "src/interfaces/IERC20.sol";
import { EventData } from "src/EventData.sol";
import { ERC1155Token } from "src/ERC1155Token.sol";

interface IFactory {
  function owner() external view returns (address);
  function ticketOfficeOpen() external view returns (bool);
  function getEventData(uint256) external view returns (address);
  function usdc() external view returns (IERC20);
}

/// @title TicketOperations - Public ticket purchase and comp ticket operations
/// @notice Handles buying tickets and redeeming comp tickets
contract TicketOperations {
  address public factory;  // Upgradeable by protocol owner
  
  // Reentrancy guard
  uint256 private _status = 1;
  
  event TicketPurchased(uint256 indexed eventId, address indexed buyer, uint256 ticketType, uint256 quantity);
  event CompTicketRedeemed(uint256 indexed eventId, address indexed user, uint256 ticketType);
  event RefundClaimed(uint256 indexed eventId, address indexed user, uint256 totalAmount);
  event FactoryUpdated(address indexed oldFactory, address indexed newFactory);
  
  modifier nonReentrant() {
    require(_status != 2, "!R");
    _status = 2;
    _;
    _status = 1;
  }
  
  modifier officeOpen() {
    require(IFactory(factory).ticketOfficeOpen(), "!O");
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
  
  // ============ PUBLIC TICKET PURCHASE ============
  
  function buyTicket(uint256 _eventId, uint256 _ticketType) external nonReentrant officeOpen {
    address eventDataAddr = IFactory(factory).getEventData(_eventId);
    EventData eventData = EventData(eventDataAddr);
    
    require(!eventData.locked(), "!L");
    
    // Validate ticket type and availability
    require(_ticketType < eventData.getTicketCount(), "!T");
    uint256 ticketsSold = eventData.getTicketsSold(_ticketType);
    uint256 capacity = eventData.getTicketCapacity(_ticketType);
    require(ticketsSold < capacity, "!Q");
    
    uint256 price = eventData.getTicketPrice(_ticketType);
    
    // Transfer USDC from buyer to EventData contract
    IERC20 usdc = IFactory(factory).usdc();
    require(usdc.transferFrom(msg.sender, address(eventData), price), "!P");
    
    // Update state in EventData
    eventData.incrementTicketsSold(_ticketType, 1);
    eventData.addToBalance(price);
    
    // Mint ticket NFT
    ERC1155Token ticketToken = ERC1155Token(eventData.ticketToken());
    ticketToken.mint(msg.sender, _ticketType, 1);
    
    emit TicketPurchased(_eventId, msg.sender, _ticketType, 1);
  }
  
  function buyTickets(
    uint256 _eventId,
    uint256[] memory _ticketTypes,
    uint256[] memory _quantities
  ) external nonReentrant officeOpen {
    require(_ticketTypes.length == _quantities.length, "!L");
    
    address eventDataAddr = IFactory(factory).getEventData(_eventId);
    EventData eventData = EventData(eventDataAddr);
    
    require(!eventData.locked(), "!L");
    
    uint256 totalCost = 0;
    uint256 ticketCount = eventData.getTicketCount();
    
    // Calculate total and validate
    for (uint256 i = 0; i < _ticketTypes.length; i++) {
      uint256 ticketType = _ticketTypes[i];
      uint256 quantity = _quantities[i];
      
      require(ticketType < ticketCount, "!T");
      
      uint256 ticketsSold = eventData.getTicketsSold(ticketType);
      uint256 capacity = eventData.getTicketCapacity(ticketType);
      require(ticketsSold + quantity <= capacity, "!Q");
      
      totalCost += eventData.getTicketPrice(ticketType) * quantity;
    }
    
    // Transfer total USDC from buyer to EventData contract
    IERC20 usdc = IFactory(factory).usdc();
    require(usdc.transferFrom(msg.sender, address(eventData), totalCost), "!P");
    
    // Update state and mint tickets
    ERC1155Token ticketToken = ERC1155Token(eventData.ticketToken());
    for (uint256 i = 0; i < _ticketTypes.length; i++) {
      eventData.incrementTicketsSold(_ticketTypes[i], _quantities[i]);
      ticketToken.mint(msg.sender, _ticketTypes[i], _quantities[i]);
      
      emit TicketPurchased(_eventId, msg.sender, _ticketTypes[i], _quantities[i]);
    }
    
    eventData.addToBalance(totalCost);
  }
  
  // ============ COMP TICKET REDEMPTION ============
  
  function redeemCompTicket(uint256 _eventId, uint256 _ticketType) external nonReentrant {
    address eventDataAddr = IFactory(factory).getEventData(_eventId);
    EventData eventData = EventData(eventDataAddr);
    
    require(!eventData.locked(), "!L");
    require(eventData.freeTicketVoucher(msg.sender, _ticketType), "!V");
    require(!eventData.ticketComped(msg.sender, _ticketType), "!D");
    
    // Check capacity
    uint256 ticketsSold = eventData.getTicketsSold(_ticketType);
    uint256 capacity = eventData.getTicketCapacity(_ticketType);
    require(ticketsSold < capacity, "!Q");
    
    // Update state
    eventData.setTicketComped(msg.sender, _ticketType, true);
    eventData.incrementTicketsSold(_ticketType, 1);
    
    // Mint ticket NFT
    ERC1155Token ticketToken = ERC1155Token(eventData.ticketToken());
    ticketToken.mint(msg.sender, _ticketType, 1);
    
    emit CompTicketRedeemed(_eventId, msg.sender, _ticketType);
  }
  
  // ============ SELF-SERVICE REFUND ============
  
  /// @notice Allows ticket holders to claim refunds for all their tickets when event is locked/cancelled
  /// @param _eventId The event ID to claim refund from
  /// @dev Event must be locked. Comped tickets are not refundable. Burns all tickets and transfers USDC.
  function claimRefund(uint256 _eventId) external nonReentrant {
    address eventDataAddr = IFactory(factory).getEventData(_eventId);
    EventData eventData = EventData(eventDataAddr);
    
    require(eventData.locked(), "!L"); // Event must be locked/cancelled for refunds
    
    ERC1155Token ticketToken = ERC1155Token(eventData.ticketToken());
    uint256 ticketCount = eventData.getTicketCount();
    uint256 totalRefund = 0;
    
    // Loop through all ticket types
    for (uint256 i = 0; i < ticketCount; i++) {
      // Skip comped tickets - they don't get refunds
      if (eventData.ticketComped(msg.sender, i)) {
        continue;
      }
      
      uint256 balance = ticketToken.balanceOf(msg.sender, i);
      if (balance > 0) {
        uint256 price = eventData.getTicketPrice(i);
        uint256 refundAmount = price * balance;
        
        // Burn tickets
        ticketToken.burn(msg.sender, i, balance);
        
        // Update state
        eventData.decrementTicketsSold(i, balance);
        
        totalRefund += refundAmount;
      }
    }
    
    require(totalRefund > 0, "!T"); // Must have tickets to refund
    require(eventData.eventBalance() >= totalRefund, "!B"); // Sufficient balance
    
    // Update balance and transfer USDC
    eventData.subtractFromBalance(totalRefund);
    eventData.transferUSDC(msg.sender, totalRefund);
    
    emit RefundClaimed(_eventId, msg.sender, totalRefund);
  }
}
