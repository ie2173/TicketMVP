// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script } from "lib/forge-std/src/Script.sol";
import { console } from "lib/forge-std/src/console.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { TicketOfficeUpgradeable } from "../src/TicketOfficeUpgradeable.sol";

/**
 * @title DeployUpgradeableTicketOffice
 * @dev Deployment script for upgradeable ticket office
 */
contract DeployUpgradeableTicketOffice is Script {
  address public constant MAINNET_USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
  address public constant SEPOLIA_USDC = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238;
  address public constant OWNER = 0x70AFEF91DAe765B1E45A9736c21D7cd061EAf205;

  function run() external {
    uint256 chainId = block.chainid;
    address usdcAddress;
    
    if (chainId == 1) {
      usdcAddress = MAINNET_USDC;
      console.log("Deploying to Mainnet");
    } else if (chainId == 11155111) {
      usdcAddress = SEPOLIA_USDC;
      console.log("Deploying to Sepolia");
    } else {
      usdcAddress = MAINNET_USDC; // Default for forks
      console.log("Deploying to Local/Fork");
    }

    console.log("Using USDC address:", usdcAddress);
    console.log("Owner address:", OWNER);

    vm.startBroadcast();

    // Deploy the implementation
    TicketOfficeUpgradeable implementation = new TicketOfficeUpgradeable();
    console.log("Implementation deployed at:", address(implementation));

    // Prepare initialization data
    bytes memory initData = abi.encodeWithSelector(
      TicketOfficeUpgradeable.initialize.selector,
      "Cheers Finance",
      usdcAddress,
      OWNER
    );

    // Deploy the proxy
    ERC1967Proxy proxy = new ERC1967Proxy(
      address(implementation),
      initData
    );

    console.log("Proxy deployed at:", address(proxy));
    console.log("Ticket Office is ready at:", address(proxy));

    vm.stopBroadcast();

    // Verify the deployment
    TicketOfficeUpgradeable ticketOffice = TicketOfficeUpgradeable(address(proxy));
    console.log("Ticket Office Open:", ticketOffice.ticketOfficeOpen());
    console.log("Owner:", ticketOffice.owner());
  }
}