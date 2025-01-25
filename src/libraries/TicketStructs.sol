// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.20;

library TicketStructs {
    struct Ticketdetails {
        string[] ticketNames;
        uint256[] ticketCapacities;
        uint256[] ticketPrices;
        uint256[] ticketsSold;
        string name;
        address owner;
        uint256 eventDate;
        string concertLocation;
        string[] performers;
        string[] keywords;
        string[] categories;
        string eventType;
    }
}