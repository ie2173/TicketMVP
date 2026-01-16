// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "../interfaces/IERC20.sol";
import { TicketStructs } from "./TicketStructs.sol";

/**
 * @title TicketValidationLib
 * @dev Library for ticket validation and business logic
 */
library TicketValidationLib {
  error InvalidTicketPurchase(string reason);
  error InsufficientFunds(uint256 required, uint256 provided);
  error TicketSoldOut(uint256 ticketId);
  error EventNotFound(uint256 eventId);

  /**
   * @dev Validates ticket purchase parameters
   */
  function validateTicketPurchase(
    TicketStructs.Ticketdetails storage eventDetails,
    uint256 ticketId,
    uint256 quantity,
    uint256 totalCost,
    uint256 userBalance
  ) external view {
    if (eventDetails.eventDate == 0) {
      revert EventNotFound(ticketId);
    }
    
    if (eventDetails.eventDate <= block.timestamp) {
      revert InvalidTicketPurchase("Event has already occurred");
    }
    
    if (ticketId >= eventDetails.ticketInformation.ticketNames.length) {
      revert InvalidTicketPurchase("Invalid ticket type");
    }
    
    uint256 available = eventDetails.ticketInformation.ticketCapacities[ticketId] - 
                        eventDetails.ticketInformation.ticketsSold[ticketId];
    
    if (available < quantity) {
      revert TicketSoldOut(ticketId);
    }
    
    if (userBalance < totalCost) {
      revert InsufficientFunds(totalCost, userBalance);
    }
  }

  /**
   * @dev Calculates total cost for ticket purchase
   */
  function calculateTotalCost(
    TicketStructs.Tickets storage ticketInfo,
    uint256[] calldata ticketIds,
    uint256[] calldata quantities
  ) external view returns (uint256 totalCost) {
    require(ticketIds.length == quantities.length, "Array length mismatch");
    
    for (uint256 i = 0; i < ticketIds.length; i++) {
      require(ticketIds[i] < ticketInfo.ticketPrices.length, "Invalid ticket ID");
      totalCost += ticketInfo.ticketPrices[ticketIds[i]] * quantities[i];
    }
  }

  /**
   * @dev Updates ticket sold counters
   */
  function updateTicketsSold(
    TicketStructs.Tickets storage ticketInfo,
    uint256[] calldata ticketIds,
    uint256[] calldata quantities
  ) external {
    for (uint256 i = 0; i < ticketIds.length; i++) {
      ticketInfo.ticketsSold[ticketIds[i]] += quantities[i];
    }
  }

  /**
   * @dev Validates refund eligibility
   */
  function validateRefund(
    TicketStructs.Ticketdetails storage eventDetails,
    address requester,
    bool isEventLocked
  ) external view {
    if (eventDetails.eventDate == 0) {
      revert EventNotFound(0);
    }
    
    if (!isEventLocked) {
      revert InvalidTicketPurchase("Event must be locked for refunds");
    }
    
    if (eventDetails.owner != requester) {
      revert InvalidTicketPurchase("Only event owner can issue refunds");
    }
  }
}