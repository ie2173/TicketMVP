// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "./interfaces/IERC20.sol";
import { TicketStructs } from "./libraries/TicketStructs.sol";
import { ERC1155Token } from "./tokens/ERC1155Token.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract EventContract is ReentrancyGuard {
  IERC20 immutable private _usdc;
  address immutable private _factory;
  address immutable private _contractOwner;
  
  address public ticketNftAddress;
  address public eventOwner;
  address public treasurerAddress;
  uint256 public eventDate;
  bool public eventLocked;
  uint256 private eventBalance;
  
  TicketStructs.Ticketdetails public eventDetails;
  mapping(address => mapping(uint256 => bool)) public freeTicketVoucher;
  mapping(address => mapping(uint256 => bool)) public ticketComped;

  event TicketPurchased(address indexed buyer, uint256 indexed ticketId, uint256 quantity);
  event TicketComped(address indexed recipient, uint256 indexed ticketId);
  event FundsWithdrawn(address indexed recipient, uint256 amount);

  modifier onlyFactory() {
    require(msg.sender == _factory, "Only factory");
    _;
  }

  modifier onlyOwnerOrTreasurer() {
    require(msg.sender == eventOwner || msg.sender == treasurerAddress, "Unauthorized");
    _;
  }

  constructor(
    address usdcAddress,
    address contractOwner,
    address factory
  ) {
    _usdc = IERC20(usdcAddress);
    _contractOwner = contractOwner;
    _factory = factory;
  }

  function initialize(
    TicketStructs.Ticketdetails calldata details,
    TicketStructs.TicketInformation calldata ticketInformation,
    string memory baseURL
  ) external onlyFactory {
    require(ticketNftAddress == address(0), "Already initialized");
    
    eventOwner = details.owner;
    eventDate = details.eventDate;
    treasurerAddress = details.owner;
    
    // Create ticket NFT contract
    ERC1155Token ticketNft = new ERC1155Token(baseURL, details.name);
    ticketNftAddress = address(ticketNft);
    
    // Store event details
    eventDetails = TicketStructs.Ticketdetails(
      details.name,
      details.owner,
      details.eventDate,
      TicketStructs.Tickets(
        ticketInformation.ticketNames,
        ticketInformation.ticketCapacities,
        ticketInformation.ticketPrices,
        new uint256[](ticketInformation.ticketNames.length)
      ),
      details.locationDetails,
      details.performers,
      details.keywords,
      details.categories,
      details.eventDescription,
      details.eventType
    );
  }

  function mintSingleTicket(
    uint256 ticketId,
    uint256 quantity,
    address to
  ) external nonReentrant {
    require(!eventLocked, "Event locked");
    require(
      eventDetails.ticketInformation.ticketCapacities[ticketId] >= 
      quantity + eventDetails.ticketInformation.ticketsSold[ticketId], 
      "Sold out"
    );

    uint256 cost = eventDetails.ticketInformation.ticketPrices[ticketId] * quantity;
    
    bool success = _usdc.transferFrom(msg.sender, address(this), cost);
    require(success, "Transfer failed");
    
    eventBalance += cost;
    eventDetails.ticketInformation.ticketsSold[ticketId] += quantity;
    
    ERC1155Token(ticketNftAddress).mint(to, ticketId, quantity);
    emit TicketPurchased(to, ticketId, quantity);
  }

  function mintMultipleTickets(
    uint256[] memory ticketIds,
    uint256[] memory amounts,
    address to
  ) external nonReentrant {
    require(!eventLocked, "Event locked");
    require(ticketIds.length == amounts.length, "Array mismatch");
    
    uint256 totalCost = 0;
    for (uint256 i = 0; i < ticketIds.length;) {
      require(
        eventDetails.ticketInformation.ticketCapacities[ticketIds[i]] >= 
        amounts[i] + eventDetails.ticketInformation.ticketsSold[ticketIds[i]], 
        "Sold out"
      );
      totalCost += eventDetails.ticketInformation.ticketPrices[ticketIds[i]] * amounts[i];
      unchecked { ++i; }
    }

    bool success = _usdc.transferFrom(msg.sender, address(this), totalCost);
    require(success, "Transfer failed");
    
    eventBalance += totalCost;
    ERC1155Token(ticketNftAddress).mintBatchTickets(to, ticketIds, amounts);
    
    for (uint256 i = 0; i < ticketIds.length;) {
      if (amounts[i] != 0) {
        eventDetails.ticketInformation.ticketsSold[ticketIds[i]] += amounts[i];
        emit TicketPurchased(to, ticketIds[i], amounts[i]);
      }
      unchecked { ++i; }
    }
  }

  function compTicket(address user, uint256 ticketId) external onlyOwnerOrTreasurer {
    require(!eventLocked, "Event locked");
    freeTicketVoucher[user][ticketId] = true;
    emit TicketComped(user, ticketId);
  }

  function redeemTicket(uint256 ticketId) external {
    require(freeTicketVoucher[msg.sender][ticketId], "No voucher");
    require(!eventLocked, "Event locked");
    
    freeTicketVoucher[msg.sender][ticketId] = false;
    eventDetails.ticketInformation.ticketsSold[ticketId] += 1;
    
    ERC1155Token(ticketNftAddress).mint(msg.sender, ticketId, 1);
    ticketComped[msg.sender][ticketId] = true;
  }

  function withdrawFunds() external onlyOwnerOrTreasurer nonReentrant {
    require(block.timestamp >= eventDate + 86_400, "Too early");
    require(!eventLocked, "Locked for refunds");
    require(eventBalance > 0, "No funds");

    uint256 fee = eventBalance * 5 / 100;
    uint256 payout = eventBalance - fee;
    
    eventBalance = 0;
    eventLocked = true;
    
    bool success1 = _usdc.transfer(_contractOwner, fee);
    require(success1, "Fee transfer failed");
    
    bool success2 = _usdc.transfer(eventOwner, payout);
    require(success2, "Payout failed");
    
    emit FundsWithdrawn(eventOwner, payout);
  }

  function lockEventForRefunds() external onlyOwnerOrTreasurer {
    eventLocked = true;
  }

  function issueRefund() external nonReentrant {
    require(eventLocked, "Event not locked");
    
    uint256 refundAmount = 0;
    for (uint256 i = 0; i < eventDetails.ticketInformation.ticketNames.length;) {
      require(!ticketComped[msg.sender][i], "No refund for comps");
      
      uint256 userBalance = ERC1155Token(ticketNftAddress).balanceOf(msg.sender, i);
      if (userBalance > 0) {
        ERC1155Token(ticketNftAddress).burn(msg.sender, i, userBalance);
        uint256 ticketRefund = eventDetails.ticketInformation.ticketPrices[i] * userBalance;
        refundAmount += ticketRefund;
        eventDetails.ticketInformation.ticketsSold[i] -= userBalance;
      }
      unchecked { ++i; }
    }
    
    require(refundAmount > 0, "No tickets to refund");
    eventBalance -= refundAmount;
    
    bool success = _usdc.transfer(msg.sender, refundAmount);
    require(success, "Refund failed");
  }

  // View functions
  function getTicketPrice(uint256 ticketId) external view returns (uint256) {
    return eventDetails.ticketInformation.ticketPrices[ticketId];
  }

  function getTicketsSold(uint256 ticketId) external view returns (uint256) {
    return eventDetails.ticketInformation.ticketsSold[ticketId];
  }

  function getEventBalance() external view returns (uint256) {
    return eventBalance;
  }

  // Additional view helpers for adapter compatibility
  function getTicketNames() external view returns (string[] memory) {
    return eventDetails.ticketInformation.ticketNames;
  }

  function getTicketPrices() external view returns (uint256[] memory) {
    return eventDetails.ticketInformation.ticketPrices;
  }

  function getTicketCapacities() external view returns (uint256[] memory) {
    return eventDetails.ticketInformation.ticketCapacities;
  }

  function getTicketsSoldAll() external view returns (uint256[] memory) {
    return eventDetails.ticketInformation.ticketsSold;
  }

  function getLocation() external view returns (TicketStructs.LocationDetails memory) {
    return eventDetails.locationDetails;
  }

  function getPerformers() external view returns (string[] memory) {
    return eventDetails.performers;
  }
}