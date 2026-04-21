// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ERC1155 } from "src/tokens/ERC1155Base.sol";

interface IFactory {
  function isOperationContract(address) external view returns (bool);
}

contract ERC1155Token is ERC1155 {
  address immutable public factory;
  string public name;

  constructor(string memory newUri, string memory newName) {
    factory = msg.sender;
    name = newName;
    _setBaseURI(newUri);
  }
  
  modifier onlyAuthorized() {
    require(
      msg.sender == factory || IFactory(factory).isOperationContract(msg.sender),
      "!AUTH"
    );
    _;
  }

  function mint(address to, uint256 id, uint256 amount) public onlyAuthorized {
    _mint(to, id, amount, "");
  }

  function mintBatchTickets(address to, uint256[] memory ids, uint256[] memory amounts) public onlyAuthorized {
    _mintBatch(to, ids, amounts, "");
  }

  function burn(address from, uint256 id, uint256 value) public onlyAuthorized {
    _burn(from, id, value);
  }

  function updateTicketUri(string memory newUri) public onlyAuthorized {
    _setBaseURI(newUri);
  }
}
