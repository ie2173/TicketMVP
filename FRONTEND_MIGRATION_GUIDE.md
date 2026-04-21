# Frontend Migration Guide: Factory + EventContract Architecture

## Overview

This guide walks you through migrating your frontend from the monolithic TicketOffice contract to the new Factory + EventContract architecture.

## Table of Contents

1. [Key Changes](#key-changes)
2. [Contract ABIs](#contract-abis)
3. [Setup & Configuration](#setup--configuration)
4. [Common Patterns](#common-patterns)
5. [Migration Examples](#migration-examples)
6. [Helper Functions](#helper-functions)
7. [Testing Checklist](#testing-checklist)

---

## Key Changes

### Old Architecture (Single Contract)
```
TicketOffice (27KB - Failed to Deploy)
├── All events stored in one contract
├── eventDetails[eventId] mapping
├── buyTickets(eventId, ...)
└── getEventDetails(eventId)
```

### New Architecture (Factory + Events)
```
TicketOfficeFactory (1.1KB)
├── eventContracts[eventId] → EventContract address
├── nextEventId counter
└── ticketOfficeOpen flag

EventContract (16.8KB per event)
├── Event-specific storage
├── buyTickets(...)  // No eventId needed!
├── getEventDetails()
└── ERC1155Token instance
```

---

## Contract ABIs

### TicketOfficeFactory ABI (Minimal)

```typescript
const FACTORY_ABI = [
  // Read functions
  "function getEventContract(uint256 eventId) view returns (address)",
  "function getAllEventContracts() view returns (address[])",
  "function nextEventId() view returns (uint256)",
  "function ticketOfficeOpen() view returns (bool)",
  "function owner() view returns (address)",
  
  // Write functions
  "function registerEvent(address eventContract, address eventOwner) returns (uint256)",
  "function toggleOffice()",
  
  // Events
  "event EventCreated(uint256 indexed eventId, address indexed eventContract, address indexed eventOwner)"
];
```

### EventContract ABI

```typescript
const EVENT_ABI = [
  // Purchase functions
  "function buyTicket(uint256 ticketId, uint256 quantity, address buyer)",
  "function buyTickets(uint256[] memory ticketIds, uint256[] memory quantities, address buyer)",
  "function redeemCompTicket(uint256 ticketId)",
  
  // Refund
  "function issueRefund()",
  
  // View functions
  "function getEventDetails() view returns (tuple(string name, address owner, uint256 eventDate, tuple(string[] ticketNames, uint256[] ticketCapacities, uint256[] ticketPrices, uint256[] ticketsSold, uint256[] feePercentages) ticketInformation, tuple(string concertLocation, string venueName) locationDetails, string[] performers, string[] keywords, string[] categories, string eventDescription, string eventType))",
  "function getEventName() view returns (string)",
  "function getEventDate() view returns (uint256)",
  "function getTicketNames() view returns (string[])",
  "function getTicketPrices() view returns (uint256[])",
  "function getTicketPrice(uint256 ticketId) view returns (uint256)",
  "function getTicketCapacities() view returns (uint256[])",
  "function getTicketsSold() view returns (uint256[])",
  "function getEventBalance() view returns (uint256)",
  "function getTicketTokenAddress() view returns (address)",
  "function isLocked() view returns (bool)",
  "function isEventOwner(address user) view returns (bool)",
  "function isTicketHolder(address user, uint256 ticketId) view returns (bool)",
  "function eventOwner() view returns (address)",
  "function factory() view returns (address)",
  
  // Admin functions
  "function addTicket(string memory ticketName, uint256 ticketPrice, uint256 ticketCapacity, uint256 feePercentage)",
  "function addPerformer(string memory performer)",
  "function addCompTicket(uint256 ticketId, uint256 quantity, address[] memory addresses)",
  "function updateEventDetails(tuple(...) details)",
  "function withdrawFunds()",
  "function lockEvent()",
  "function grantWithdrawalApproval(address user)"
];
```

---

## Setup & Configuration

### Environment Variables

```typescript
// .env
VITE_FACTORY_ADDRESS_MAINNET=0x... // Your deployed factory
VITE_FACTORY_ADDRESS_SEPOLIA=0x...
VITE_USDC_ADDRESS_MAINNET=0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
VITE_USDC_ADDRESS_SEPOLIA=0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238
```

### Contract Instances

```typescript
import { ethers } from 'ethers';

// Setup provider
const provider = new ethers.providers.Web3Provider(window.ethereum);
const signer = provider.getSigner();

// Factory instance
const factoryAddress = import.meta.env.VITE_FACTORY_ADDRESS_MAINNET;
const factory = new ethers.Contract(factoryAddress, FACTORY_ABI, signer);

// Get EventContract instance
async function getEventContract(eventId: number) {
  const eventAddress = await factory.getEventContract(eventId);
  return new ethers.Contract(eventAddress, EVENT_ABI, signer);
}
```

---

## Common Patterns

### Pattern 1: Get Event Contract Address

**Old:**
```typescript
// Event data was in main contract
const eventDetails = await ticketOffice.getEventDetails(eventId);
```

**New:**
```typescript
// Step 1: Get event contract address
const eventAddress = await factory.getEventContract(eventId);

// Step 2: Create event contract instance
const eventContract = new ethers.Contract(eventAddress, EVENT_ABI, signer);

// Step 3: Get event data
const eventDetails = await eventContract.getEventDetails();
```

### Pattern 2: Buy Tickets

**Old:**
```typescript
async function buyTickets(eventId: number, ticketIds: number[], quantities: number[]) {
  // Approve USDC
  const totalCost = calculateTotalCost(ticketIds, quantities);
  await usdc.approve(TICKET_OFFICE_ADDRESS, totalCost);
  
  // Buy tickets
  const tx = await ticketOffice.buyTickets(eventId, ticketIds, quantities);
  await tx.wait();
}
```

**New:**
```typescript
async function buyTickets(eventId: number, ticketIds: number[], quantities: number[]) {
  // Get event contract
  const eventAddress = await factory.getEventContract(eventId);
  const eventContract = new ethers.Contract(eventAddress, EVENT_ABI, signer);
  
  // Approve USDC for THIS event contract
  const totalCost = await calculateTotalCost(eventContract, ticketIds, quantities);
  await usdc.approve(eventAddress, totalCost); // Note: eventAddress, not factory!
  
  // Buy tickets (no eventId parameter!)
  const buyerAddress = await signer.getAddress();
  const tx = await eventContract.buyTickets(ticketIds, quantities, buyerAddress);
  await tx.wait();
}
```

### Pattern 3: Create Event (Admin)

**Old:**
```typescript
async function createEvent(eventDetails, ticketDetails, tokenUri) {
  const tx = await ticketOffice.createEvent(eventDetails, ticketDetails, tokenUri);
  const receipt = await tx.wait();
  
  // Parse Event emission for eventId
  const eventId = parseEventId(receipt);
  return eventId;
}
```

**New:**
```typescript
async function createEvent(eventDetails, tokenUri) {
  // Deploy EventContract
  const EventContractFactory = new ethers.ContractFactory(
    EVENT_ABI,
    EVENT_BYTECODE,
    signer
  );
  
  const factoryAddress = await factory.address;
  const usdcAddress = import.meta.env.VITE_USDC_ADDRESS_MAINNET;
  
  const eventContract = await EventContractFactory.deploy(
    factoryAddress,
    eventDetails.owner,
    usdcAddress,
    eventDetails.name,
    tokenUri,
    eventDetails
  );
  await eventContract.deployed();
  
  // Register with factory
  const tx = await factory.registerEvent(
    eventContract.address,
    eventDetails.owner
  );
  const receipt = await tx.wait();
  
  // Parse EventCreated event
  const event = receipt.events?.find(e => e.event === 'EventCreated');
  const eventId = event?.args?.eventId;
  
  return { eventId, eventAddress: eventContract.address };
}
```

---

## Migration Examples

### Example 1: Event List Page

**Old Implementation:**
```typescript
// EventListPage.tsx
async function loadEvents() {
  const nextEventId = await ticketOffice.nextEventId();
  const events = [];
  
  for (let i = 0; i < nextEventId; i++) {
    const details = await ticketOffice.getEventDetails(i);
    const eventAddress = await ticketOffice.getAddress(i);
    events.push({
      eventId: i,
      name: details.name,
      date: details.eventDate,
      address: eventAddress
    });
  }
  
  return events;
}
```

**New Implementation:**
```typescript
// EventListPage.tsx
async function loadEvents() {
  // Get all event contract addresses
  const eventAddresses = await factory.getAllEventContracts();
  
  // Load details for each event
  const events = await Promise.all(
    eventAddresses.map(async (address, eventId) => {
      const eventContract = new ethers.Contract(address, EVENT_ABI, provider);
      const details = await eventContract.getEventDetails();
      
      return {
        eventId,
        name: details.name,
        date: details.eventDate.toNumber(),
        address,
        eventContract
      };
    })
  );
  
  return events;
}
```

### Example 2: Event Detail Page

**Old Implementation:**
```typescript
// EventDetailPage.tsx
function EventDetailPage({ eventId }) {
  const [eventData, setEventData] = useState(null);
  
  useEffect(() => {
    async function load() {
      const details = await ticketOffice.getEventDetails(eventId);
      const ticketNames = await ticketOffice.getTicketNames(eventId);
      const ticketPrices = await ticketOffice.getTicketPrices(eventId);
      const capacities = await ticketOffice.getEventCapacities(eventId);
      const soldCounts = await ticketOffice.getTicketsSold(eventId);
      
      setEventData({
        details,
        ticketNames,
        ticketPrices,
        capacities,
        soldCounts
      });
    }
    load();
  }, [eventId]);
  
  return <div>...</div>;
}
```

**New Implementation:**
```typescript
// EventDetailPage.tsx
function EventDetailPage({ eventId }) {
  const [eventData, setEventData] = useState(null);
  const [eventContract, setEventContract] = useState(null);
  
  useEffect(() => {
    async function load() {
      // Get event contract
      const eventAddress = await factory.getEventContract(eventId);
      const contract = new ethers.Contract(eventAddress, EVENT_ABI, provider);
      setEventContract(contract);
      
      // Load all data (no eventId parameters!)
      const [details, ticketNames, ticketPrices, capacities, soldCounts] = 
        await Promise.all([
          contract.getEventDetails(),
          contract.getTicketNames(),
          contract.getTicketPrices(),
          contract.getTicketCapacities(),
          contract.getTicketsSold()
        ]);
      
      setEventData({
        address: eventAddress,
        details,
        ticketNames,
        ticketPrices,
        capacities,
        soldCounts
      });
    }
    load();
  }, [eventId]);
  
  return <div>...</div>;
}
```

### Example 3: Purchase Flow

**Old Implementation:**
```typescript
// PurchaseButton.tsx
async function handlePurchase(eventId, ticketId, quantity) {
  try {
    // Calculate cost
    const price = await ticketOffice.getTicketPrice(eventId, ticketId);
    const cost = price.mul(quantity);
    
    // Approve USDC
    const approveTx = await usdc.approve(TICKET_OFFICE_ADDRESS, cost);
    await approveTx.wait();
    
    // Buy ticket
    const buyTx = await ticketOffice.mintSingleTicket(
      eventId,
      quantity,
      ticketId,
      userAddress
    );
    await buyTx.wait();
    
    toast.success('Tickets purchased!');
  } catch (error) {
    toast.error('Purchase failed');
  }
}
```

**New Implementation:**
```typescript
// PurchaseButton.tsx
async function handlePurchase(eventId, ticketId, quantity) {
  try {
    // Get event contract
    const eventAddress = await factory.getEventContract(eventId);
    const eventContract = new ethers.Contract(eventAddress, EVENT_ABI, signer);
    
    // Calculate cost
    const price = await eventContract.getTicketPrice(ticketId);
    const cost = price.mul(quantity);
    
    // Approve USDC for EVENT CONTRACT (not factory!)
    const approveTx = await usdc.approve(eventAddress, cost);
    await approveTx.wait();
    
    // Buy ticket (no eventId parameter!)
    const userAddress = await signer.getAddress();
    const buyTx = await eventContract.buyTicket(ticketId, quantity, userAddress);
    await buyTx.wait();
    
    toast.success('Tickets purchased!');
  } catch (error) {
    toast.error('Purchase failed');
  }
}
```

---

## Helper Functions

### Reusable Utility Functions

```typescript
// lib/contractHelpers.ts

import { ethers } from 'ethers';

/**
 * Get EventContract instance for a specific event
 */
export async function getEventContract(
  factory: ethers.Contract,
  eventId: number,
  signerOrProvider: ethers.Signer | ethers.providers.Provider
): Promise<ethers.Contract> {
  const eventAddress = await factory.getEventContract(eventId);
  return new ethers.Contract(eventAddress, EVENT_ABI, signerOrProvider);
}

/**
 * Get all events with their basic info
 */
export async function getAllEvents(
  factory: ethers.Contract,
  provider: ethers.providers.Provider
): Promise<EventInfo[]> {
  const eventAddresses = await factory.getAllEventContracts();
  
  return Promise.all(
    eventAddresses.map(async (address, eventId) => {
      const eventContract = new ethers.Contract(address, EVENT_ABI, provider);
      const [name, date, owner, isLocked] = await Promise.all([
        eventContract.getEventName(),
        eventContract.getEventDate(),
        eventContract.eventOwner(),
        eventContract.isLocked()
      ]);
      
      return {
        eventId,
        address,
        name,
        date: date.toNumber(),
        owner,
        isLocked
      };
    })
  );
}

/**
 * Calculate total cost for ticket purchase
 */
export async function calculateTicketCost(
  eventContract: ethers.Contract,
  ticketIds: number[],
  quantities: number[]
): Promise<ethers.BigNumber> {
  const prices = await eventContract.getTicketPrices();
  
  let total = ethers.BigNumber.from(0);
  for (let i = 0; i < ticketIds.length; i++) {
    const price = prices[ticketIds[i]];
    const cost = price.mul(quantities[i]);
    total = total.add(cost);
  }
  
  return total;
}

/**
 * Check if user owns tickets to an event
 */
export async function getUserTickets(
  eventContract: ethers.Contract,
  userAddress: string
): Promise<TicketBalance[]> {
  const ticketTokenAddress = await eventContract.getTicketTokenAddress();
  const ticketToken = new ethers.Contract(
    ticketTokenAddress,
    ERC1155_ABI,
    eventContract.provider
  );
  
  const ticketNames = await eventContract.getTicketNames();
  
  const balances = await Promise.all(
    ticketNames.map(async (name, ticketId) => {
      const balance = await ticketToken.balanceOf(userAddress, ticketId);
      return {
        ticketId,
        name,
        balance: balance.toNumber()
      };
    })
  );
  
  return balances.filter(b => b.balance > 0);
}

/**
 * Get event contract from ticket token address
 */
export async function getEventFromTicketToken(
  factory: ethers.Contract,
  ticketTokenAddress: string,
  provider: ethers.providers.Provider
): Promise<{ eventId: number; eventContract: ethers.Contract } | null> {
  const eventAddresses = await factory.getAllEventContracts();
  
  for (let eventId = 0; eventId < eventAddresses.length; eventId++) {
    const eventContract = new ethers.Contract(
      eventAddresses[eventId],
      EVENT_ABI,
      provider
    );
    const tokenAddress = await eventContract.getTicketTokenAddress();
    
    if (tokenAddress.toLowerCase() === ticketTokenAddress.toLowerCase()) {
      return { eventId, eventContract };
    }
  }
  
  return null;
}
```

### React Hooks

```typescript
// hooks/useEventContract.ts

import { useEffect, useState } from 'react';
import { ethers } from 'ethers';

export function useEventContract(factoryContract: ethers.Contract, eventId: number) {
  const [eventContract, setEventContract] = useState<ethers.Contract | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);
  
  useEffect(() => {
    async function load() {
      try {
        setLoading(true);
        const address = await factoryContract.getEventContract(eventId);
        const contract = new ethers.Contract(address, EVENT_ABI, factoryContract.signer);
        setEventContract(contract);
      } catch (err) {
        setError(err as Error);
      } finally {
        setLoading(false);
      }
    }
    
    load();
  }, [factoryContract, eventId]);
  
  return { eventContract, loading, error };
}

// hooks/useEventDetails.ts

export function useEventDetails(eventContract: ethers.Contract | null) {
  const [details, setDetails] = useState(null);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    if (!eventContract) return;
    
    async function load() {
      try {
        setLoading(true);
        const data = await eventContract.getEventDetails();
        setDetails(data);
      } catch (error) {
        console.error('Failed to load event details:', error);
      } finally {
        setLoading(false);
      }
    }
    
    load();
  }, [eventContract]);
  
  return { details, loading };
}

// Usage in component:
function EventPage({ eventId }) {
  const { factoryContract } = useContracts();
  const { eventContract } = useEventContract(factoryContract, eventId);
  const { details } = useEventDetails(eventContract);
  
  if (!details) return <Loading />;
  
  return <div>{details.name}</div>;
}
```

---

## Testing Checklist

### Pre-Migration Testing
- [ ] Backup current frontend code
- [ ] Document all contract interactions in current app
- [ ] Test current app on testnet one final time
- [ ] Export any event data you need to preserve

### Migration Testing (Sepolia)
- [ ] Deploy Factory to Sepolia
- [ ] Create test event with EventContract
- [ ] Test: Load event list
- [ ] Test: View event details
- [ ] Test: Buy single ticket
- [ ] Test: Buy multiple tickets
- [ ] Test: Redeem comp ticket
- [ ] Test: Issue refund (locked event)
- [ ] Test: Admin functions (add ticket, update details)
- [ ] Test: Withdraw funds
- [ ] Test: View user tickets (wallet page)

### Production Testing (Mainnet)
- [ ] Deploy Factory to mainnet
- [ ] Create first production event
- [ ] Smoke test all user flows
- [ ] Monitor gas costs vs old implementation
- [ ] Set up analytics/monitoring
- [ ] Update documentation

### Edge Cases
- [ ] Test with office closed (should fail gracefully)
- [ ] Test purchasing when sold out
- [ ] Test with insufficient USDC balance
- [ ] Test with insufficient USDC approval
- [ ] Test refund for comp ticket holder (should fail)
- [ ] Test admin functions as non-admin (should revert)

---

## TypeScript Type Definitions

```typescript
// types/contracts.ts

export interface EventDetails {
  name: string;
  owner: string;
  eventDate: number;
  ticketInformation: {
    ticketNames: string[];
    ticketCapacities: number[];
    ticketPrices: BigNumber[];
    ticketsSold: number[];
    feePercentages: number[];
  };
  locationDetails: {
    concertLocation: string;
    venueName: string;
  };
  performers: string[];
  keywords: string[];
  categories: string[];
  eventDescription: string;
  eventType: string;
}

export interface EventInfo {
  eventId: number;
  address: string;
  name: string;
  date: number;
  owner: string;
  isLocked: boolean;
}

export interface TicketBalance {
  ticketId: number;
  name: string;
  balance: number;
}
```

---

## Troubleshooting

### Common Issues

**Issue: "Event not found"**
```typescript
// Solution: Check if event is registered
const nextEventId = await factory.nextEventId();
if (eventId >= nextEventId) {
  throw new Error('Event does not exist');
}
```

**Issue: "Transaction reverts with !O"**
```typescript
// Solution: Office is closed
const isOpen = await factory.ticketOfficeOpen();
if (!isOpen) {
  alert('Ticket office is currently closed');
  return;
}
```

**Issue: "USDC approval fails"**
```typescript
// Solution: Approve the EVENT CONTRACT, not factory
const eventAddress = await factory.getEventContract(eventId);
await usdc.approve(eventAddress, amount); // NOT factory.address!
```

**Issue: "Cannot read property of undefined"**
```typescript
// Solution: Wait for contract to load
const { eventContract, loading } = useEventContract(factory, eventId);
if (loading || !eventContract) {
  return <Loading />;
}
```

---

## Summary of Changes

| Operation | Old Pattern | New Pattern |
|-----------|-------------|-------------|
| **Get event data** | `ticketOffice.getEventDetails(eventId)` | `eventContract.getEventDetails()` |
| **Buy tickets** | `ticketOffice.buyTickets(eventId, ...)` | `eventContract.buyTickets(...)` |
| **USDC approval** | Approve `TICKET_OFFICE_ADDRESS` | Approve `eventAddress` |
| **Create event** | `ticketOffice.createEvent(...)` | Deploy `EventContract` + `factory.registerEvent(...)` |
| **Check capacity** | `ticketOffice.getEventCapacity(eventId, ticketId)` | `eventContract.getTicketCapacities()[ticketId]` |
| **Withdraw funds** | `ticketOffice.withdrawFunds(eventId)` | `eventContract.withdrawFunds()` |

---

## Need Help?

If you encounter issues during migration:

1. Check the test files for working examples
2. Review the FACTORY_DEPLOYMENT_GUIDE.md
3. Test on Sepolia first
4. Compare gas costs between old and new patterns

The new architecture is more modular and scalable - good luck with your migration! 🚀
