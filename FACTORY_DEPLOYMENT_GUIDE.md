# TicketOffice Factory + EventContract Deployment Guide

## Architecture Overview

The new architecture splits functionality into two main contracts:

1. **TicketOfficeFactory** (1,138 bytes) - Registry and global settings
2. **EventContract** (16,845 bytes per event) - Individual event logic and data

## Contract Sizes ✅

| Contract | Size | Status |
|----------|------|--------|
| TicketOfficeFactory | 1,138 bytes | ✅ 95% under limit |
| EventContract | 16,845 bytes | ✅ 31% under limit |
| ERC1155Token | 5,918 bytes | ✅ 76% under limit |

## Deployment Steps

### 1. Deploy Factory (One-time)

```bash
# Mainnet
bash deployFactoryMainnet.sh

# Sepolia
bash deployFactorySepolia.sh
```

The factory will be deployed with:
- USDC address (mainnet or testnet)
- Owner address (CheersFinance.eth)
- `ticketOfficeOpen = true` by default

### 2. Deploy EventContract (Per Event)

Each event gets its own contract instance:

```bash
# Set environment variables
export FACTORY_ADDRESS=<deployed-factory-address>
export USDC_ADDRESS=<usdc-address>

# Deploy event
forge script script/DeployEventContract.s.sol --rpc-url mainnet --broadcast --verify
```

The EventContract constructor will:
- Deploy an ERC1155Token for tickets
- Store all event details
- Register with the factory automatically

### 3. Frontend Integration

**Before (Old Architecture):**
```javascript
// Single contract
await ticketOffice.buyTickets(eventId, ticketIds, quantities);
await ticketOffice.getEventDetails(eventId);
```

**After (New Architecture):**
```javascript
// Step 1: Get event contract address from factory
const factory = new ethers.Contract(FACTORY_ADDRESS, FactoryABI, provider);
const eventAddress = await factory.getEventContract(eventId);

// Step 2: Interact with specific event contract
const eventContract = new ethers.Contract(eventAddress, EventABI, signer);
await eventContract.buyTickets(ticketIds, quantities, buyerAddress);
const details = await eventContract.getEventDetails();
```

## Key Differences

### Contract Deployment

**Old:** One large contract (~27KB, failed deployment)
**New:** Factory (1.1KB) + EventContract per event (16.8KB)

### Event Creation

**Old:**
```solidity
ticketOffice.createEvent(details, tokenUri);
```

**New:**
```solidity
// Off-chain: Deploy EventContract
EventContract event = new EventContract(factory, owner, usdc, name, uri, details);

// On-chain: Register with factory
factory.registerEvent(address(event), owner);
```

### Function Calls

| Old Function | New Function | Location |
|--------------|--------------|----------|
| `ticketOffice.buyTickets(eventId, ...)` | `eventContract.buyTickets(...)` | EventContract |
| `ticketOffice.getEventDetails(eventId)` | `eventContract.getEventDetails()` | EventContract |
| `ticketOffice.withdrawFunds(eventId)` | `eventContract.withdrawFunds()` | EventContract |
| `ticketOffice.toggleOffice()` | `factory.toggleOffice()` | Factory |

## Gas Cost Comparison

### Deployment Costs

| Action | Old | New | Difference |
|--------|-----|-----|------------|
| Initial deployment | Failed ❌ | ~$50 (factory) | Possible ✅ |
| Per event | Included | ~$300 (event) | +$300 per event |

### Execution Costs

| Action | Old | New | Difference |
|--------|-----|-----|------------|
| Buy tickets | ~$15 | ~$16 | +$1 (extra lookup) |
| Create event | ~$300 | ~$300 | Similar |
| Withdraw funds | ~$10 | ~$10 | Similar |

## Benefits

✅ **Deployable**: Each contract under 24.5KB limit  
✅ **Isolated**: Events can't interfere with each other  
✅ **Flexible**: Can upgrade EventContract logic for new events  
✅ **Secure**: Smaller attack surface per contract  
✅ **Scalable**: No single contract storage limits

## Migration Checklist

- [ ] Deploy TicketOfficeFactory to mainnet
- [ ] Verify factory contract on Etherscan
- [ ] Update frontend to use factory + event contract pattern
- [ ] Test event creation on testnet
- [ ] Deploy first production event
- [ ] Update documentation and SDK
- [ ] Deprecate old contract (keep for reference)

## Shell Scripts

Create these deployment scripts:

### deployFactoryMainnet.sh
```bash
#!/bin/bash
forge script script/TicketOfficeFactory.s.sol \\
  --rpc-url mainnet \\
  --broadcast \\
  --verify \\
  -vvvv
```

### deployEventMainnet.sh
```bash
#!/bin/bash
# Requires FACTORY_ADDRESS and USDC_ADDRESS env vars
forge script script/DeployEventContract.s.sol \\
  --rpc-url mainnet \\
  --broadcast \\
  --verify \\
  -vvvv
```

## Helper Functions for Frontend

```typescript
// Get all events
async function getAllEvents(factoryAddress: string) {
  const factory = new ethers.Contract(factoryAddress, FactoryABI, provider);
  const eventAddresses = await factory.getAllEventContracts();
  
  return Promise.all(
    eventAddresses.map(async (addr, index) => {
      const event = new ethers.Contract(addr, EventABI, provider);
      const details = await event.getEventDetails();
      return { eventId: index, address: addr, details };
    })
  );
}

// Buy tickets for an event
async function buyTickets(factoryAddress: string, eventId: number, ticketIds: number[], quantities: number[]) {
  const factory = new ethers.Contract(factoryAddress, FactoryABI, provider);
  const eventAddress = await factory.getEventContract(eventId);
  
  const event = new ethers.Contract(eventAddress, EventABI, signer);
  const tx = await event.buyTickets(ticketIds, quantities, await signer.getAddress());
  return tx.wait();
}
```

## Contract Addresses

After deployment, update these:

### Mainnet
- **TicketOfficeFactory**: `<TO_BE_DEPLOYED>`
- **USDC**: `0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48`

### Sepolia
- **TicketOfficeFactory**: `<TO_BE_DEPLOYED>`  
- **USDC**: `0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238`

## Troubleshooting

**Q: Event not found in factory?**  
A: Make sure to call `factory.registerEvent()` after deploying EventContract

**Q: Factory says office closed?**  
A: Call `factory.toggleOffice()` as owner to open it

**Q: Can't buy tickets?**  
A: Check USDC approval for the EventContract address (not factory)

**Q: How to migrate existing events?**  
A: Deploy new EventContract with same details, don't register old events in new factory
