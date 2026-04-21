# Frontend Bug Fix: `!OP` Error on Ticket Purchase

## Problem

Users attempting to purchase tickets via `buyTickets()` receive a `ContractFunctionExecutionError` with revert reason `!OP`.

## Root Cause

The frontend is calling the **old, de-registered v1 TicketOperations contract**. This contract was replaced during a redeployment and is no longer authorized to modify event data.

When v1 TicketOperations tries to call `eventData.incrementTicketsSold()`, the EventData contract checks:

```solidity
require(
    msg.sender == factory || 
    IFactory(factory).isOperationContract(msg.sender),
    "!OP"
);
```

Since v1 was de-registered (`isOperationContract(v1) == false`), this check fails and the transaction reverts with `!OP`.

## Fix Required

Update the TicketOperations contract address in the frontend:

| | Address |
|---|---|
| **OLD (broken, de-registered)** | `0x0c931FC196D678b6F327c5d03D8253F75575B484` |
| **NEW (correct, active)** | `0xb5F29FEe54F85DF5cB9e10D45edc77227902Df60` |

### Steps:
1. Find where the TicketOperations address is configured in the frontend (likely an env var, config file, or constants file).
2. Replace `0x0c931FC196D678b6F327c5d03D8253F75575B484` with `0xb5F29FEe54F85DF5cB9e10D45edc77227902Df60`.
3. Ensure USDC `approve()` calls also target the **new** address — users must approve the new TicketOperations contract to spend their USDC.

### USDC Approval Reminder
The `transferFrom` in `buyTickets()` pulls USDC from the buyer. The approval must be granted to the **TicketOperations contract address** (not the Factory, not EventData). If users previously approved the old v1 address, they will need to approve the new v2 address.

## All Mainnet Contract Addresses (Current)

| Contract | Address | Status |
|---|---|---|
| **TicketOfficeFactory** | `0xE2A349548e3Aff59681f0eA1c25779F830Fb3ee0` | Active |
| **TicketOperations (v2)** | `0xb5F29FEe54F85DF5cB9e10D45edc77227902Df60` | Active, registered |
| **AdminOperations** | `0x0a9E911BdAc9b4f5327b4D47A851c6E031D74c03` | Active, registered |
| **USDC (Mainnet)** | `0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48` | — |

### Event-Specific (Jazz Nights, eventId=0)

| Contract | Address |
|---|---|
| **EventData** | `0x2085e1a7c5A87129077882d4CD0EF16aB765c2Bc` |
| **ERC1155Token (Ticket NFT)** | `0xabC407298Eb2D7476eBBa1730C0d5be16591C27A` |

## No Contract Changes Required

This is a frontend-only fix. All smart contracts are correctly deployed and configured on-chain. Verified:
- TicketOperations v2 is registered with the factory (`isOperationContract = true`)
- Factory `ticketOfficeOpen = true`
- Event is not locked
- Ticket capacity and pricing are correctly set (3 ticket types, 100 capacity each, 1 USDC price)
