// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.20;

library TicketStructs {
    struct Ticketdetails {
        string name;
        address owner;
        uint256 eventDate;
        Tickets ticketInformation;
        LocationDetails locationDetails;
        string[] performers;
        string[] keywords;
        string[] categories;
        string eventDescription;
        string eventType;
    }
    struct LocationDetails {
        string concertLocation;
        string venueName;
    }
    struct Tickets {
    string [] ticketNames;
    uint256 [] ticketCapacities;
    uint256 [] ticketPrices;
    uint256 [] ticketsSold;
}
}