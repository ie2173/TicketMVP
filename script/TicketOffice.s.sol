// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "../src/Create2.sol";
import "lib/forge-std/src/Script.sol";
import "forge-std/console.sol";
import "../src/TicketOffice.sol";

contract TicketOfficeDeployScript is Script {
    address public USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public SEPOLIAUSDC = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238;
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        Create2 create2 = new Create2();
        bytes32 salt = keccak256(abi.encodePacked("CheersFinance"));
        bytes memory bytecode = type(TicketOffice).creationCode;
        bytecode = abi.encodePacked(bytecode, abi.encode(USDC, SEPOLIAUSDC));
        address ticketOfficeAddress = create2.deploy(salt, bytecode);
        //TicketOffice ticketoffice = new TicketOffice("Cheers Finance",SEPOLIAUSDC);
        console.log("TicketOffice address: ", ticketOfficeAddress);
    }
}
