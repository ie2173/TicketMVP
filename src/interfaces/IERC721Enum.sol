// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.13;

interface IERC721Enum {
    function totalSupply()
        external
        view
        returns (uint256);

    function tokenByIndex(
        uint256 _index
    )
        external
        view
        returns (uint256);

    function tokenOfOwnerByIndex(
        uint256 _index
    )
        external
        view
        returns (address);
}