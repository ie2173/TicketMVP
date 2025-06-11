// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC1155/ERC1155.sol)

import { IERC1155 } from "../interfaces/IERC1155.sol";
import { IERC1155Meta } from "../interfaces/IERC1155Meta.sol";
import { IERC1155Receiver } from "../interfaces/IERC1155Receiver.sol";
import { ERC165 } from "../utils/ERC165.sol";
import { Arrays } from "@openzeppelin/contracts/utils/Arrays.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

contract ERC1155 is ERC165, IERC1155 {
  using Arrays for uint256[];
  using Arrays for address[];
  using Strings for uint256;

  mapping(uint256 id => mapping(address account => uint256)) private _balances;

  mapping(address account => mapping(address operator => bool)) private _operatorApprovals;

  string private _baseUri;

  function supportsInterface(bytes4 interfaceId) public pure override returns (bool) {
    return interfaceId == type(IERC1155).interfaceId
      || interfaceId == type(IERC1155Meta).interfaceId || interfaceId == 0x01ffc9a7;
  }

  function uri() public view returns (string memory) {
    return _baseUri;
  }

  function balanceOf(address account, uint256 id) public view returns (uint256) {
    return _balances[id][account];
  }

  function balanceOfBatch(
    address[] memory accounts,
    uint256[] memory ids
  )
    public
    view
    returns (uint256[] memory)
  {
    if (accounts.length != ids.length) {
      revert();
    }
    uint256[] memory batchBalances = new uint256[](accounts.length);
    for (uint256 i = 0; i < accounts.length; ++i) {
      batchBalances[i] = balanceOf(accounts.unsafeMemoryAccess(i), ids.unsafeMemoryAccess(i));
    }

    return batchBalances;
  }

  function setApprovalForAll(address operator, bool approved) public {
    _setApprovalForAll(msg.sender, operator, approved);
  }

  function isApprovedForAll(address account, address operator) public view returns (bool) {
    return _operatorApprovals[account][operator];
  }

  function safeTransferFrom(
    address from,
    address to,
    uint256 id,
    uint256 value,
    bytes memory data
  )
    public
    virtual
  {
    if (from != msg.sender && !isApprovedForAll(from, msg.sender)) {
      revert();
    }
    _safeTransferFrom(from, to, id, value, data);
  }

  function safeBatchTransferFrom(
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory values,
    bytes memory data
  )
    public
    virtual
  {
    if (from != msg.sender && !isApprovedForAll(from, msg.sender)) {
      revert();
    }
    _safeBatchTransferFrom(from, to, ids, values, data);
  }

  function _update(
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory values
  )
    internal
    virtual
  {
    if (ids.length != values.length) {
      revert();
    }

    address operator = msg.sender;

    for (uint256 i = 0; i < ids.length; ++i) {
      uint256 id = ids.unsafeMemoryAccess(i);
      uint256 value = values.unsafeMemoryAccess(i);

      if (from != address(0)) {
        uint256 fromBalance = _balances[id][from];
        if (fromBalance < value) {
          revert();
        }
        unchecked {
          // Overflow not possible: value <= fromBalance
          _balances[id][from] = fromBalance - value;
        }
      }

      if (to != address(0)) {
        _balances[id][to] += value;
      }
    }

    if (ids.length == 1) {
      uint256 id = ids.unsafeMemoryAccess(0);
      uint256 value = values.unsafeMemoryAccess(0);
      emit TransferSingle(msg.sender, from, to, id, value);
    } else {
      emit TransferBatch(operator, from, to, ids, values);
    }
  }

  function _updateWithAcceptanceCheck(
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory values,
    bytes memory data
  )
    internal
    virtual
  {
    _update(from, to, ids, values);
    if (to != address(0)) {
      address operator = address(msg.sender);

      if (ids.length == 1) {
        uint256 id = ids.unsafeMemoryAccess(0);
        uint256 value = values.unsafeMemoryAccess(0);
        _doSafeTransferAcceptanceCheck(operator, from, to, id, value, data);
      } else {
        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, values, data);
      }
    }
  }

  function _setBaseURI(string memory newUri) internal virtual {
    _baseUri = newUri;
  }

  function _setApprovalForAll(address owner, address operator, bool approved) internal {
    if (operator == address(0)) {
      revert();
    }
    _operatorApprovals[owner][operator] = approved;
    emit ApprovalForAll(owner, operator, approved);
  }

  function _safeTransferFrom(
    address from,
    address to,
    uint256 id,
    uint256 value,
    bytes memory data
  )
    internal
  {
    if (to == address(0)) {
      revert();
    }
    if (from == address(0)) {
      revert();
    }
    (uint256[] memory ids, uint256[] memory values) = _asSingletonArrays(id, value);
    _updateWithAcceptanceCheck(from, to, ids, values, data);
  }

  function _safeBatchTransferFrom(
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory values,
    bytes memory data
  )
    internal
  {
    if (to == address(0)) {
      revert();
    }
    if (from == address(0)) {
      revert();
    }
    _updateWithAcceptanceCheck(from, to, ids, values, data);
  }

  function _mint(address to, uint256 id, uint256 value, bytes memory data) internal {
    // if (to == address(0)) {
    //revert('tripped address zero check on mint');
    //}
    (uint256[] memory ids, uint256[] memory values) = _asSingletonArrays(id, value);

    _updateWithAcceptanceCheck(address(0), to, ids, values, data);
  }

  function _mintBatch(
    address to,
    uint256[] memory ids,
    uint256[] memory values,
    bytes memory data
  )
    internal
  {
    if (to == address(0)) {
      revert();
    }
    _updateWithAcceptanceCheck(address(0), to, ids, values, data);
  }

  function _burn(address from, uint256 id, uint256 value) internal {
    if (from == address(0)) {
      revert();
    }
    (uint256[] memory ids, uint256[] memory values) = _asSingletonArrays(id, value);
    _updateWithAcceptanceCheck(from, address(0), ids, values, "");
  }

  

  function _doSafeTransferAcceptanceCheck(
    address operator,
    address from,
    address to,
    uint256 id,
    uint256 value,
    bytes memory data
  )
    private
  {
    if (to.code.length > 0) {
      try IERC1155Receiver(to).onERC1155Received(operator, from, id, value, data) returns (
        bytes4 response
      ) {
        if (response != IERC1155Receiver.onERC1155Received.selector) {
          revert();
        }
      } catch (bytes memory reason) {
        if (reason.length == 0) {
          revert();
        } else {
          assembly {
            revert(add(32, reason), mload(reason))
          }
        }
      }
    }
  }

  function _doSafeBatchTransferAcceptanceCheck(
    address operator,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory values,
    bytes memory data
  )
    private
  {
    if (to.code.length > 0) {
      try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, values, data) returns (
        bytes4 response
      ) {
        if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
          revert("Safe Batch acceptance check step 1");
        }
      } catch (bytes memory reason) {
        if (reason.length == 0) {
          revert("Do safe batch transfer acceptance check step 2");
        } else {
          assembly {
            revert(add(32, reason), mload(reason))
          }
        }
      }
    }
  }

  function _asSingletonArrays(
    uint256 element1,
    uint256 element2
  )
    private
    pure
    returns (uint256[] memory array1, uint256[] memory array2)
  {
    /// @solidity memory-safe-assembly
    assembly {
      // Load the free memory pointer
      array1 := mload(0x40)
      // Set array length to 1
      mstore(array1, 1)
      // Store the single element at the next word after the length (where content starts)
      mstore(add(array1, 0x20), element1)

      // Repeat for next array locating it right after the first array
      array2 := add(array1, 0x40)
      mstore(array2, 1)
      mstore(add(array2, 0x20), element2)

      // Update the free memory pointer by pointing after the second array
      mstore(0x40, add(array2, 0x40))
    }
  }
}
