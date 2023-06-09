// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.20;

interface ITicketOffice {
    event TicketPurchased(address indexed _purchaser, uint256 indexed _tokenId);

    //return name of contract: 
    function name() external returns (string memory );

    //return event name by id
    function getEventName(uint256 _eventID) external returns (string memory);

    //return event owner address 
    function getEventOwner(uint256 _eventID) external returns (address);

    //return address for event
    function getAddress(uint256 _eventID) external returns (address);

    
    



    //creates an event related to tickets for a specific concert/event
    //Mint NFT
    //Emit event containing event name, price, nft address, string containing the event photo, if applicable
    //Grants msg.sender operator property of the NFT. and admin authorization on this contract
    //sets reciepient of the funds to receive it after event ends.
    function CreateTicketEvent(string memory name, string memory symbol, address treasuryAddress ) external  returns (address);


    // allows user to purchase a ticket, they pay the fee and 
    // 
    

    


}