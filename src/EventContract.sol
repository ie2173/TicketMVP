// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "src/interfaces/IERC20.sol";
import { ERC1155Token } from "src/ERC1155Token.sol";
import { TicketStructs } from "src/libraries/TicketStructs.sol";

interface ITicketOfficeFactory {
  function owner() external view returns (address);
  function ticketOfficeOpen() external view returns (bool);
}

contract EventContract {
  using TicketStructs for TicketStructs.Ticketdetails;
  using TicketStructs for TicketStructs.LocationDetails;

  // Immutables
  address public immutable factory;
  address public immutable eventOwner;
  IERC20 public immutable usdc;
  ERC1155Token public immutable ticketToken;
  
  // Reentrancy guard
  uint256 private _status = 1;

  // Event data
  TicketStructs.Ticketdetails public details;
  uint256 public eventBalance;
  bool public locked;
  
  // Ticket vouchers and comps
  mapping(address => mapping(uint256 => bool)) public freeTicketVoucher;
  mapping(address => mapping(uint256 => bool)) public ticketComped;
  mapping(address => bool) public withdrawlApproval;

  // Events
  event TicketPurchased(address indexed buyer, uint256 indexed ticketId, uint256 quantity);
  event FundsWithdrawn(address indexed recipient, uint256 amount);
  event EventLocked();

  // Modifiers
  modifier onlyFactoryOwner() {
    require(msg.sender == ITicketOfficeFactory(factory).owner(), "!A");
    _;
  }

  modifier onlyEventAdmin() {
    require(
      msg.sender == eventOwner || 
      msg.sender == ITicketOfficeFactory(factory).owner() || 
      withdrawlApproval[msg.sender],
      "!U"
    );
    _;
  }

  modifier officeOpen() {
    require(ITicketOfficeFactory(factory).ticketOfficeOpen(), "!O");
    _;
  }

  modifier nonReentrant() {
    require(_status != 2, "!R");
    _status = 2;
    _;
    _status = 1;
  }

  constructor(
    address _factory,
    address _eventOwner,
    address _usdc,
    string memory eventName,
    string memory tokenUri,
    TicketStructs.Ticketdetails memory _details
  ) {
    factory = _factory;
    eventOwner = _eventOwner;
    usdc = IERC20(_usdc);
    details = _details;
    
    // Deploy ERC1155 token for this event
    ticketToken = new ERC1155Token(tokenUri, eventName);
  }

  // ============ PUBLIC TICKET PURCHASE FUNCTIONS ============

  function buyTickets(
    uint256[] memory _ticketIds,
    uint256[] memory _quantities,
    address _buyer
  ) external officeOpen nonReentrant {
    require(!locked, "!F");
    
    uint256 grossCost = 0;
    for (uint256 i = 0; i < _ticketIds.length; i++) {
      require(
        details.ticketInformation.ticketCapacities[_ticketIds[i]] >=
          details.ticketInformation.ticketsSold[_ticketIds[i]] + _quantities[i],
        "!S"
      );
      grossCost += details.ticketInformation.ticketPrices[_ticketIds[i]] * _quantities[i];
    }

    require(grossCost <= usdc.balanceOf(msg.sender), "!$");
    bool success = usdc.transferFrom(msg.sender, address(this), grossCost);
    require(success);
    
    eventBalance += grossCost;
    ticketToken.mintBatchTickets(_buyer, _ticketIds, _quantities);
    
    for (uint256 i = 0; i < _ticketIds.length; i++) {
      if (_quantities[i] != 0) {
        details.ticketInformation.ticketsSold[_ticketIds[i]] += _quantities[i];
      }
    }
  }

  function buyTicket(
    uint256 _ticketId,
    uint256 _quantity,
    address _buyer
  ) external officeOpen nonReentrant {
    require(!locked, "!F");
    require(
      details.ticketInformation.ticketCapacities[_ticketId] >=
        details.ticketInformation.ticketsSold[_ticketId] + _quantity,
      "!S"
    );
    
    uint256 grossCost = details.ticketInformation.ticketPrices[_ticketId] * _quantity;
    require(grossCost <= usdc.balanceOf(msg.sender), "!$");
    
    bool success = usdc.transferFrom(msg.sender, address(this), grossCost);
    require(success);
    
    eventBalance += grossCost;
    ticketToken.mint(_buyer, _ticketId, _quantity);
    details.ticketInformation.ticketsSold[_ticketId] += _quantity;
  }

  function redeemCompTicket(uint256 _ticketId) external officeOpen {
    require(freeTicketVoucher[msg.sender][_ticketId], "!V");
    require(!locked, "!F");
    
    freeTicketVoucher[msg.sender][_ticketId] = false;
    ticketToken.mint(msg.sender, _ticketId, 1);
    details.ticketInformation.ticketsSold[_ticketId] += 1;
    ticketComped[msg.sender][_ticketId] = true;
  }

  function issueRefund() external officeOpen nonReentrant {
    require(locked, "!RI");
    
    address id = address(ticketToken);
    uint256 refundTotal = 0;

    for (uint256 i = 0; i < details.ticketInformation.ticketNames.length; i++) {
      require(!ticketComped[msg.sender][i], "!RI");
      
      uint256 ticketCount = ticketToken.balanceOf(msg.sender, i);
      if (ticketCount > 0) {
        ticketToken.burn(msg.sender, i, ticketCount);
        require(ticketToken.balanceOf(msg.sender, i) == 0, "!B");
        refundTotal += details.ticketInformation.ticketPrices[i] * ticketCount;
      }
    }

    eventBalance -= refundTotal;
    bool success = usdc.transfer(msg.sender, refundTotal);
    require(success, "!T");
  }

  // ============ ADMIN FUNCTIONS ============

  function addCompTicket(
    uint256 _ticketId,
    uint256 _quantity,
    address[] memory _addresses
  ) external onlyEventAdmin {
    require(!locked, "!F");
    require(
      details.ticketInformation.ticketCapacities[_ticketId] >=
        details.ticketInformation.ticketsSold[_ticketId] + (_quantity * _addresses.length),
      "!S"
    );

    for (uint256 i = 0; i < _addresses.length; i++) {
      freeTicketVoucher[_addresses[i]][_ticketId] = true;
    }
  }

  function addTicket(
    string memory _ticketName,
    uint256 _ticketPrice,
    uint256 _ticketCapacity,
    uint256 _feePercentage
  ) external onlyEventAdmin {
    require(!locked, "!F");
    
    details.ticketInformation.ticketNames.push(_ticketName);
    details.ticketInformation.ticketPrices.push(_ticketPrice);
    details.ticketInformation.ticketCapacities.push(_ticketCapacity);
    details.ticketInformation.ticketsSold.push(0);
    details.ticketInformation.feePercentages.push(_feePercentage);
  }

  function addPerformer(string memory _performer) external onlyEventAdmin {
    require(!locked, "!F");
    details.performers.push(_performer);
  }

  function updateEventDetails(TicketStructs.Ticketdetails memory _details) external onlyEventAdmin {
    require(!locked, "!F");
    require(_details.eventDate > block.timestamp, "!D");
    require(eventOwner == _details.owner, "!O");
    
    details = _details;
  }

  function withdrawFunds() external onlyEventAdmin nonReentrant {
    require(!locked, "!L");
    require(eventBalance > 0, "!$");
    require(
      details.eventDate < block.timestamp || msg.sender == ITicketOfficeFactory(factory).owner(),
      "!W"
    );

    uint256 balance = eventBalance;
    eventBalance = 0;

    uint256 feeTotal = 0;
    for (uint256 i = 0; i < details.ticketInformation.feePercentages.length; i++) {
      feeTotal += (details.ticketInformation.ticketPrices[i] * 
                   details.ticketInformation.ticketsSold[i] * 
                   details.ticketInformation.feePercentages[i]) / 100;
    }

    uint256 eventOwnerAmount = balance - feeTotal;
    
    bool success1 = usdc.transfer(eventOwner, eventOwnerAmount);
    require(success1, "!T");

    bool success2 = usdc.transfer(ITicketOfficeFactory(factory).owner(), feeTotal);
    require(success2, "!T");

    emit FundsWithdrawn(eventOwner, eventOwnerAmount);
  }

  function lockEvent() external onlyFactoryOwner {
    locked = true;
    emit EventLocked();
  }

  function burnTicket(uint256 _ticketId, uint256 _quantity) external onlyFactoryOwner {
    require(ticketToken.balanceOf(msg.sender, _ticketId) >= _quantity, "!T");
    ticketToken.burn(msg.sender, _ticketId, _quantity);
  }

  function grantWithdrawalApproval(address _user) external onlyEventAdmin {
    withdrawlApproval[_user] = true;
  }

  // ============ VIEW FUNCTIONS ============

  function getEventDetails() external view returns (TicketStructs.Ticketdetails memory) {
    return details;
  }

  function getTicketPrice(uint256 _ticketId) external view returns (uint256) {
    return details.ticketInformation.ticketPrices[_ticketId];
  }

  function getTicketPrices() external view returns (uint256[] memory) {
    return details.ticketInformation.ticketPrices;
  }

  function getTicketNames() external view returns (string[] memory) {
    return details.ticketInformation.ticketNames;
  }

  function getTicketCapacities() external view returns (uint256[] memory) {
    return details.ticketInformation.ticketCapacities;
  }

  function getTicketsSold() external view returns (uint256[] memory) {
    return details.ticketInformation.ticketsSold;
  }

  function getEventName() external view returns (string memory) {
    return details.name;
  }

  function getEventDate() external view returns (uint256) {
    return details.eventDate;
  }

  function getEventLocation() external view returns (TicketStructs.LocationDetails memory) {
    return details.locationDetails;
  }

  function getEventPerformers() external view returns (string[] memory) {
    return details.performers;
  }

  function getEventBalance() external view returns (uint256) {
    return eventBalance;
  }

  function isLocked() external view returns (bool) {
    return locked;
  }

  function getTicketTokenAddress() external view returns (address) {
    return address(ticketToken);
  }

  function isEventOwner(address _user) external view returns (bool) {
    return eventOwner == _user;
  }

  function isTicketHolder(address _user, uint256 _ticketId) external view returns (bool) {
    return ticketToken.balanceOf(_user, _ticketId) > 0;
  }
}
