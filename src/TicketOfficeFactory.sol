// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "./interfaces/IERC20.sol";
import { TicketStructs } from "./libraries/TicketStructs.sol";
import { EventContract } from "./EventContract.sol";

contract TicketOfficeFactory {
  IERC20 immutable private _usdc;
  address immutable public contractOwner;
  
  uint256 private _count;
  bool public isOpen = true;
  
  // Event registry
  mapping(uint256 => address) public eventContracts;
  mapping(uint256 => TicketStructs.BasicEventInfo) public eventRegistry;
  mapping(address => uint256[]) public userEvents; // Events created by user
  
  event EventCreated(
    uint256 indexed eventId, 
    address indexed eventContract, 
    address indexed owner,
    string name
  );
  
  event OfficeStatusChanged(bool isOpen);

  modifier onlyOwner() {
    require(msg.sender == contractOwner, "Only owner");
    _;
  }

  modifier officeOpen() {
    require(isOpen, "Closed");
    _;
  }

  constructor(address usdcAddress) {
    _usdc = IERC20(usdcAddress);
    contractOwner = msg.sender;
  }

  function createEvent(
    TicketStructs.Ticketdetails calldata details,
    TicketStructs.TicketInformation calldata ticketInformation,
    string memory baseURL
  ) external officeOpen returns (uint256 eventId, address eventContract) {
    require(
      block.timestamp + 86_400 * 3 < details.eventDate,
      "3 days"
    );
    
    eventId = _count++;
    
    // Deploy EventContract
    EventContract newContract = new EventContract(address(_usdc), contractOwner, address(this));
    eventContract = address(newContract);
    
    // Initialize the event contract
    newContract.initialize(details, ticketInformation, baseURL);
    
    // Store in registry
    eventContracts[eventId] = eventContract;
    eventRegistry[eventId] = TicketStructs.BasicEventInfo(
      details.name,
      details.owner,
      details.eventDate,
      eventContract,
      ticketInformation.ticketNames.length
    );
    
    userEvents[msg.sender].push(eventId);
    
    emit EventCreated(eventId, eventContract, details.owner, details.name);
  }

  function toggle() external onlyOwner {
    isOpen = !isOpen;
    emit OfficeStatusChanged(isOpen);
  }

  // View functions for event discovery
  function getEventContract(uint256 eventId) external view returns (address) {
    return eventContracts[eventId];
  }

  function getEventInfo(uint256 eventId) external view returns (TicketStructs.BasicEventInfo memory) {
    return eventRegistry[eventId];
  }

  function getUserEvents(address user) external view returns (uint256[] memory) {
    return userEvents[user];
  }

  function getCount() external view returns (uint256) {
    return _count;
  }
}