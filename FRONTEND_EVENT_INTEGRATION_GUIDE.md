# Frontend Event Integration Guide - New Architecture

## Overview
This guide covers implementing the optimized 5-contract architecture in your frontend application with maximum RPC efficiency.

## Architecture Summary

### Contracts
1. **TicketOfficeFactory** - Creates and tracks all events
2. **EventData** - Storage contract (one per event) - holds USDC
3. **ERC1155Token** - NFT tickets (one per event)
4. **TicketOperations** - Buy tickets
5. **AdminOperations** - Admin functions (refunds, withdrawals, comps)

### Key Optimization: Event-Based Data Loading
**All event display data is emitted in event logs** - No need for multiple RPC calls to display events!

---

## 1. Contract Addresses & ABIs

### Deployed Addresses (Sepolia)
```typescript
export const ADDRESSES = {
  factory: '0xe4426F8500d5f497E2cC0959eaf2B37b912E9711',
  ticketOperations: '0xcCe1e8e89263b4d8dA8751016Ec015140b7BcbFF',
  adminOperations: '0xAfD08843746743f978FD39071f2957AdF98487ed',
  usdc: '0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238'
};
```

**Etherscan Verified Contracts:**
- [Factory](https://sepolia.etherscan.io/address/0xe4426f8500d5f497e2cc0959eaf2b37b912e9711) - **Permissionless Event Creation!**
- [TicketOperations](https://sepolia.etherscan.io/address/0xcce1e8e89263b4d8da8751016ec015140b7bcbff)
- [AdminOperations](https://sepolia.etherscan.io/address/0xafd08843746743f978fd39071f2957adf98487ed)

### ABIs Location
Generate ABIs from compiled contracts:
```bash
forge build
# ABIs are in: out/<ContractName>.sol/<ContractName>.json
```

### TypeScript ABI Imports
```typescript
import FactoryABI from './abis/TicketOfficeFactory.json';
import EventDataABI from './abis/EventData.json';
import ERC1155TokenABI from './abis/ERC1155Token.json';
import TicketOperationsABI from './abis/TicketOperations.json';
import AdminOperationsABI from './abis/AdminOperations.json';
```

---

## 2. Event Display - Efficient Pattern

### The Key Event: `EventDetailsSet`
```solidity
event EventDetailsSet(
  uint256 indexed eventId,
  string eventName,
  string tokenURI,        // Your event image!
  string venueLocation,
  uint256 eventDate,
  uint256 ticketTypeCount
)
```

### One-Time Event Indexing (Load All Events)
```typescript
interface EventDisplayData {
  eventId: number;
  eventDataAddress: string;
  ticketTokenAddress: string;
  name: string;
  image: string;
  venue: string;
  date: Date;
  ticketTypeCount: number;
}

async function loadAllEvents(
  factoryContract: ethers.Contract
): Promise<EventDisplayData[]> {
  // Step 1: Get total event count
  const eventCount = await factoryContract.getEventCount();
  
  // Step 2: Get all EventCreated events (contract addresses)
  const createdFilter = factoryContract.filters.EventCreated();
  const createdLogs = await factoryContract.queryFilter(createdFilter);
  
  // Step 3: For each event, get its EventData contract
  const events: EventDisplayData[] = [];
  
  for (const log of createdLogs) {
    const { eventId, eventData, ticketToken } = log.args;
    
    // Step 4: Query EventDetailsSet from the EventData contract
    const eventDataContract = new ethers.Contract(
      eventData,
      EventDataABI.abi,
      provider
    );
    
    const detailsFilter = eventDataContract.filters.EventDetailsSet();
    const detailsLogs = await eventDataContract.queryFilter(detailsFilter);
    
    if (detailsLogs.length > 0) {
      const details = detailsLogs[0].args;
      
      events.push({
        eventId: eventId.toNumber(),
        eventDataAddress: eventData,
        ticketTokenAddress: ticketToken,
        name: details.eventName,
        image: details.tokenURI,  // ✅ No extra RPC call!
        venue: details.venueLocation,
        date: new Date(details.eventDate.toNumber() * 1000),
        ticketTypeCount: details.ticketTypeCount.toNumber()
      });
    }
  }
  
  return events;
}
```

### Optimized: Batch Event Loading with Pagination
For scalability with many events:

```typescript
async function loadEventsPaginated(
  factoryContract: ethers.Contract,
  page: number = 0,
  pageSize: number = 50
): Promise<EventDisplayData[]> {
  const eventCount = await factoryContract.getEventCount();
  const startIndex = page * pageSize;
  
  if (startIndex >= eventCount) {
    return [];
  }
  
  // Query only the events for this page
  const createdFilter = factoryContract.filters.EventCreated();
  const createdLogs = await factoryContract.queryFilter(
    createdFilter,
    startIndex,
    Math.min(startIndex + pageSize, eventCount)
  );
  
  // Then follow same pattern as loadAllEvents for each log
  // ...
}
```

### Real-Time Updates - Listen for New Events
```typescript
function listenForNewEvents(
  factoryContract: ethers.Contract,
  onNewEvent: (event: EventDisplayData) => void
) {
  // Listen for new event creation on Factory
  factoryContract.on('EventCreated', async (eventId, eventData, ticketToken) => {
    // Get the EventData contract
    const eventDataContract = new ethers.Contract(
      eventData,
      EventDataABI.abi,
      provider
    );
    
    // Listen for its details
    eventDataContract.once('EventDetailsSet', (
      eventId,
      eventName,
      tokenURI,
      venueLocation,
      eventDate,
      ticketTypeCount
    ) => {
      onNewEvent({
        eventId: eventId.toNumber(),
        eventDataAddress: eventData,
        ticketTokenAddress: ticketToken,
        name: eventName,
        image: tokenURI,
        venue: venueLocation,
        date: new Date(eventDate.toNumber() * 1000),
        ticketTypeCount: ticketTypeCount.toNumber()
      });
    });
  });
}
```

---

## 3. Loading Event Details

### Get Full Event Details (when user clicks on event)
```typescript
interface FullEventDetails {
  // Display data
  eventId: number;
  name: string;
  image: string;
  venue: string;
  date: Date;
  description: string;
  eventType: string;
  
  // Ticket info
  ticketNames: string[];
  ticketPrices: number[]; // in USDC (6 decimals)
  ticketCapacities: number[];
  ticketsSold: number[];
  
  // Location
  concertLocation: string;
  venueName: string;
  
  // Metadata
  performers: string[];
  keywords: string[];
  categories: string[];
  
  // Contract addresses
  eventDataAddress: string;
  ticketTokenAddress: string;
  eventOwner: string;
}

async function loadFullEventDetails(
  eventDataAddress: string
): Promise<FullEventDetails> {
  const eventDataContract = new ethers.Contract(
    eventDataAddress,
    EventDataABI.abi,
    provider
  );
  
  // Single RPC call to get all details
  const details = await eventDataContract.details();
  const eventId = await eventDataContract.eventId();
  const eventOwner = await eventDataContract.eventOwner();
  const ticketToken = await eventDataContract.ticketToken();
  
  return {
    eventId: eventId.toNumber(),
    name: details.name,
    date: new Date(details.eventDate.toNumber() * 1000),
    description: details.eventDescription,
    eventType: details.eventType,
    
    // Ticket information
    ticketNames: details.ticketInformation.ticketNames,
    ticketPrices: details.ticketInformation.ticketPrices.map((p: any) => 
      p.toNumber() / 1e6  // Convert from 6 decimals to float
    ),
    ticketCapacities: details.ticketInformation.ticketCapacities.map((c: any) => c.toNumber()),
    ticketsSold: details.ticketInformation.ticketsSold.map((s: any) => s.toNumber()),
    
    // Location
    concertLocation: details.locationDetails.concertLocation,
    venueName: details.locationDetails.venueName,
    venue: details.locationDetails.venueName, // For consistency
    
    // Metadata
    performers: details.performers,
    keywords: details.keywords,
    categories: details.categories,
    
    // Addresses
    eventDataAddress,
    ticketTokenAddress: ticketToken,
    eventOwner,
    
    // Get image from event logs (already cached from initial load)
    image: '' // Fill from your cached EventDetailsSet data
  };
}
```

---

## 4. Buying Tickets

### Single Ticket Purchase
```typescript
async function buyTicket(
  ticketOperationsAddress: string,
  usdcAddress: string,
  eventId: number,
  ticketType: number,
  signer: ethers.Signer
): Promise<ethers.ContractTransaction> {
  const ticketOps = new ethers.Contract(
    ticketOperationsAddress,
    TicketOperationsABI.abi,
    signer
  );
  
  const usdc = new ethers.Contract(
    usdcAddress,
    ['function approve(address spender, uint256 amount) returns (bool)'],
    signer
  );
  
  // Get the event details to know the price
  const factoryAddress = await ticketOps.factory();
  const factory = new ethers.Contract(factoryAddress, FactoryABI.abi, signer);
  const eventDataAddress = await factory.getEventData(eventId);
  const eventData = new ethers.Contract(eventDataAddress, EventDataABI.abi, signer);
  const details = await eventData.details();
  
  const price = details.ticketInformation.ticketPrices[ticketType];
  
  // Step 1: Approve USDC (NOTE: USDC goes to EventData contract, not TicketOperations!)
  const approveTx = await usdc.approve(ticketOperationsAddress, price);
  await approveTx.wait();
  
  // Step 2: Buy ticket
  const buyTx = await ticketOps.buyTicket(eventId, ticketType);
  return buyTx;
}
```

### Multiple Tickets Purchase
```typescript
async function buyMultipleTickets(
  ticketOperationsAddress: string,
  usdcAddress: string,
  eventId: number,
  ticketTypes: number[],
  quantities: number[],
  signer: ethers.Signer
): Promise<ethers.ContractTransaction> {
  const ticketOps = new ethers.Contract(
    ticketOperationsAddress,
    TicketOperationsABI.abi,
    signer
  );
  
  // Calculate total price
  const factoryAddress = await ticketOps.factory();
  const factory = new ethers.Contract(factoryAddress, FactoryABI.abi, signer);
  const eventDataAddress = await factory.getEventData(eventId);
  const eventData = new ethers.Contract(eventDataAddress, EventDataABI.abi, signer);
  const details = await eventData.details();
  
  let totalPrice = ethers.BigNumber.from(0);
  for (let i = 0; i < ticketTypes.length; i++) {
    const price = details.ticketInformation.ticketPrices[ticketTypes[i]];
    totalPrice = totalPrice.add(price.mul(quantities[i]));
  }
  
  // Approve total
  const usdc = new ethers.Contract(
    usdcAddress,
    ['function approve(address spender, uint256 amount) returns (bool)'],
    signer
  );
  const approveTx = await usdc.approve(ticketOperationsAddress, totalPrice);
  await approveTx.wait();
  
  // Buy multiple
  const buyTx = await ticketOps.buyMultipleTickets(eventId, ticketTypes, quantities);
  return buyTx;
}
```

---

## 5. Displaying User's Tickets

### Get User's Ticket Balance
```typescript
async function getUserTickets(
  eventDataAddress: string,
  userAddress: string
): Promise<{ ticketType: number; balance: number }[]> {
  const eventData = new ethers.Contract(
    eventDataAddress,
    EventDataABI.abi,
    provider
  );
  
  const ticketTokenAddress = await eventData.ticketToken();
  const ticketToken = new ethers.Contract(
    ticketTokenAddress,
    ERC1155TokenABI.abi,
    provider
  );
  
  const details = await eventData.details();
  const ticketTypeCount = details.ticketInformation.ticketPrices.length;
  
  const userTickets = [];
  for (let i = 0; i < ticketTypeCount; i++) {
    const balance = await ticketToken.balanceOf(userAddress, i);
    if (balance.gt(0)) {
      userTickets.push({
        ticketType: i,
        balance: balance.toNumber()
      });
    }
  }
  
  return userTickets;
}
```

### Batch Balance Query (More Efficient)
```typescript
async function getUserTicketsBatch(
  eventDataAddress: string,
  userAddress: string
): Promise<number[]> {
  const eventData = new ethers.Contract(
    eventDataAddress,
    EventDataABI.abi,
    provider
  );
  
  const ticketTokenAddress = await eventData.ticketToken();
  const ticketToken = new ethers.Contract(
    ticketTokenAddress,
    ERC1155TokenABI.abi,
    provider
  );
  
  const details = await eventData.details();
  const ticketTypeCount = details.ticketInformation.ticketPrices.length;
  
  // Create arrays for batch call
  const accounts = Array(ticketTypeCount).fill(userAddress);
  const ids = Array.from({ length: ticketTypeCount }, (_, i) => i);
  
  const balances = await ticketToken.balanceOfBatch(accounts, ids);
  return balances.map((b: any) => b.toNumber());
}
```

---

## 6. Admin Functions

### Withdraw Funds from Event
```typescript
async function withdrawEventFunds(
  adminOperationsAddress: string,
  eventId: number,
  amount: string, // USDC amount with 6 decimals (e.g., "100.5" becomes "100500000")
  signer: ethers.Signer
): Promise<ethers.ContractTransaction> {
  const adminOps = new ethers.Contract(
    adminOperationsAddress,
    AdminOperationsABI.abi,
    signer
  );
  
  // Convert to 6 decimal format
  const amountBN = ethers.utils.parseUnits(amount, 6);
  
  const tx = await adminOps.withdrawFunds(eventId, amountBN);
  return tx;
}
```

### Issue Refund
```typescript
async function issueRefund(
  adminOperationsAddress: string,
  eventId: number,
  buyerAddress: string,
  ticketType: number,
  signer: ethers.Signer
): Promise<ethers.ContractTransaction> {
  const adminOps = new ethers.Contract(
    adminOperationsAddress,
    AdminOperationsABI.abi,
    signer
  );
  
  const tx = await adminOps.issueRefund(eventId, buyerAddress, ticketType);
  return tx;
}
```

### Add Comp Ticket
```typescript
async function addCompTicket(
  adminOperationsAddress: string,
  eventId: number,
  recipientAddress: string,
  ticketType: number,
  signer: ethers.Signer
): Promise<ethers.ContractTransaction> {
  const adminOps = new ethers.Contract(
    adminOperationsAddress,
    AdminOperationsABI.abi,
    signer
  );
  
  const tx = await adminOps.addCompTicket(eventId, recipientAddress, ticketType);
  return tx;
}
```

---

## 7. Creating Events (Admin Only)

### Create Event Structure
```typescript
interface EventCreationData {
  owner: string;
  name: string;
  tokenURI: string; // IPFS link for event image
  eventDate: number; // Unix timestamp
  eventDescription: string;
  eventType: string;
  
  // Location
  concertLocation: string;
  venueName: string;
  
  // Tickets
  ticketNames: string[];
  ticketPrices: string[]; // In USDC (will be converted to 6 decimals)
  ticketCapacities: number[];
  feePercentages: number[]; // e.g., [5, 3] for 5% and 3% fees
  
  // Metadata
  performers: string[];
  keywords: string[];
  categories: string[];
}

async function createEvent(
  factoryAddress: string,
  eventData: EventCreationData,
  signer: ethers.Signer
): Promise<{ eventId: number; eventDataAddress: string; ticketTokenAddress: string }> {
  const factory = new ethers.Contract(
    factoryAddress,
    FactoryABI.abi,
    signer
  );
  
  // Convert prices to 6 decimals
  const ticketPrices = eventData.ticketPrices.map(price => 
    ethers.utils.parseUnits(price, 6)
  );
  
  // Build the details struct
  const details = {
    name: eventData.name,
    owner: eventData.owner,
    eventDate: eventData.eventDate,
    ticketInformation: {
      ticketNames: eventData.ticketNames,
      ticketCapacities: eventData.ticketCapacities,
      ticketPrices: ticketPrices,
      ticketsSold: Array(eventData.ticketNames.length).fill(0),
      feePercentages: eventData.feePercentages
    },
    locationDetails: {
      concertLocation: eventData.concertLocation,
      venueName: eventData.venueName
    },
    performers: eventData.performers,
    keywords: eventData.keywords,
    categories: eventData.categories,
    eventDescription: eventData.eventDescription,
    eventType: eventData.eventType
  };
  
  // Create event
  const tx = await factory.createEvent(
    eventData.owner,
    eventData.tokenURI,
    details
  );
  
  const receipt = await tx.wait();
  
  // Parse the EventCreated event
  const event = receipt.events?.find((e: any) => e.event === 'EventCreated');
  
  return {
    eventId: event.args.eventId.toNumber(),
    eventDataAddress: event.args.eventData,
    ticketTokenAddress: event.args.ticketToken
  };
}
```

---

## 8. Caching Strategy

### Recommended Caching Approach
```typescript
class EventCache {
  private events: Map<number, EventDisplayData> = new Map();
  private lastUpdate: number = 0;
  private readonly CACHE_TTL = 5 * 60 * 1000; // 5 minutes
  
  async getEvents(factoryContract: ethers.Contract): Promise<EventDisplayData[]> {
    const now = Date.now();
    
    if (now - this.lastUpdate > this.CACHE_TTL || this.events.size === 0) {
      // Refresh cache
      const events = await loadAllEvents(factoryContract);
      this.events.clear();
      events.forEach(event => this.events.set(event.eventId, event));
      this.lastUpdate = now;
    }
    
    return Array.from(this.events.values());
  }
  
  addEvent(event: EventDisplayData) {
    this.events.set(event.eventId, event);
  }
  
  getEvent(eventId: number): EventDisplayData | undefined {
    return this.events.get(eventId);
  }
}
```

---

## 9. Error Handling

### Common Errors and Solutions
```typescript
const ERROR_CODES = {
  '!A': 'Not authorized - only owner can perform this action',
  '!O': 'Office closed - ticket sales are currently paused',
  '!E': 'Event does not exist',
  '!S': 'Sold out - no more tickets available',
  '!OP': 'Not authorized - only operation contracts can call this'
};

function parseError(error: any): string {
  const errorString = error.message || error.toString();
  
  for (const [code, message] of Object.entries(ERROR_CODES)) {
    if (errorString.includes(code)) {
      return message;
    }
  }
  
  return 'An unexpected error occurred';
}
```

---

## 10. Complete React Hook Example

```typescript
import { useState, useEffect, useCallback } from 'react';
import { ethers } from 'ethers';

export function useEvents(factoryAddress: string, provider: ethers.providers.Provider) {
  const [events, setEvents] = useState<EventDisplayData[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  
  const loadEvents = useCallback(async () => {
    try {
      setLoading(true);
      const factory = new ethers.Contract(
        factoryAddress,
        FactoryABI.abi,
        provider
      );
      
      const loadedEvents = await loadAllEvents(factory);
      setEvents(loadedEvents);
      setError(null);
    } catch (err: any) {
      setError(parseError(err));
    } finally {
      setLoading(false);
    }
  }, [factoryAddress, provider]);
  
  // Initial load
  useEffect(() => {
    loadEvents();
  }, [loadEvents]);
  
  // Listen for new events
  useEffect(() => {
    const factory = new ethers.Contract(
      factoryAddress,
      FactoryABI.abi,
      provider
    );
    
    const handleNewEvent = (newEvent: EventDisplayData) => {
      setEvents(prev => [...prev, newEvent]);
    };
    
    listenForNewEvents(factory, handleNewEvent);
    
    return () => {
      factory.removeAllListeners('EventCreated');
    };
  }, [factoryAddress, provider]);
  
  return { events, loading, error, reload: loadEvents };
}
```

---

## 11. Gas Optimization Tips

1. **Batch Operations**: Use `buyMultipleTickets()` instead of multiple `buyTicket()` calls
2. **Approval Management**: Approve max uint256 once instead of approving per transaction
3. **Event Filtering**: Use indexed parameters in event queries for faster filtering
4. **Pagination**: For large event lists, query events in batches using `getEventData(id)` with incremental IDs

---

## 12. Security Considerations

1. **USDC Approval**: Only approve the exact amount needed, not unlimited
2. **Verify Event Owner**: Check `eventData.eventOwner()` matches expected address
3. **Check Office Status**: Verify `factory.ticketOfficeOpen()` before purchases
4. **Validate Addresses**: Ensure `getEventData()` returns non-zero address
5. **Price Verification**: Always display prices from contract, never hard-coded

---

## Summary

This architecture provides:
- ✅ **Minimal RPC Calls**: Event display data from event logs
- ✅ **Scalability**: Pagination support for millions of events  
- ✅ **Real-time Updates**: Event listeners for new events
- ✅ **Gas Efficiency**: Funds stored in EventData, batch operations available
- ✅ **Type Safety**: Full TypeScript support
- ✅ **Error Handling**: User-friendly error messages

The key insight: **Use event logs for display data, direct contract calls only for transactions and detailed queries.**
