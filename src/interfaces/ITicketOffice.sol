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
    
    // Get Event Price
    function getEventDetails(uint256 _eventId) external returns (uint256);


    //Get ownerof NFT.
    function getNFTBalance(address _NFTAddress, address _ownerAddress) external returns(bool);


    



    //creates an event related to tickets for a specific concert/event
    //Mint NFT
    //Emit event containing event name, price, nft address, string containing the event photo, if applicable
    //Grants msg.sender operator property of the NFT. and admin authorization on this contract
    //sets reciepient of the funds to receive it after event ends.
    function CreateTicketEvent(string memory name, string memory symbol, address treasuryAddress ) external  returns (address);


    // allows user to purchase a ticket, they pay the fee and mint an NFT ticket send to address
    // EMIT purchase
    //Payable with Eth
    
    
function PurchaseTicket(uint256 _EventID) external;

//Purchase Ticket, but with USDC
function PurchaseTicketWithUSDC(uint256 _EventId) external;

    // Condition to see if user gets free NFT due to condition.
    // If user redeems a ticket, switch a map variable to mark address redeemed.
    // mints ticket and sends to user.
    function RedeemTicket(uint _EventId) external;


}