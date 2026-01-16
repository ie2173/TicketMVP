// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "../interfaces/IERC20.sol";
import { TicketStructs } from "./TicketStructs.sol";

library TicketOfficeLib {

  function processWithdrawal(
    IERC20 token,
    uint256 eventId,
    uint256 eventDate,
    address eventOwner,
    address contractOwner,
    uint256 balance
  ) internal returns (bool) {
    require(
      block.timestamp - 86_400 >= eventDate,
      "Too early"
    );
    require(balance > 0, "No funds");
    
    uint256 payOut = balance * 95 / 100;
    uint256 fee = balance * 5 / 100;
    
    bool success1 = token.transfer(contractOwner, fee);
    require(success1, "TX fail");
    bool success2 = token.transfer(eventOwner, payOut);
    require(success2, "TX fail");
    
    return true;
  }

}