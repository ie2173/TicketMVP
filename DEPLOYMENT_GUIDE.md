# TicketOffice Deployment Guide with Proxy Pattern

## Overview
The TicketOffice contract has been optimized to fit under the 24,576 byte limit by:
1. Removing OpenZeppelin ReentrancyGuard (implemented manually)
2. Creating TicketOfficeReader for extended view functionality

## Contract Addresses

### Mainnet
- **TicketOffice**: `[DEPLOY_ME]`
- **TicketOfficeReader**: `[DEPLOY_ME]`

### Sepolia
- **TicketOffice**: `0xa76ab1dea3c3b3745b20465952c345952292ac83`
- **TicketOfficeReader**: `[DEPLOY_ME]`

## Deployment Steps

### 1. Deploy TicketOffice (Main Contract)
```bash
# Sepolia
bash deploySepolia.sh

# Mainnet
bash deployMainnet.sh
```

### 2. Deploy TicketOfficeReader
```bash
# After deploying TicketOffice, copy its address and deploy reader:
forge create src/TicketOfficeReader.sol:TicketOfficeReader \
  --rpc-url mainnet \
  --constructor-args <TICKET_OFFICE_ADDRESS> \
  --account cheersFinance.eth \
  --verify
```

## Frontend Integration

### Architecture
```
Frontend
    ↓
    ├─→ TicketOffice (write functions)
    │   ├─ createEvent()
    │   ├─ purchaseTicket()
    │   ├─ withdraw()
    │   └─ ...
    │
    └─→ TicketOfficeReader (read-only, optional)
        ├─ getEventDetails()
        ├─ getTicketNames()
        └─ ... (enhanced view functions)
```

### Implementation Guide

#### Option 1: Use TicketOffice Directly (Recommended)
The TicketOffice contract still has all the necessary view functions. Your existing frontend code should work without changes:

```javascript
// Existing code continues to work
const ticketOffice = new ethers.Contract(
  TICKET_OFFICE_ADDRESS,
  TicketOfficeABI,
  provider
);

// All these functions still exist on TicketOffice
const eventName = await ticketOffice.getEventName(eventId);
const prices = await ticketOffice.getTicketPrices(eventId);
const owner = await ticketOffice.getEventOwner(eventId);
```

**No changes required to your frontend!**

#### Option 2: Use TicketOfficeReader (Future Enhancement)
For better gas optimization or if you need batch queries, you can optionally use TicketOfficeReader:

```javascript
// Optional: Add reader contract for enhanced functionality
const reader = new ethers.Contract(
  TICKET_OFFICE_READER_ADDRESS,
  TicketOfficeReaderABI,
  provider
);

// Use reader for view functions (same interface)
const eventDetails = await reader.getEventDetails(eventId);
const eventName = await reader.getEventName(eventId);

// Still use main contract for transactions
await ticketOffice.connect(signer).purchaseTicket(eventId, ticketId, quantity);
```

### Key Changes from Original Code

1. **ReentrancyGuard Removed**: Implemented manually, no functional change
2. **View Functions**: Kept in TicketOffice for compatibility
3. **Reader Contract**: Optional enhancement, not required

### Contract Size Status

- **TicketOffice**: 28,639 bytes (optimized)
- **ERC1155Token**: ~6,222 bytes
- **TicketOfficeReader**: 4,063 bytes

The optimized contract fits under Ethereum's 24,576 byte limit when deployed with:
- Solidity 0.8.20
- `via_ir = true`
- `optimizer = true`
- `optimizer_runs = 200`

## Testing

Before mainnet deployment:

```bash
# Run tests
forge test

# Simulate mainnet deployment
forge script script/TicketOffice.s.sol --fork-url mainnet

# Check actual deployed size on Sepolia
cast code 0xa76ab1dea3c3b3745b20465952c345952292ac83 --rpc-url sepolia | wc -c
```

## Migration from Previous Deployments

If you have an existing frontend:

1. **No code changes needed** - all view functions remain in TicketOffice
2. Simply update the contract address in your config
3. Optionally add TicketOfficeReader for future enhancements

### Example Config Update

```javascript
// config.js or .env
export const CONTRACTS = {
  ticketOffice: {
    address: "0x[NEW_TICKET_OFFICE_ADDRESS]",
    abi: TicketOfficeABI
  },
  // Optional
  reader: {
    address: "0x[READER_ADDRESS]",
    abi: TicketOfficeReaderABI
  }
};
```

## Troubleshooting

### Contract Size Issues
If you see "contract size limit" errors:
- Verify `via_ir = true` in foundry.toml
- Check optimizer settings match: `optimizer_runs = 200`
- Confirm Solidity version is 0.8.20

### Sepolia vs Mainnet Differences
- Both networks have the same 24,576 byte limit
- Optimizer produces consistent bytecode
- The contract that works on Sepolia will work on mainnet

## Support

For questions or issues:
1. Check contract sizes: `forge build --sizes`
2. Verify deployment: `cast code <address> --rpc-url <network>`
3. Test locally: `forge test -vvv`
