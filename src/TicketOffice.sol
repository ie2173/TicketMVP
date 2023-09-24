// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.20;

import "src/interfaces/IERC20.sol";
import "src/interfaces/IERC721.sol";
import "src/tokens/ERC721Base.sol";
import "src/interfaces/ITicketOffice.sol";

abstract contract ERC721Tickets is ERC721Base {
    address public owner;
    uint256 public totalSupply;
    uint256 public tokenId = 0;

    constructor(string memory _name, string memory _symbol, uint256 _totalSupply) {
        __name = _name;
        __symbol = _symbol;
        totalSupply = _totalSupply;
        owner = msg.sender;

        }

    function mint(address _to) public {
        require(msg.sender == owner, "Required to use Cheers Finance ticket booth to create ticket");
        require(tokenId < totalSupply, "Event Sold Out");
        _mint(_to, tokenId);
        tokenId++;
    }

}

abstract contract TicketOffice is ITicketOffice {
    struct TicketDetails {
        uint256 price;
        uint256 totalSupply;
        string name;
         address owner;


    }
    
    ERC721Tickets[] public ticketNft;
    string internal __name;
    address internal ContractOwner;
    uint256 internal eventIdCounter;
    mapping(uint256 => address) public eventTicketAddress;
    mapping(uint256 => mapping(address => bool)) public freeTicketVoucher;
    mapping(uint256 => TicketDetails) public eventDetails;


    constructor(string memory  _name) {
        ContractOwner = msg.sender;
        __name = _name;

    }

    modifier okAdmin(uint256 _EventId) {
        require(getEventOwner(_EventId) == msg.sender, "Unauthorized user");
        _;

    }

    function name() public view returns(string memory) {
        return __name;
    }

    function contractOwner() public view returns (address) {
        return ContractOwner;
    }

    function getEventName(uint256 _EventId) public view returns (string memory) {
        return eventDetails[_EventId].name;
    }

    function isEventOwner(uint256 _EventId, address _address) public view returns (bool) {
        return eventDetails[_EventId].owner == _address ? true : false;
    }

    function getAddress(uint256 _EventId) public view returns(address) {
        return eventTicketAddress[_EventId];

    }

    function getEventPrice(uint256 _EventId) public view returns (uint256) {
        return eventDetails[_EventId].price;
    }

    function getEventCapacity(uint256 _EventId) public view returns (uint256) {
        return eventDetails[_EventId].totalSupply;

    }

    function getTicketBalance(uint256 _EventId, address _ownerAddress) public view returns(uint256) {
        return IERC721(eventTicketAddress[_EventId]).balanceOf(_ownerAddress);
    }


    function RedeemTicket(uint256 _EventId) public {
        require(freeTicketVoucher[_EventId][msg.sender] == true, "Not Qualified to Redeem Ticket");
        freeTicketVoucher[_EventId][msg.sender] = false;
        ERC721Tickets(getAddress(_EventId)).mint(msg.sender);
    }

    function compOne(uint256 _EventId, address _address) public okAdmin(_EventId) {
        freeTicketVoucher[_EventId][_address] = true;

    }

    function compMany(uint256 _EventId, address[] memory _addresses) public okAdmin(_EventId) {
            for (uint i; i >_addresses.length; i++) {
                freeTicketVoucher[_EventId][_addresses[i]] == true;
            }
    }

    function getEventOwner(uint256 _EventId) public view returns(address) {
        return eventDetails[_EventId].owner;
    }
}