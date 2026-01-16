# Contract Size Optimization Guide

## 🚨 Current Status
- **Contract:** TicketOffice.sol
- **Current Size:** 28,197 bytes
- **Size Limit:** 24,576 bytes (EIP-170)
- **Excess:** 3,621 bytes (14.7% over limit)
- **Status:** ❌ Cannot deploy to mainnet

## ✅ Optimizations Already Applied
- [x] Removed unused imports (`IERC1155`)
- [x] Optimized modifier logic (moved to internal functions)
- [x] Fixed variable naming conventions (`baseURL` → `baseUri`)
- [x] Created library structure foundation
- [x] **Result:** Reduced from 28,568 → 28,197 bytes (371 bytes saved)

## 🎯 Strategies to Reduce Contract Size

### Option 1: Factory Pattern (Recommended)
**Effort:** Medium | **Risk:** Low | **Savings:** ~8,000+ bytes

Split the monolithic contract into specialized contracts:

```
TicketFactory.sol (~15,000 bytes)
├── Event creation and management
├── Payment processing
└── Admin functions

TicketNFT.sol (~6,000 bytes) [Per Event]
├── ERC1155 implementation
├── Minting logic
└── Transfer restrictions
```

**Steps:**
1. Create `TicketFactory.sol` with core business logic
2. Move ERC1155 functionality to separate contract template
3. Factory creates new TicketNFT contracts per event
4. Update deployment scripts
5. Modify frontend to interact with factory pattern

**Pros:** 
- Maintains all functionality
- Easy to upgrade individual components
- Clean separation of concerns

**Cons:**
- More complex deployment
- Multiple contract addresses to manage

### Option 2: Proxy + Multiple Implementations
**Effort:** High | **Risk:** Medium | **Savings:** ~10,000+ bytes

Use UUPS proxy pattern with specialized implementation contracts:

```
TicketOfficeProxy.sol
├── Routes calls to appropriate implementation
├── Stores all state variables
└── Upgrade mechanism

TicketOfficeCore.sol (~12,000 bytes)
├── Event creation
├── Basic getters
└── Admin functions

TicketOfficeSales.sol (~12,000 bytes)
├── Ticket purchasing
├── Payment processing
└── Refund logic

TicketOfficeAdvanced.sol (~8,000 bytes)
├── Comp tickets
├── Complex queries
└── Reporting functions
```

**Steps:**
1. Install OpenZeppelin upgradeable contracts
2. Create proxy contract with state variables
3. Split logic across multiple implementation contracts
4. Implement delegatecall routing logic
5. Add upgrade mechanisms
6. Deploy proxy + implementations

**Pros:**
- Single contract address for users
- Fully upgradeable
- Can add features without redeployment

**Cons:**
- Complex architecture
- Higher gas costs for some operations
- Requires careful storage layout management

### Option 3: Feature Reduction (Quick Fix)
**Effort:** Low | **Risk:** Medium | **Savings:** ~4,000+ bytes

Remove or simplify non-essential features:

**Candidates for Removal:**
- [ ] Complex comp ticket system (`compMany`, `compOne`)
- [ ] Advanced getter functions (combine similar ones)
- [ ] Detailed event metadata (simplify to essential fields)
- [ ] Multiple treasurer approval system
- [ ] Redundant validation checks

**Steps:**
1. Identify functions used <5% of the time
2. Remove or combine getter functions
3. Simplify data structures
4. Remove redundant require statements
5. Consolidate similar functions

**Pros:**
- Quick implementation
- Maintains core business logic
- Easy to test

**Cons:**
- Loss of functionality
- May need to add features back later
- Could impact user experience

### Option 4: Library Extraction
**Effort:** Medium | **Risk:** Low | **Savings:** ~2,000-5,000 bytes

Move complex logic to external libraries:

```solidity
// TicketValidationLib.sol
library TicketValidation {
    function validatePurchase(...) external pure returns (bool) {}
    function calculateTotalCost(...) external pure returns (uint256) {}
}

// PaymentLib.sol  
library PaymentProcessor {
    function processPayment(...) external {}
    function issueRefund(...) external {}
}

// EventLib.sol
library EventManager {
    function createEvent(...) external {}
    function validateEventData(...) external pure returns (bool) {}
}
```

**Steps:**
1. Identify stateless functions that can be moved to libraries
2. Create focused libraries for different concerns
3. Update main contract to use library calls
4. Deploy libraries first, then main contract
5. Update build scripts for library linking

**Pros:**
- Reusable across multiple contracts
- Cleaner main contract
- Gas-efficient for complex logic

**Cons:**
- Additional deployment complexity
- Library linking required
- Libraries cannot be upgraded

### Option 5: Data Structure Optimization
**Effort:** Low | **Risk:** Low | **Savings:** ~1,000-2,000 bytes

Optimize storage and reduce redundancy:

**Current Issues:**
```solidity
// Redundant storage
mapping(uint256 => TicketStructs.Ticketdetails) public eventDetails;
mapping(uint256 => address) public eventTicketAddress;
mapping(uint256 => address) public withdrawlApproval;

// Can be combined into single struct
struct EventData {
    TicketStructs.Ticketdetails details;
    address ticketAddress;
    address treasurer;
    uint256 balance;
    bool locked;
}
mapping(uint256 => EventData) public events;
```

**Steps:**
1. Combine related mappings into structs
2. Use packed structs where possible
3. Remove redundant data storage
4. Use events for historical data instead of storage
5. Implement view functions for backward compatibility

## 🔧 Implementation Priority

### Phase 1: Quick Wins (1-2 hours)
1. **Data Structure Optimization** - Combine mappings, pack structs
2. **Remove unused functions** - Delete functions with 0% usage
3. **Simplify validation** - Remove redundant require statements

**Expected Savings:** ~2,000 bytes

### Phase 2: Architecture Change (1-2 days)
Choose ONE of:
- **Factory Pattern** (Recommended for most cases)
- **Feature Reduction** (If timeline is critical)
- **Library Extraction** (If planning multiple similar contracts)

**Expected Savings:** ~4,000-8,000 bytes

### Phase 3: Advanced Optimization (3-5 days)
- **Proxy Pattern** (If upgradeability is critical)
- **Custom assembly optimizations**
- **Gas-optimized function ordering**

**Expected Savings:** ~6,000+ bytes

## 📋 Testing Checklist

After each optimization:
- [ ] Run `forge build --sizes` to verify size reduction
- [ ] Run `forge test --fork-url $MAINNET_RPC_URL` to ensure functionality
- [ ] Test critical paths: event creation, ticket purchasing, refunds
- [ ] Verify gas costs haven't increased significantly
- [ ] Check compatibility with existing frontend integration

## 🚀 Deployment Strategy

### Mainnet Deployment Options:
1. **Direct Deploy** - After reaching <24,576 bytes
2. **Create2 Deployment** - For deterministic addresses
3. **Proxy Deployment** - If using upgradeable pattern

### Alternative Networks:
- **Polygon** - 128KB limit (no size issues)
- **Arbitrum** - 128KB limit (no size issues)  
- **Base** - 128KB limit (no size issues)
- **Optimism** - 128KB limit (no size issues)

## 💡 Quick Commands

```bash
# Check current contract size
forge build --sizes

# Test after changes
forge test --fork-url https://eth-mainnet.g.alchemy.com/v2/uB0e37C17l2v_Jp8ESmS1rsIyckC-LaI -vv

# Deploy to testnet
forge script script/TicketOffice.s.sol --rpc-url sepolia --broadcast --verify

# Size analysis with specific contract
forge build src/TicketOffice.sol --sizes
```

## 🎯 Recommended Approach

**For immediate deployment:** Start with **Option 3 (Feature Reduction)** to get under the limit quickly, then implement **Option 1 (Factory Pattern)** for the production version.

**For long-term solution:** Go directly with **Option 1 (Factory Pattern)** as it provides the best balance of functionality, maintainability, and gas efficiency.

---

*Last updated: January 15, 2026*
*Current test status: ✅ 50/50 tests passing*
*Deployment status: ❌ Size limit exceeded*