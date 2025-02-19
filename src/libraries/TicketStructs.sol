// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.20;

library TicketStructs {

    struct Location {
        string name;
        string location;
    }

    struct TicketData {
        string[] ticketNames;
        uint256[] ticketCapacities;
        uint256[] ticketPrices;
        uint256[] ticketsSold;
    }
    struct Ticketdetails {
        TicketData ticketData;
        string name;
        address owner;
        uint256 eventDate;
        Location location;
        string[] performers;
        string[] keywords;
        string[] categories;
        string eventType;
    }
}