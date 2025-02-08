// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "lib/forge-std/src/Script.sol";
import "lib/forge-std/src/console.sol";
import "../src/TicketOffice.sol";

contract TicketOfficeDeployScript is Script {
    address public USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public SEPOLIAUSDC = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238;
    
    // The address that will sign the transaction
    address public constant SIGNER = 0x70AFEF91DAe765B1E45A9736c21D7cd061EAf205;

    function setUp() public {}

    function run() public {
        console.log("Transaction signer:", SIGNER);
        
        vm.startBroadcast();

        // Using a consistent salt for cross-chain deployment
        bytes32 salt = keccak256(abi.encodePacked("TicketOffice_v1"));
        console.log("Salt used:", vm.toString(salt));

        // Deploy using CREATE2 with Forge's native support
        TicketOffice ticketOffice = new TicketOffice{salt: salt}(
            "Cheers Finance",
            USDC
        );

        address deployedAddress = address(ticketOffice);
        console.log("Deployed to:", deployedAddress);

        vm.stopBroadcast();
    }
}