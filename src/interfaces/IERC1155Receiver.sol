// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC1155Receiver {
  function onERC1155Received(
    address operator,
    address from,
    uint256 id,
    uint256 value,
    bytes memory data
  )
    external
    returns (bytes4);

  function onERC1155BatchReceived(
    address operator,
    address from,
    uint256[] memory ids,
    uint256[] memory values,
    bytes memory data
  )
    external
    returns (bytes4);
}
