// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC165 {
  function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

contract ERC165 is IERC165 {
  function supportsInterface(bytes4 interfaceId) external view virtual override returns (bool) {
    return interfaceId == type(IERC165).interfaceId;
  }
}
