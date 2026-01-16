// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ERC1155 } from "./ERC1155Base.sol";

contract ERC1155Token is ERC1155 {
  address immutable public owner;
  string public name;

  constructor(string memory newUri, string memory newName) {
    owner = msg.sender;
    name = newName;
    _setBaseURI(newUri);
  }

  function mint(address to, uint256 id, uint256 amount) public {
    require(msg.sender == owner, "Unauthorized");
    _mint(to, id, amount, "");
  }

  function mintBatchTickets(address to, uint256[] memory ids, uint256[] memory amounts) public {
    require(msg.sender == owner, "Unauthorized");
    _mintBatch(to, ids, amounts, "");
  }

  function burn(address from, uint256 id, uint256 value) public {
    require(msg.sender == owner, "Unauthorized");
    _burn(from, id, value);
  }

  function updateTicketUri(string memory newUri) public {
    require(msg.sender == owner, "Unauthorized");
    _setBaseURI(newUri);
  }
}