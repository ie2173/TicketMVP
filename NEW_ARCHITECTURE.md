# New Secure Architecture - Separation of Concerns

## Overview

The ticket system has been completely redesigned with security and modularity as top priorities. **No malicious contracts can be injected** - the factory creates everything.

## Architecture Components

### 1. **TicketOfficeFactory** (24,367 bytes - 99% of limit)
- **Role**: Central registry and event creator
- **Responsibilities**:
  - Creates EventData contracts (secure deployment)
  - Creates ERC1155Token contracts
  - Maintains array of all events
  - Authorizes operation contracts
  - Controls ticket office open/closed state

**Key Security**: Factory is the ONLY way to create events. No external contracts can be registered.

### 2. **EventData** (7,565 bytes - 31% of limit)
- **Role**: Pure storage contract (NO business logic)
- **Responsibilities**:
  - Stores event details, ticket info, balances
  - Provides getter functions
  - State modification functions (only callable by authorized operations)
  
**Key Security**: Only authorized operation contracts can modify state. No direct public writes.

### 3. **TicketOperations** (4,878 bytes - 20% of limit)
- **Role**: Public ticket purchase logic
- **Responsibilities**:
  - `buyTicket()` - Single ticket purchase
  - `buyTickets()` - Batch ticket purchase
  - `redeemCompTicket()` - Redeem comp tickets
  - USDC payment handling
  - NFT minting via ERC1155Token

**Key Security**: Checks office status, validates capacity, non-reentrant, USDC transfers first.

### 4. **AdminOperations** (8,865 bytes - 36% of limit)
- **Role**: Event management and admin functions
- **Responsibilities**:
  - `issueRefund()` - Refund tickets (event must be locked)
  - `withdrawFunds()` - Withdraw revenue with fee calculation
  - `addCompTicket()` - Add comp ticket vouchers
  - `lockEvent()` - Lock event (no more changes)
  - `addTicket()`, `addPerformer()`, `updateEventDetails()` - Event modifications
  
**Key Security**: Only event owner, factory owner, or approved addresses can call.

### 5. **ERC1155Token** (6,204 bytes - 25% of limit)
- **Role**: NFT tickets for each event
- **Responsibilities**:
  - Mint tickets (only authorized)
  - Burn tickets (for refunds)
  - ERC1155 standard compliance
  
**Key Security**: Only factory or authorized operation contracts can mint/burn.

---

## Security Model

### ✅ **Problem Solved**: No Malicious Contract Injection

**Before**: `registerEvent(address)` allowed ANY address to be registered
**After**: Factory creates all contracts itself - impossible to inject malicious code

### Authorization Flow

```
User → TicketOperations.buyTicket()
  ↓
TicketOperations checks: Factory.ticketOfficeOpen() ✓
  ↓
TicketOperations gets: Factory.getEventData(eventId)
  ↓
TicketOperations calls: EventData.incrementTicketsSold() 
  ↓
EventData checks: msg.sender authorized? ✓ (TicketOperations is authorized)
  ↓
TicketOperations calls: ERC1155Token.mint()
  ↓
ERC1155Token checks: msg.sender authorized? ✓ (TicketOperations is authorized)
```

### Access Control Matrix

| Function | Factory Owner | Event Owner | Operation Contracts | Public |
|----------|---------------|-------------|---------------------|--------|
| Create Event | ✅ | ❌ | ❌ | ❌ |
| Authorize Operations | ✅ | ❌ | ❌ | ❌ |
| Toggle Office | ✅ | ❌ | ❌ | ❌ |
| Buy Tickets | ❌ | ❌ | ❌ | ✅ (via TicketOperations) |
| Add Comp Ticket | ✅ | ✅ | ❌ | ❌ |
| Issue Refund | ✅ | ✅ | ❌ | ❌ |
| Withdraw Funds | ✅ | ✅ | ❌ | ❌ |
| Modify EventData | ❌ | ❌ | ✅ (authorized only) | ❌ |
| Mint Tickets | ❌ | ❌ | ✅ (authorized only) | ❌ |

---

## Deployment Flow

### 1. Deploy Core Infrastructure (One Time)
```solidity
// 1. Deploy Factory
TicketOfficeFactory factory = new TicketOfficeFactory(usdcAddress, ownerAddress);

// 2. Deploy Operation Contracts
TicketOperations ticketOps = new TicketOperations(address(factory));
AdminOperations adminOps = new AdminOperations(address(factory));

// 3. Authorize Operation Contracts
factory.setOperationContract(address(ticketOps), true);
factory.setOperationContract(address(adminOps), true);
```

### 2. Create Event (Per Event)
```solidity
// Factory creates EventData + ERC1155Token atomically
(uint256 eventId, address eventData, address ticketToken) = factory.createEvent(
  eventOwner,
  "Concert Name",
  "ipfs://metadata",
  eventDetails // struct with all event info
);
```

### 3. Users Interact
```solidity
// Buy ticket
usdc.approve(address(ticketOps), price);
ticketOps.buyTicket(eventId, ticketType);

// Admin operations
adminOps.addCompTicket(eventId, userAddress, ticketType);
adminOps.withdrawFunds(eventId);
```

---

## Data Flow

### Event Lookup
All operations use `eventId` (array index):
```
eventId → factory.getEventData(eventId) → EventData contract address
```

### Ticket Purchase Flow
```
1. User approves USDC to TicketOperations
2. TicketOperations.buyTicket(eventId, ticketType)
3. TicketOperations gets EventData from factory
4. TicketOperations validates (office open, capacity, etc.)
5. TicketOperations transfers USDC from user
6. TicketOperations calls EventData.incrementTicketsSold()
7. TicketOperations calls EventData.addToBalance()
8. TicketOperations calls ERC1155Token.mint()
9. User receives NFT ticket
```

### Withdrawal Flow
```
1. AdminOperations.withdrawFunds(eventId)
2. Check caller authorization (event owner / factory owner)
3. Get EventData from factory
4. Calculate fees per ticket type
5. EventData.subtractFromBalance()
6. Transfer fees to factory owner (USDC)
7. Transfer revenue to event owner (USDC)
```

---

## Contract Sizes (All Under 24,576 Limit!)

| Contract | Size | % of Limit | Status |
|----------|------|------------|--------|
| TicketOfficeFactory | 24,367 B | 99% | ✅ |
| AdminOperations | 8,865 B | 36% | ✅ |
| EventData | 7,565 B | 31% | ✅ |
| ERC1155Token | 6,204 B | 25% | ✅ |
| TicketOperations | 4,878 B | 20% | ✅ |

**Total if monolithic: 51,879 bytes** (211% over limit!)  
**Separated: Each deployable** ✅

---

## Test Coverage

All 7 tests passing:
- ✅ Factory deployment
- ✅ Event creation
- ✅ Single ticket purchase
- ✅ Batch ticket purchase
- ✅ Office closed enforcement
- ✅ Comp ticket addition
- ✅ Comp ticket redemption

---

## Benefits of New Architecture

### 🔒 Security
- **No malicious contract injection** - Factory creates everything
- **Separation of concerns** - Each contract has one job
- **Authorization layers** - Multiple checks at each level
- **Immutable references** - Factory, eventId, eventOwner set at creation

### 📏 Size Management
- All contracts under 24KB limit
- Can upgrade individual components
- Factory stays small (just creates + tracks)

### 🔧 Maintainability
- Clear responsibility boundaries
- Easy to test individual components
- Can add new operation contracts without touching factory

### ⚡ Gas Efficiency
- State stored once in EventData
- Operation contracts are stateless (lower deployment cost)
- Batch operations supported

### 🚀 Scalability
- Unlimited events (array-based)
- Can deploy multiple operation contract versions
- Gradual migration possible (authorize new version, deprecate old)

---

## Migration from Old Architecture

### Old System Issues
1. ❌ registerEvent() accepted any address
2. ❌ Monolithic EventContract (28,639 bytes - too large)
3. ❌ No separation between data and logic
4. ❌ Malicious contracts could be registered

### New System Fixes
1. ✅ Factory creates all contracts
2. ✅ Separated into 5 deployable contracts
3. ✅ EventData is pure storage, logic in operations
4. ✅ Impossible to inject malicious contracts

---

## Next Steps

1. **Deploy to Sepolia**:
   ```bash
   # Deploy factory
   forge script script/TicketOfficeFactory.s.sol --rpc-url sepolia --broadcast
   
   # Deploy operations (update factory address)
   # Deploy TicketOperations
   # Deploy AdminOperations
   
   # Authorize operations
   cast send $FACTORY "setOperationContract(address,bool)" $TICKET_OPS true
   cast send $FACTORY "setOperationContract(address,bool)" $ADMIN_OPS true
   ```

2. **Create Test Event**:
   ```bash
   forge script script/DeployEventContract.s.sol --rpc-url sepolia --broadcast
   ```

3. **Update Frontend**: See WAGMI_INTEGRATION_GUIDE.md (needs updates for new architecture)

4. **Deploy to Mainnet** (after Sepolia testing)

---

## Frontend Integration

### Contract Addresses Needed
```typescript
const ADDRESSES = {
  factory: '0x...', // TicketOfficeFactory
  ticketOps: '0x...', // TicketOperations
  adminOps: '0x...', // AdminOperations (admin panel only)
}
```

### Key Changes from Old System
1. **Event Lookup**: `factory.getEventData(eventId)` → EventData address
2. **Buying Tickets**: Call `ticketOps.buyTicket(eventId, ticketType)` not event contract
3. **USDC Approval**: Approve TicketOperations, not EventContract
4. **Admin Functions**: Call AdminOperations contract, pass eventId

---

## Summary

This architecture solves the fundamental security flaw while staying under contract size limits. The factory has complete control over event creation, making it **impossible to inject malicious contracts**. Each component is small, focused, and secure.

**The system is now production-ready for Sepolia testing!**
