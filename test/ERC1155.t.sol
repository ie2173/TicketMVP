// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "lib/forge-std/src/Test.sol";
//import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "src/tokens/ERC1155Base.sol";
import "src/interfaces/IERC1155Receiver.sol";
import "src/utils/ERC165.sol";

//contract ERC1155Token is ERC1155URIStorage {
contract ERC1155Token is ERC1155 { 
    address public owner;
    string public name;
    uint256 public totalGeneralSupply;
    uint256 public totalVipSupply;
    uint256 public generalTokenId = 0;
    uint256 public vipTokenId = 0;
    uint256 public tokenId = 0;

    constructor(string memory newUri, string memory newName, uint256 generalSupply, uint256 vipSupply) public   {

        owner = msg.sender;
        name = newName;
        totalGeneralSupply = generalSupply;
        totalVipSupply = vipSupply;
        _setBaseURI(newUri); 
    }

    function mintGeneralTicket(address to, uint256 amount) public returns (uint256[] memory){
        require(msg.sender == owner, "Required to use Cheers Finance to Mint Tickets");
        generalTokenId += amount;
        require(generalTokenId <= totalGeneralSupply, "Tickets Sold Out");
        _mint(to, 0, amount, "");
    }

    function mintVipTicket(address to, uint256 amount) public {
        require(msg.sender == owner, "Required to use Cheers Finance to Mint Tickets");
        vipTokenId += amount;
        require(vipTokenId <= totalVipSupply, "Tickets Sold Out");
        _mint(to, 1, amount,"");
    }

    function mintBatchTickets(address to, uint256[] memory ids, uint256[] memory amounts) public {
        require(msg.sender == owner, "Required to use Cheers Finance to mint tickets");
        require(ids.length == amounts.length,"Ids and Amounts must be equal");
        for (uint256 i; i < ids.length; ++i) {
            if (ids[i] == 0) {
                require(generalTokenId + amounts[i] <= totalGeneralSupply,"General Tickets are over capacity");

            } 
            if (ids[i]==1){
                require(vipTokenId + amounts[i] <= totalVipSupply, "Vip Tickets are over capacity");

            }
        }
        _mintBatch(to, ids, amounts, "");
    }
}

contract ERC1155Receiver is IERC1155Receiver {
    function onERC1155Received(address operator, address from,uint256  id, uint256 value, bytes memory data) public pure returns (bytes4) {
        return this.onERC1155Received.selector;

    }

    function onERC1155BatchReceived(address operator, address from,uint256[] memory  ids,uint256[] memory   values, bytes memory data) public pure override  returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    function getAddress() public view returns(address) {
        return address(this);
    }

}

contract INVALIDERC1155Receiver is IERC1155Receiver {
    function onERC1155Received(address operator, address from,uint256  id, uint256 value, bytes memory data) public pure returns (bytes4) {
        return bytes4(0xffffffff);

    }

    function onERC1155BatchReceived(address operator, address from, uint256[] memory ids, uint256[] memory values, bytes memory data) public pure  returns (bytes4) {
        return bytes4(0x00000000);
    }

    function getAddress() public view returns(address) {
        return address(this);
    }

}

contract ERC1155BaseTest is Test {
    ERC1155Token public erc1155;
    ERC1155Receiver public receiver;
    INVALIDERC1155Receiver public invalidReceiver;
    address public exampleOwner = address(this);
    string public exampleName = "Concert Name";
    string public exampleUrl = "IPFS:4206969";
    uint256 public exampleGeneralSupply = 10;
    uint256 public exampleVipSupply = 5;
    address public eoa1 = address(0x01);
    address public eoa2 = address(0x02);

    event TransferSingle (address operator, address from, address to, uint256 id, uint256 value);


    event TransferBatch (address operator, address from, address to, uint256[] ids, uint256[] values);

    event ApprovalForAll (address account, address operator, bool approved);

    function setUp() public {
        erc1155 = new ERC1155Token(exampleUrl,exampleName, exampleGeneralSupply, exampleVipSupply);
    }

    function testSupportsInterface() public {
    bytes4 ierc1155interfaceId = 0xd9b67a26;
 // ERC1155MEta Interface Id:  0x0e89341c
    bytes4 ierc1155MetainterfaceId = 0x0e89341c;
 // ERC165 Interface Id: 0x01ffc9a7 
    bytes4 ierc165interfaceId = 0x01ffc9a7;
    bool iERC165Result = erc1155.supportsInterface(ierc165interfaceId);
    assertTrue(iERC165Result);
    bool iERC1155Result = erc1155.supportsInterface(ierc1155interfaceId);
    assertTrue(iERC1155Result);
    bool iERC1155MetaResult = erc1155.supportsInterface(ierc1155MetainterfaceId);
    assertTrue(iERC1155MetaResult);
    }


    function testName() public {
        string memory nameResult = erc1155.name();
        assertEq(nameResult, "Concert Name");
    }

    function testUrl() public {
        string memory uriResult = erc1155.uri();
        assertEq(uriResult, "IPFS:4206969");
    }

    function testMintGeneralTicket() public {
        // Mint One Token
        vm.expectEmit();
        emit TransferSingle(address(this), address(0),eoa1,0,1);
        erc1155.mintGeneralTicket(eoa1, 1);
        uint256 balanceResult = erc1155.balanceOf(eoa1, 0);
        uint256 idResult = erc1155.generalTokenId();
        assertEq(balanceResult, 1);
        assertEq(idResult, 1);

        // Mint 9 Tokens
        vm.expectEmit();
        emit TransferSingle(address(this), address(0), eoa1, 0, 9);
        erc1155.mintGeneralTicket(eoa1, 9);
        uint256 balanceResult1 = erc1155.balanceOf(eoa1, 0);
        uint256 idResult1 = erc1155.generalTokenId();
        assertEq(balanceResult1, 10);
        assertEq(idResult1, 10);
        // Expect Revert over Capacity
        vm.expectRevert("Tickets Sold Out");
        erc1155.mintGeneralTicket(eoa1, 50);
    }
    

    function testMintVipTicket() public {
        // mint one Token
        vm.expectEmit();
        emit TransferSingle(address(this),address(0), eoa1, 1, 1);
        erc1155.mintVipTicket(eoa1, 1);
        uint256 balanceResult = erc1155.balanceOf(eoa1, 1);
        uint256 idResult = erc1155.vipTokenId();
        assertEq(balanceResult, 1);
        assertEq(idResult, 1);
        // mint 4 tokens
        vm.expectEmit();
        emit TransferSingle(address(this),address(0), eoa1, 1, 4);
        erc1155.mintVipTicket(eoa1, 4);
        uint256 balanceResult1 = erc1155.balanceOf(eoa1, 1);
        uint256 idResult1 = erc1155.vipTokenId();
        assertEq(balanceResult1, 5);
        assertEq(idResult1, 5);
        // Expect Revert over Capacity
        vm.expectRevert("Tickets Sold Out");
        erc1155.mintVipTicket(eoa1, 12);
    }

    function testBatchTickets() public {
        uint256[] memory idArray = new uint256[](2);
        uint256[] memory valueArray = new uint256[](2);
        uint256[] memory maxValueArray = new uint256[](2);
        uint256[] memory generalOverloadValueArray = new uint256[](2); 
        uint256[] memory vipOverloadValueArray = new uint256[](2);
        idArray[0] = 0;
        idArray[1] = 1;
        valueArray[0] = 1;
        valueArray[1] = 1;
        maxValueArray[0] = 9;
        maxValueArray[1] = 4;
        generalOverloadValueArray[0] = 15;
        generalOverloadValueArray[1] = 1;
        vipOverloadValueArray[0] = 1;
        vipOverloadValueArray[1] = 15;
        // Single vip & general Tickets
        vm.expectEmit();
        emit TransferBatch(address(this), address(0), eoa1, idArray, valueArray);
        erc1155.mintBatchTickets(eoa1, idArray, valueArray);
        uint256 batchGenResult = erc1155.balanceOf(eoa1, 0);
        uint256 batchVipResult = erc1155.balanceOf(eoa1, 1);
        assertEq(batchGenResult, 1);
        assertEq(batchVipResult, 1);
        // expect revert with overload General ticket purchase
        vm.expectRevert("General Tickets are over capacity");
        erc1155.mintBatchTickets(eoa1, idArray, generalOverloadValueArray);
        

        // expect revert with Overload VUP Ticket Purchase
        vm.expectRevert("Vip Tickets are over capacity");
        erc1155.mintBatchTickets(eoa1, idArray, vipOverloadValueArray);
        
        // Max Vip & General Tickets
        vm.expectEmit();
        emit TransferBatch(address(this), address(0), eoa1, idArray, maxValueArray);
        erc1155.mintBatchTickets(eoa1, idArray, maxValueArray);
        uint256 batchGenResult1 = erc1155.balanceOf(eoa1, 0);
        uint256 batchVipResult1 = erc1155.balanceOf(eoa1, 1);
        assertEq(batchGenResult1, 10);
        assertEq(batchVipResult1, 5);
    } 

    function testBalanceofBatch() public {
        address[] memory accountArray = new address[](4);
        uint256[] memory idArray = new uint256[](4);
        uint256[] memory mintIdArray = new uint256[](2);
        uint256[] memory mintAmountArray = new uint256[](2);
        accountArray[0] = eoa1;
        accountArray[1] = eoa2;
        accountArray[2] = eoa1;
        accountArray[3] = eoa2;
        idArray[0] = 0;
        idArray[1] = 0;
        idArray[2] = 1;
        idArray[3] = 1;
        mintIdArray[0] = 0;
        mintIdArray[1] = 1;
        mintAmountArray[0] = 5;
        mintAmountArray[1] = 2;
        erc1155.mintBatchTickets(eoa1, mintIdArray, mintAmountArray);
        erc1155.mintBatchTickets(eoa2, mintIdArray, mintAmountArray);
        uint256[] memory batchResult = erc1155.balanceOfBatch(accountArray, idArray);
        assertEq(batchResult[0], 5);
        assertEq(batchResult[1], 5);
        assertEq(batchResult[2], 2);
        assertEq(batchResult[3], 2);
    }

    function testApproveForAll() public {
        vm.startPrank(eoa1);
        vm.expectEmit();
        emit ApprovalForAll(eoa1, eoa2, true);
        erc1155.setApprovalForAll(eoa2, true);
        bool result = erc1155.isApprovedForAll(eoa1, eoa2);
        assertTrue(result);
    }

    function testsafeTransferFrom() public {
        // Set up transfer to EOA1, give EOA1 permission for EOA2.
        // set up safe smart contract & Invalid contract
        erc1155.mintGeneralTicket(eoa1, 1);
        erc1155.mintVipTicket(eoa1, 1);
        vm.startPrank(eoa2);
        erc1155.setApprovalForAll(eoa1, true);
        vm.stopPrank();
        ERC1155Receiver safeContract = new ERC1155Receiver();
        address safeContractAddress = safeContract.getAddress();
        INVALIDERC1155Receiver unsafeContract = new INVALIDERC1155Receiver();
        address unsafeContractAddress = unsafeContract.getAddress();
        // Test Owner initiated 
        vm.expectEmit();
        emit TransferSingle (eoa1, eoa1, eoa2, 0, 1);
        vm.startPrank(eoa1);
        erc1155.safeTransferFrom(eoa1, eoa2, 0, 1, "");
        uint256 transfer1result = erc1155.balanceOf(eoa2, 0);
        uint256 transfer1result1 = erc1155.balanceOf(eoa1, 0);
        assertEq(transfer1result, 1);
        assertEq(transfer1result1,0);
        vm.stopPrank();
        // Test approved operator initiated
        vm.expectEmit();
        emit TransferSingle(eoa1, eoa2, eoa1, 0, 1);
        vm.startPrank(eoa1);
        erc1155.safeTransferFrom(eoa2, eoa1, 0, 1, "");
        uint256 transfer2Result = erc1155.balanceOf(eoa1, 0);
        uint256 transfer2Result1 = erc1155.balanceOf(eoa2, 0);
        assertEq(transfer2Result, 1);
        assertEq(transfer2Result1, 0);
        vm.stopPrank();
        // test smart contract received successful
        vm.expectEmit();
        emit TransferSingle(eoa1, eoa1, safeContractAddress, 0, 1);
        vm.startPrank(eoa1);
        erc1155.safeTransferFrom(eoa1, safeContractAddress, 0, 1, "");
        uint256 contractBalanceResult = erc1155.balanceOf(safeContractAddress, 0);
        assertEq(contractBalanceResult, 1);

        // test not operator initiated reverts
        vm.startPrank(eoa2);
        vm.expectRevert();
        erc1155.safeTransferFrom(eoa1, eoa2, 1, 1, "");
        vm.stopPrank();

        // test invalid smart contract reverts
        vm.startPrank(eoa1);
        vm.expectEmit();
        emit TransferSingle(eoa1, eoa1, unsafeContractAddress, 1, 1);
        vm.expectRevert();
        erc1155.safeTransferFrom(eoa1, unsafeContractAddress, 1, 1, "");
        uint256 balanceCheck = erc1155.balanceOf(unsafeContractAddress, 1);
        assertEq(balanceCheck, 0);

        //test insufficient balance revert
        address eoa3 = address(0x003);
        vm.startPrank(eoa3);
        vm.expectRevert();
        erc1155.safeTransferFrom(eoa3, eoa1, 0, 5, "");
    }

    function testsafeBatchTransferFrom() public {
        uint256[] memory idArray = new uint256[](2);
        uint256[] memory valueArray = new uint256[](2);
        idArray[0] = 0;
        idArray[1] = 1;
        valueArray[0] = 1;
        valueArray[1] = 1;
        erc1155.mintBatchTickets(eoa1, idArray, valueArray);
        vm.startPrank(eoa2);
        erc1155.setApprovalForAll(eoa1, true);
        vm.stopPrank();
        ERC1155Receiver safeContract = new ERC1155Receiver();
        address safeContractAddress = safeContract.getAddress();
        INVALIDERC1155Receiver unsafeContract = new INVALIDERC1155Receiver();
        address unsafeContractAddress = unsafeContract.getAddress();
        //test owner initiated
        vm.startPrank(eoa1);
        vm.expectEmit();
        emit TransferBatch(eoa1, eoa1, eoa2, idArray, valueArray);
        erc1155.safeBatchTransferFrom(eoa1, eoa2, idArray, valueArray, "");
        uint256 generalBalanceResult = erc1155.balanceOf(eoa2, 0); 
        uint256 vipBalanceResult = erc1155.balanceOf(eoa2, 1);
        assertEq(generalBalanceResult, 1);
        assertEq(vipBalanceResult, 1); 

        // test approved operator initiated
        vm.expectEmit();
        emit TransferBatch(eoa1, eoa2, eoa1, idArray, valueArray);
        erc1155.safeBatchTransferFrom(eoa2, eoa1, idArray, valueArray, "");
        uint256 generalBalanceResult1 = erc1155.balanceOf(eoa1, 0); 
        uint256 vipBalanceResult1 = erc1155.balanceOf(eoa1, 1);
        assertEq(generalBalanceResult1, 1);
        assertEq(vipBalanceResult1, 1);   

        //test smart contract received approved
        vm.expectEmit();
        emit TransferBatch(eoa1, eoa1, safeContractAddress, idArray, valueArray);
        erc1155.safeBatchTransferFrom(eoa1, safeContractAddress, idArray, valueArray, "");
        uint256 generalBalanceResult2 = erc1155.balanceOf(safeContractAddress, 0);
        uint256 vipBalanceResult2 = erc1155.balanceOf(safeContractAddress, 1);
        assertEq(generalBalanceResult2, 1);
        assertEq(vipBalanceResult2, 1);

        // test invalid balance of revert
        assertEq(erc1155.balanceOf(eoa1, 0), 0);
        assertEq(erc1155.balanceOf(eoa1, 1),0);
        vm.expectRevert();
        erc1155.safeBatchTransferFrom(eoa1, eoa2, idArray, valueArray, "");

        // test invalid operator revert
        vm.stopPrank();
        erc1155.mintBatchTickets(eoa2, idArray, valueArray);
        vm.startPrank(eoa2);
        vm.expectEmit();
        emit ApprovalForAll(eoa2, eoa1, false);
        erc1155.setApprovalForAll(eoa1, false);
        vm.stopPrank();
        vm.startPrank(eoa1);
        vm.expectRevert();
        erc1155.safeBatchTransferFrom(eoa2, eoa1, idArray, valueArray, "");
        vm.stopPrank();

        // test invalid smart contract revert
        vm.startPrank(eoa2);
        vm.expectRevert();
        erc1155.safeBatchTransferFrom(eoa2, unsafeContractAddress, idArray, valueArray, "");
        uint256 generalBalanceResult3 = erc1155.balanceOf(unsafeContractAddress, 0);
        uint256 vipBalanceResult3 = erc1155.balanceOf(unsafeContractAddress, 1);
        assertEq(generalBalanceResult3, 0);
        assertEq(vipBalanceResult3, 0);

    }
}