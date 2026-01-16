// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "../interfaces/IERC20.sol";
import { TicketStructs } from "./TicketStructs.sol";

/**
 * @title PaymentLib
 * @dev Library for handling payment operations
 */
library PaymentLib {
  error PaymentFailed(string reason);
  error InsufficientBalance(uint256 required, uint256 available);

  event PaymentProcessed(address indexed from, address indexed to, uint256 amount);
  event RefundProcessed(address indexed to, uint256 amount);

  /**
   * @dev Processes payment for ticket purchase
   */
  function processPayment(
    IERC20 token,
    address from,
    address to,
    uint256 amount,
    mapping(uint256 => uint256) storage eventBalance,
    uint256 eventId
  ) external {
    if (amount == 0) return;
    
    uint256 userBalance = token.balanceOf(from);
    if (userBalance < amount) {
      revert InsufficientBalance(amount, userBalance);
    }
    
    bool success = token.transferFrom(from, to, amount);
    if (!success) {
      revert PaymentFailed("Token transfer failed");
    }
    
    eventBalance[eventId] += amount;
    emit PaymentProcessed(from, to, amount);
  }

  /**
   * @dev Processes refund to user
   */
  function processRefund(
    IERC20 token,
    address from,
    address to,
    uint256 amount,
    mapping(uint256 => uint256) storage eventBalance,
    uint256 eventId
  ) external {
    if (amount == 0) return;
    
    uint256 contractBalance = token.balanceOf(from);
    if (contractBalance < amount) {
      revert InsufficientBalance(amount, contractBalance);
    }
    
    if (eventBalance[eventId] < amount) {
      revert InsufficientBalance(amount, eventBalance[eventId]);
    }
    
    bool success = token.transfer(to, amount);
    if (!success) {
      revert PaymentFailed("Refund transfer failed");
    }
    
    eventBalance[eventId] -= amount;
    emit RefundProcessed(to, amount);
  }

  /**
   * @dev Withdraws event funds to owner
   */
  function withdrawEventFunds(
    IERC20 token,
    address to,
    uint256 amount,
    mapping(uint256 => uint256) storage eventBalance,
    uint256 eventId
  ) external {
    if (amount == 0) return;
    
    if (eventBalance[eventId] < amount) {
      revert InsufficientBalance(amount, eventBalance[eventId]);
    }
    
    bool success = token.transfer(to, amount);
    if (!success) {
      revert PaymentFailed("Withdrawal failed");
    }
    
    eventBalance[eventId] -= amount;
    emit PaymentProcessed(address(this), to, amount);
  }
}