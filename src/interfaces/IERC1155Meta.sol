// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC1155Meta {
  event URI(string _value, uint256 _id);

  function uri(uint256 _id) external view returns (string memory);
}
