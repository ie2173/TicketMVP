// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "src/interfaces/IERC20.sol";
import { EventData } from "src/EventData.sol";
import { ERC1155Token } from "src/ERC1155Token.sol";
import { TicketStructs } from "src/libraries/TicketStructs.sol";

contract TicketOfficeFactory {
  // State variables
  address[] public events; // Array of EventData contracts
  bool public ticketOfficeOpen;
  address public immutable owner;
  IERC20 public immutable usdc;
  
  // Authorized operation contracts
  mapping(address => bool) public isOperationContract;

  // Events
  event EventCreated(
    uint256 indexed eventId,
    address indexed eventData,
    address indexed ticketToken
  );
  event OfficeToggled(bool isOpen);
  event OperationContractSet(address indexed operationContract, bool authorized);

  // Modifiers
  modifier onlyOwner() {
    require(msg.sender == owner, "!A");
    _;
  }

  constructor(address _usdc, address _owner) {
    usdc = IERC20(_usdc);
    owner = _owner;
    ticketOfficeOpen = true;
  }

  // ============ EVENT CREATION ============
  // Factory creates EventData and ERC1155Token, adds to array
  // Anyone can create events - no restrictions!
  
  function createEvent(
    address _eventOwner,
    string calldata _tokenUri,
    TicketStructs.Ticketdetails calldata _details
  ) external returns (uint256 eventId, address eventData, address ticketToken) {
    // Create ERC1155 token for this event
    ERC1155Token newToken = new ERC1155Token(_tokenUri, _details.name);
    
    // Get the new event ID (current array length)
    eventId = events.length;
    
    // Create EventData storage contract
    EventData newEventData = new EventData(
      address(this),
      address(newToken),
      _eventOwner,
      eventId,
      address(usdc),
      _details
    );
    
    // Add to events array
    events.push(address(newEventData));
    
    eventData = address(newEventData);
    ticketToken = address(newToken);
    
    emit EventCreated(eventId, eventData, ticketToken);
    return (eventId, eventData, ticketToken);
  }

  // ============ ADMIN FUNCTIONS ============

  function setOperationContract(address _contract, bool _authorized) external onlyOwner {
    isOperationContract[_contract] = _authorized;
    emit OperationContractSet(_contract, _authorized);
  }

  function toggleOffice() external onlyOwner {
    ticketOfficeOpen = !ticketOfficeOpen;
    emit OfficeToggled(ticketOfficeOpen);
  }

  // ============ VIEW FUNCTIONS ============

  function getEventData(uint256 id) external view returns (address) {
    return id < events.length ? events[id] : address(0);
  }
  
  function getEventCount() external view returns (uint256) {
    return events.length;
  }
}
