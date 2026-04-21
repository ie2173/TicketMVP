# Test Coverage Summary

## Overview

Comprehensive test coverage for the new Factory + EventContract architecture with **25 passing tests**.

## Test Files

### 1. TicketOfficeFactory.t.sol (6 tests)

**Basic Functionality:**
- ✅ testFactoryDeployment - Verifies correct initialization
- ✅ testRegisterEvent - Tests event registration flow
- ✅ testToggleOffice - Tests opening/closing office
- ✅ testGetAllEventContracts - Tests batch event retrieval

**Access Control:**
- ✅ testOnlyOwnerCanToggleOffice - Non-owners cannot toggle
- ✅ testOnlyOwnerCanRegisterEvent - Non-owners cannot register

### 2. EventContract.t.sol (19 tests)

**Core Ticket Purchase:**
- ✅ testBuyTicket - Single ticket purchase
- ✅ testBuyMultipleTickets - Batch ticket purchase
- ✅ testCannotBuyWhenOfficeClosed - Respects office status
- ✅ testCannotExceedCapacity - Enforces capacity limits

**Comp Tickets:**
- ✅ testAddCompTicket - Admin can add free vouchers
- ✅ testRedeemCompTicket - Users can redeem vouchers

**Refunds:**
- ✅ testIssueRefund - Successful refund when locked
- ✅ testCannotRefundIfNotLocked - Prevents premature refunds

**Admin Functions:**
- ✅ testAddTicket - Add new ticket types
- ✅ testAddPerformer - Add performers to event
- ✅ testUpdateEventDetails - Update event information
- ✅ testCannotUpdateAfterLocked - Prevents updates after lock
- ✅ testWithdrawFunds - Successful withdrawal after event
- ✅ testCannotWithdrawBeforeEvent - Prevents early withdrawal

**View Functions:**
- ✅ testEventContractDeployment - Verify initialization
- ✅ testGetEventDetails - Retrieve event information
- ✅ testViewFunctions - Test all getter functions

**Access Control:**
- ✅ testOnlyAdminFunctions - Only admins can manage
- ✅ testOnlyFactoryOwnerFunctions - Only factory owner can lock/burn

## Test Results

```
Ran 2 test suites: 25 tests passed, 0 failed, 0 skipped
```

## Coverage Areas

### ✅ Fully Covered
- Event registration and retrieval
- Ticket purchasing (single and batch)
- Comp ticket system
- Refund mechanism
- Admin operations (add tickets, performers, update details)
- Fund withdrawal with fee distribution
- Access control (admin vs owner vs user)
- View functions (all getters)
- Event locking
- Office open/close functionality

### ⚠️ Not Yet Covered (Future Work)
- Integration with frontend wallet connections
- Gas optimization benchmarks
- Event creation via script (covered in DeployEventContract.s.sol)
- Multiple concurrent events
- Edge cases with decimal precision
- Real mainnet fork testing

## Running Tests

```bash
# Run all tests
forge test

# Run specific test file
forge test --match-contract TicketOfficeFactoryTest
forge test --match-contract EventContractTest

# Run with verbose output
forge test -vv

# Run with gas reporting
forge test --gas-report

# Run specific test
forge test --match-test testBuyTicket
```

## Test Helper: MockERC20

The tests use a simple MockERC20 contract to simulate USDC without needing mainnet fork:

```solidity
contract MockERC20 {
  mapping(address => uint256) public balanceOf;
  mapping(address => mapping(address => uint256)) public allowance;
  
  function approve(address spender, uint256 amount) external returns (bool);
  function transfer(address to, uint256 amount) external returns (bool);
  function transferFrom(address from, address to, uint256 amount) external returns (bool);
  function mint(address to, uint256 amount) external;
}
```

## Next Steps for Testing

1. **Mainnet Fork Tests**: Test with real USDC on forked mainnet
2. **Integration Tests**: Test factory + multiple events together
3. **Gas Benchmarks**: Compare gas costs vs old architecture
4. **Frontend Integration Tests**: E2E testing with actual wallet
5. **Stress Tests**: Large batch purchases, high capacity events

## Notes

- All tests pass with Solidity 0.8.20
- Tests use Foundry's vm.prank for access control testing
- MockERC20 simplifies testing without external dependencies
- Tests cover both success and failure scenarios
- Access control thoroughly tested for security
