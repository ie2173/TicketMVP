// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "lib/forge-std/src/Test.sol";
import "src/tokens/ERC721Base.sol";
import 'src/interfaces/IERC721.sol';
import 'src/interfaces/IERC721Receiver.sol';
import 'src/utils/ERC165.sol';


contract NFTToken is ERC721Base {
     
     uint256 public TOKEN_ID = 0;

     constructor(string memory _name, string memory _symbol, string memory _baseURL) {
        __name = _name;
        __symbol = _symbol;
        __baseURL = _baseURL;
     } 
     
     function mint(address _to) public {
        _mint(_to,TOKEN_ID);
        TOKEN_ID += 1;
     } 
}

contract NFTWALLETCONTRACT is IERC721Receiver {
   function onERC721Received(
      address _operator,
      address _from,
      uint256 _tokenId,
      bytes calldata _data
   ) public pure returns(bytes4){
      return 0x150b7a02;
   }

   function returnAddress() public view returns(address){ 
      return address(this);
   }
}

contract INVALIDNFTCONTRACT {
   function onERC721Received(
      address _operator,
      address _from,
      uint256 _tokenId,
      bytes calldata _data
   ) public pure returns(bytes4){
      return 0xFFFFFFFF;
   }

   function returnAddress() public view returns(address) {
      return address(this);
   }
}


contract ERC721Test is Test {
   
    NFTToken public ERC721;
    NFTWALLETCONTRACT public NFTCONTRACT;
    INVALIDNFTCONTRACT public INVALIDCONTRACT;
    string public NFTNAME = "DEMO";
    string public NFTSYMBOL = "DEMO";
    string public NFTBASEURL = "MONGOOSE";
    address public EOA1 = address(0x34);
    address public EOA2 = address(0x56);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function setUp() public {
       ERC721  = new NFTToken(NFTNAME, NFTSYMBOL, NFTBASEURL);

        
    }

    function testERC165() public {
      bytes4 IERC165InterfaceId = 0x01ffc9a7;
      // ERC 165 interface ID code for openzeppelin ERC721 Contracts.
      //Assert correct Interface ID's
      bytes4 IERC721InterfaceId = type(IERC721).interfaceId;
      bytes4 IERC721Id = 0x80ac58cd;
      assertEq(IERC721InterfaceId, IERC721Id);
      bytes4 IERC721MetaInterfaceId = type(IERC721Metadata).interfaceId;
      bytes4 ERC721MetaID = 0x5b5e139f;
      assertEq(IERC721MetaInterfaceId, ERC721MetaID);
      bool  IERC165Result = ERC721.supportsInterface(IERC165InterfaceId);
      assertTrue(IERC165Result);
      bool IERC721Result = ERC721.supportsInterface(IERC721InterfaceId);
      assertTrue(IERC721Result);
      bool IERC721MetaResult = ERC721.supportsInterface(IERC721MetaInterfaceId);
      assertTrue(IERC721MetaResult); 
      
      
      
    }

    function testMint() public {
      //Assert Minting Function works by checking initial mint receiver with 
        ERC721.mint(EOA1);
        address mint_owner = ERC721.ownerOf(0);
        assertEq(EOA1,mint_owner); 
      //Assert Minting Token Id Increments by one
         ERC721.mint(EOA2);
         address mint_owner2 = ERC721.ownerOf(1);
         assertEq(mint_owner2, EOA2);
    }

    function testName() public {
      string memory nameResult = ERC721.name();
      assertEq(nameResult, NFTNAME );
    }

    function testSymbol() public {
      string memory symbolResult = ERC721.symbol();
      assertEq(symbolResult, NFTSYMBOL );
    }

   function testBalanceOf() public {
      //Assert Initial Balance is Zero.
      uint256 BalanceResult = ERC721.balanceOf(EOA1);
      assertEq(BalanceResult, 0);
      //Assert Mint Raises Balance By One
      ERC721.mint(EOA1);
      BalanceResult = ERC721.balanceOf(EOA1);
      assertEq(BalanceResult,1);
      //Assert Non-Involved Account Balance Remains at Zero.
      BalanceResult = ERC721.balanceOf(EOA2);
      assertEq(BalanceResult, 0);
   }

      function testOwnerOf () public {
         //Assert Owner of index 0 is minter Account
         ERC721.mint(EOA1);
         address ownerResult = ERC721.ownerOf(0);
         assertEq(EOA1, ownerResult);
         //Assert Non-Minted Tokens reverts with correct message
         vm.expectRevert("Token Does Not Exist");
         ERC721.ownerOf(1);
         
      }

      function testTokenURI() public {
         ERC721.mint(EOA1);
         //Assert correct string return for token 1
         string memory expectedString = "MONGOOSE/0.json";
         string memory stringResults = ERC721.tokenURI(0);
         console.log("results:",expectedString,stringResults);
         assertEq(expectedString, stringResults);
         //Assert Unminted Token Reverts
         vm.expectRevert("Token Does Not Exist");
         ERC721.tokenURI(1000);
         
      }

      function testApprove() public {
         
         //Assert Approval of Token index 0 to EOA 1 With Event
         vm.startPrank(EOA1);
         ERC721.mint(EOA1);
         address mint_owner = ERC721.ownerOf(0);
         assertEq(mint_owner, EOA1);
         vm.expectEmit();
         emit Approval( EOA1,EOA2, 0);
         ERC721.approve(EOA2, 0);
         address approvalResults = ERC721.getApproved(0);
         assertEq(approvalResults, EOA2);

      }

      function testApproveRevert() public {
         vm.startPrank(EOA2);
         ERC721.mint(EOA1);
         vm.expectRevert("Unauthorized User!");
         ERC721.approve(EOA2, 0);


      }

      function testSafeTransferFrom() public {
         //Assert EOA contract transfers
         vm.startPrank(EOA1);
         ERC721.mint(EOA1);
         ERC721.safeTransferFrom(EOA1, EOA2, 0, "");
         address sTransferResult = ERC721.ownerOf(0);
         assertEq(sTransferResult,EOA2);
         // Assert Valid Contract accepts transfer
          NFTCONTRACT =  new NFTWALLETCONTRACT();
          address nftContractAddress = NFTCONTRACT.returnAddress();
         vm.startPrank(EOA2);
         ERC721.safeTransferFrom(EOA2, nftContractAddress, 0);
         sTransferResult = ERC721.ownerOf(0);
         assertEq(sTransferResult, nftContractAddress);

      }

      function testSafeTransferFromReverts() public {
         //Assert SafeTransferFrom to revert after sending to invalid contract
         vm.startPrank(EOA1);
         ERC721.mint(EOA1);
         INVALIDCONTRACT = new INVALIDNFTCONTRACT();
         address invalidcontract = INVALIDCONTRACT.returnAddress();
         vm.expectRevert("invalid Reciepeint");
         ERC721.safeTransferFrom(EOA1, invalidcontract, 0);
      }

      function testTransferFrom() public {
         //Assert Transfrom from Owner to New Owner
         vm.startPrank(EOA1);
         ERC721.mint(EOA1);
         vm.expectEmit();
         emit Transfer( EOA1, EOA2, 0);
         ERC721.transferFrom(EOA1, EOA2, 0);
         address transferResults = ERC721.ownerOf(0);
         assertEq(transferResults, EOA2);
         //Assert Transfer From EOA2 to EOA1. 
         vm.startPrank(EOA2);
         vm.expectEmit();
         emit Transfer( EOA2, EOA1, 0);
         ERC721.transferFrom(EOA2, EOA1, 0);
         transferResults = ERC721.ownerOf(0);
         assertEq(transferResults, EOA1);
         //Assert Approval can also transfer
         vm.startPrank(EOA1);
         vm.expectEmit();
         emit Approval(EOA1, EOA2, 0);
         ERC721.approve(EOA2, 0);
         vm.startPrank(EOA2);
         vm.expectEmit();
         emit Transfer(EOA1, address(0x10), 0);
         ERC721.transferFrom(EOA1, address(0x10), 0);
         transferResults = ERC721.ownerOf(0);
         assertEq(transferResults, address(0x10));

      }

      function testTransferFromRevert() public {
         //Assert Transfer Reverts when unauthorized user tries to transfer another token
         vm.startPrank(EOA2);
         ERC721.mint(EOA1);
         vm.expectRevert("Unauthorized User");
         ERC721.transferFrom(EOA2, EOA2, 0);
         // Assert From input must be owner NFT.
         vm.startPrank(EOA1);
         vm.expectRevert("From input Must be NFT Owner.");
         ERC721.transferFrom(address(0x1), EOA2, 0);
      }

      function testGetApproved() public {
        // Assert approval shows up for approve from EOA1 to EOA2
         vm.startPrank(EOA1);
         ERC721.mint(EOA1);
         ERC721.approve(EOA2, 0);
         address approvalResult = ERC721.getApproved(0);
         assertEq(approvalResult, EOA2);
         //Assert Address zero return when No approvals
         ERC721.mint(EOA2);
         approvalResult = ERC721.getApproved(1);
         assertEq(approvalResult, address(0));

      }

      function testIsApprovedForAll() public {
         //Assert Is Approved For All returns true when EOA2 is approved to 
         vm.startPrank(EOA1);
         ERC721.mint(EOA1);
         ERC721.setApprovalForAll(EOA2, true);
         bool approvalresults = ERC721.isApprovedForAll(EOA1, EOA2);
         assertEq(approvalresults, true);
         approvalresults = ERC721.isApprovedForAll(EOA2, EOA1);
         assertEq(approvalresults, false);
      }

      function testSetApprovalForAll() public {
         //Assert Approval can be set, Event is Emitted
         vm.startPrank(EOA1);
         vm.expectEmit();
         emit ApprovalForAll(EOA1, EOA2, true);
         ERC721.setApprovalForAll(EOA2, true);
         



      }
}
