// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.20;

interface IERC1155 {


    event TransferSingle (address operator, address from, address to, uint256 id, uint256 value);


    event TransferBatch (address operator, address from, address to, uint256[] ids, uint256[] values);


    event ApprovalForAll (address account, address operator, bool approved);


    function balanceOf( address account, uint256 id)  external  view returns(uint256);


    function balanceOfBatch(address[] memory accounts, uint256[] memory ids) external view returns(   uint256[] memory);

    
    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns(bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 values, bytes memory data) external;


    function safeBatchTransferFrom( address from, address to, uint256[] memory ids, uint256[] memory values, bytes memory data) external;

}