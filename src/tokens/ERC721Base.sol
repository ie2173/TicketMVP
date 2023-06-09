// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.20;

import "../interfaces/IERC721.sol";
import "../interfaces/IERC721MEta.sol";
import "../interfaces/IERC721Receiver.sol";
import "../utils/ERC165.sol";
import "../utils/Address.sol";

 contract ERC721Base is IERC721, IERC721Metadata, ERC165 {
    using AddressUtils for address;

    string internal _name;
    string internal _symbol;
    mapping(uint256 => address) public owners;
    mapping(address => uint256) public balances;
    mapping(uint256 => address) tokenApprovals;
    mapping(address => mapping(address => bool)) operatorApprovals;

  
    
    modifier OkApproval(uint256 _tokenID) {
        
        require(owners[_tokenID] == msg.sender || operatorApprovals[owners[_tokenID]][msg.sender], "Unauthorized User");

        _;
    }

    modifier OKTranfer(uint256 _tokenID) {
    
        require(owners[_tokenID] == msg.sender || tokenApprovals[_tokenID]== msg.sender || operatorApprovals[owners[_tokenID]][msg.sender], "Unauthorized User");
        
        _;
    }

    modifier OKNFT(uint256 _tokenID) {
        require(owners[_tokenID] != address(0),"Invalid Token"); 
        _;
    }

    

    function supportsInterface(bytes4 _interfaceID) public pure override returns(bool) {
        // compliant with Open Zeppelin IERC721: 
        return _interfaceID == type(IERC721).interfaceId || 
        _interfaceID == type(IERC721Metadata).interfaceId ||
        _interfaceID == 0x01ffc9a7;
    }
   
   function name() public view returns(string memory){
    return _name;

   }

   function symbol() public view returns(string memory) {
    return _symbol;
   }

   function balanceOf( address _owner) public view returns(uint256) {
    require( _owner != address(0),"Invalid Address");
    return balances[_owner];
    }

    function ownerOf (uint256 _tokenID) public view returns(address) {
         require (owners[_tokenID] != address(0), "Token Burned" );
         return owners[_tokenID];
    }

    function tokenURI (uint256 _tokenID) public pure returns(string memory) {
        uint256 token = _tokenID;

        if (token < 100) {
        string memory  returnValue = "HELL YEAH WOO GO TEAM";
        return returnValue ;}
        string memory altreturnvalue = "HELL YAH WOO WE DID IT.";
        return altreturnvalue; // Update this to add concert art, if applicable
    }

    function approve( address _to, uint256 _tokenID) public OkApproval(_tokenID) {
        tokenApprovals[_tokenID] = _to;
        emit Approval(ERC721Base.ownerOf(_tokenID), _to,_tokenID);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public {
        safeTransferFrom(_from,_to,_tokenId, "");

    }
    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) public OKTranfer(_tokenId) OKNFT(_tokenId){
        require(_to != address(0), "invalid Reciepient");
            
        if (_to.isContract()) {
            bytes4 returnValue = IERC721Receiver(_to).onERC721Received(msg.sender, _from,_tokenId, _data);
            require(returnValue ==0x150b7a02, "invalid Reciepeint"); // bytes4(keccak256("onERC721Received(address,uint256,bytes)")) 
            
        }
        _transfer(_to,_tokenId);

    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public OKTranfer(_tokenId) OKNFT(_tokenId){
        require(owners[_tokenId] == _from, "From input Must be NFT Owner.");
        _transfer(_to,_tokenId);
    }

    function getApproved(uint256 _tokenId) public view returns (address) {
        return tokenApprovals[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) public view returns (bool){
        return operatorApprovals[_owner][_operator];
    }

    function setApprovalForAll(address _operator, bool _approved) public {
        operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender,_operator, _approved);
    }
    
    function _transfer(address _to, uint256 _tokenId) internal virtual {
        address prevOwner = owners[_tokenId];
        delete tokenApprovals[_tokenId];
        balances[prevOwner] -= 1;
        owners[_tokenId] = _to;
        balances[_to] += 1;
        emit Transfer(prevOwner, _to, _tokenId);
    }

    function _mint(address _to, uint256 _tokenId) internal virtual {
        require(_to != address(0), 'invalid to address');
        require(owners[_tokenId] == address(0),'Token Already Exists'); 
        unchecked {
            balances[_to] += 1;
        }
        owners[_tokenId] = _to;
    }
    function _safeMint(address _to, uint256 _tokenId, bytes memory _data) internal virtual {
        if (_to.isContract()) {
            bytes4 returnValue = IERC721Receiver(_to).onERC721Received(msg.sender, address(0),_tokenId, _data);
            require(returnValue ==0x150b7a02, "invalid Reciepeint"); // bytes4(keccak256("onERC721Received(address,uint256,bytes)"))
            _mint(_to,_tokenId);
        }
    }
}