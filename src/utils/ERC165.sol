// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.20;

interface IERC165 {
    function supportsInterface(
        bytes4 _interfaceId
    )
        external
        view
        returns (bool);
}

contract ERC165 is IERC165 {
    

    

    function supportsInterface (
        bytes4 _interfaceId
    ) external virtual override view returns (bool) {
        return _interfaceId == type(IERC165).interfaceId;
    }

}