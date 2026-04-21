# Frontend Data Retrieval Guide

This guide explains how to interact with the smart contracts to retrieve all event data needed to display on your frontend.

## ✅ ALL METADATA NOW ACCESSIBLE VIA GETTERS!

**Good news!** The contract now includes explicit getter functions for ALL event metadata, including:
- Event name, description, type
- Venue location
- Performers, keywords, categories (arrays)
- Ticket names (individual and array)
- All ticket pricing, capacity, and availability data

**No need for:**
- ❌ Event log parsing (except for historical tracking)
- ❌ Off-chain database storage (except for caching)
- ❌ IPFS metadata parsing (except for images)

Everything can be queried directly from the contract!

## Contract Architecture Overview

The system consists of three main contract types:

1. **TicketOfficeFactory** - Creates and tracks all events
2. **EventData** - Stores all event metadata (one per event)
3. **ERC1155Token** - NFT token contract (one per event)

## Contract Addresses

### Sepolia Testnet
```typescript
const FACTORY_ADDRESS = "0x17a6b3aaf32b356f501e362b8e20c789347e782d"; // Latest deployment
const USDC_ADDRESS = "0x0000065... "; // Your USDC address
```

## Complete ABIs

> 📄 **Quick Copy**: All ABIs are also available in [frontend-abis.ts](frontend-abis.ts) for easy copy/paste into your project!

### Factory ABI (TicketOfficeFactory)

```typescript
export const factoryABI = [
  {
    inputs: [],
    name: 'getEventCount',
    outputs: [{ type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [{ name: 'id', type: 'uint256' }],
    name: 'getEventData',
    outputs: [{ type: 'address' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'owner',
    outputs: [{ type: 'address' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'ticketOfficeOpen',
    outputs: [{ type: 'bool' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [
      { name: '_eventOwner', type: 'address' },
      { name: '_tokenUri', type: 'string' },
      {
        name: '_details',
        type: 'tuple',
        components: [
          { name: 'name', type: 'string' },
          { name: 'owner', type: 'address' },
          { name: 'eventDate', type: 'uint256' },
          {
            name: 'ticketInformation',
            type: 'tuple',
            components: [
              { name: 'ticketNames', type: 'string[]' },
              { name: 'ticketCapacities', type: 'uint256[]' },
              { name: 'ticketPrices', type: 'uint256[]' },
              { name: 'ticketsSold', type: 'uint256[]' },
              { name: 'feePercentages', type: 'uint256[]' },
            ],
          },
          {
            name: 'locationDetails',
            type: 'tuple',
            components: [{ name: 'venue', type: 'string' }],
          },
          { name: 'performers', type: 'string[]' },
          { name: 'keywords', type: 'string[]' },
          { name: 'categories', type: 'string[]' },
          { name: 'eventDescription', type: 'string' },
          { name: 'eventType', type: 'string' },
        ],
      },
    ],
    name: 'createEvent',
    outputs: [
      { name: 'eventId', type: 'uint256' },
      { name: 'eventData', type: 'address' },
      { name: 'ticketToken', type: 'address' },
    ],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    anonymous: false,
    inputs: [
      { indexed: true, name: 'eventId', type: 'uint256' },
      { indexed: true, name: 'eventData', type: 'address' },
      { indexed: true, name: 'ticketToken', type: 'address' },
    ],
    name: 'EventCreated',
    type: 'event',
  },
] as const;
```

### EventData ABI (Complete with all getters)

```typescript
export const eventDataABI = [
  // Basic Info
  {
    inputs: [],
    name: 'eventId',
    outputs: [{ type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'eventOwner',
    outputs: [{ type: 'address' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'ticketToken',
    outputs: [{ type: 'address' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'factory',
    outputs: [{ type: 'address' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'eventBalance',
    outputs: [{ type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'locked',
    outputs: [{ type: 'bool' }],
    stateMutability: 'view',
    type: 'function',
  },
  // Event Metadata Getters
  {
    inputs: [],
    name: 'getEventName',
    outputs: [{ type: 'string' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'getEventDate',
    outputs: [{ type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'getVenue',
    outputs: [{ type: 'string' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'getPerformers',
    outputs: [{ type: 'string[]' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'getKeywords',
    outputs: [{ type: 'string[]' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'getCategories',
    outputs: [{ type: 'string[]' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'getEventDescription',
    outputs: [{ type: 'string' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'getEventType',
    outputs: [{ type: 'string' }],
    stateMutability: 'view',
    type: 'function',
  },
  // Ticket Getters
  {
    inputs: [],
    name: 'getTicketCount',
    outputs: [{ type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'getTicketNames',
    outputs: [{ type: 'string[]' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [{ name: 'ticketType', type: 'uint256' }],
    name: 'getTicketName',
    outputs: [{ type: 'string' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [{ name: 'ticketType', type: 'uint256' }],
    name: 'getTicketPrice',
    outputs: [{ type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [{ name: 'ticketType', type: 'uint256' }],
    name: 'getTicketCapacity',
    outputs: [{ type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [{ name: 'ticketType', type: 'uint256' }],
    name: 'getTicketsSold',
    outputs: [{ type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [{ name: 'ticketType', type: 'uint256' }],
    name: 'getTicketFeePercentage',
    outputs: [{ type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'getTotalTicketsSold',
    outputs: [{ type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  // Events
  {
    anonymous: false,
    inputs: [
      { indexed: true, name: 'eventId', type: 'uint256' },
      { indexed: false, name: 'eventName', type: 'string' },
      { indexed: false, name: 'tokenURI', type: 'string' },
      { indexed: false, name: 'venueLocation', type: 'string' },
      { indexed: false, name: 'eventDate', type: 'uint256' },
      { indexed: false, name: 'ticketTypeCount', type: 'uint256' },
    ],
    name: 'EventDetailsSet',
    type: 'event',
  },
] as const;
```

### ERC1155 Token ABI

```typescript
export const erc1155TokenABI = [
  {
    inputs: [],
    name: 'uri',
    outputs: [{ type: 'string' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'name',
    outputs: [{ type: 'string' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'factory',
    outputs: [{ type: 'address' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [
      { name: 'account', type: 'address' },
      { name: 'id', type: 'uint256' },
    ],
    name: 'balanceOf',
    outputs: [{ type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [
      { name: 'accounts', type: 'address[]' },
      { name: 'ids', type: 'uint256[]' },
    ],
    name: 'balanceOfBatch',
    outputs: [{ type: 'uint256[]' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [
      { name: 'account', type: 'address' },
      { name: 'operator', type: 'address' },
    ],
    name: 'isApprovedForAll',
    outputs: [{ type: 'bool' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [
      { name: 'operator', type: 'address' },
      { name: 'approved', type: 'bool' },
    ],
    name: 'setApprovalForAll',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      { name: 'from', type: 'address' },
      { name: 'to', type: 'address' },
      { name: 'id', type: 'uint256' },
      { name: 'value', type: 'uint256' },
      { name: 'data', type: 'bytes' },
    ],
    name: 'safeTransferFrom',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    anonymous: false,
    inputs: [
      { indexed: true, name: 'operator', type: 'address' },
      { indexed: true, name: 'from', type: 'address' },
      { indexed: true, name: 'to', type: 'address' },
      { indexed: false, name: 'id', type: 'uint256' },
      { indexed: false, name: 'value', type: 'uint256' },
    ],
    name: 'TransferSingle',
    type: 'event',
  },
] as const;
```

### TicketOperations ABI (for buying tickets)

```typescript
export const ticketOperationsABI = [
  {
    inputs: [
      { name: 'eventId', type: 'uint256' },
      { name: 'ticketType', type: 'uint256' },
    ],
    name: 'buyTicket',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      { name: 'eventId', type: 'uint256' },
      { name: 'ticketTypes', type: 'uint256[]' },
      { name: 'quantities', type: 'uint256[]' },
    ],
    name: 'buyTickets',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      { name: 'eventId', type: 'uint256' },
      { name: 'ticketType', type: 'uint256' },
    ],
    name: 'redeemCompTicket',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
] as const;
```

### USDC ABI (minimal ERC20)

```typescript
export const usdcABI = [
  {
    inputs: [
      { name: 'spender', type: 'address' },
      { name: 'amount', type: 'uint256' },
    ],
    name: 'approve',
    outputs: [{ type: 'bool' }],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      { name: 'owner', type: 'address' },
      { name: 'spender', type: 'address' },
    ],
    name: 'allowance',
    outputs: [{ type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [{ name: 'account', type: 'address' }],
    name: 'balanceOf',
    outputs: [{ type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'decimals',
    outputs: [{ type: 'uint8' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    anonymous: false,
    inputs: [
      { indexed: true, name: 'owner', type: 'address' },
      { indexed: true, name: 'spender', type: 'address' },
      { indexed: false, name: 'value', type: 'uint256' },
    ],
    name: 'Approval',
    type: 'event',
  },
] as const;
```

## Step-by-Step Data Retrieval

### 1. Get All Events from Factory

```typescript
import { createPublicClient, http } from 'viem';
import { sepolia } from 'viem/chains';

const publicClient = createPublicClient({
  chain: sepolia,
  transport: http(),
});

// Factory ABI (minimal for reading)
const factoryABI = [
  {
    inputs: [],
    name: 'getEventCount',
    outputs: [{ type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [{ name: 'id', type: 'uint256' }],
    name: 'getEventData',
    outputs: [{ type: 'address' }],
    stateMutability: 'view',
    type: 'function',
  },
] as const;

// Get total number of events
const eventCount = await publicClient.readContract({
  address: FACTORY_ADDRESS,
  abi: factoryABI,
  functionName: 'getEventCount',
});

console.log(`Total events: ${eventCount}`);

// Get all event addresses
const eventAddresses = [];
for (let i = 0; i < eventCount; i++) {
  const eventDataAddress = await publicClient.readContract({
    address: FACTORY_ADDRESS,
    abi: factoryABI,
    functionName: 'getEventData',
    args: [BigInt(i)],
  });
  eventAddresses.push(eventDataAddress);
}
```

### 2. Get Complete Event Metadata

```typescript
// EventData ABI
const eventDataABI = [
  {
    inputs: [],
    name: 'eventId',
    outputs: [{ type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'eventOwner',
    outputs: [{ type: 'address' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'ticketToken',
    outputs: [{ type: 'address' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'getEventDate',
    outputs: [{ type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'getEventName',
    outputs: [{ type: 'string' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'getVenue',
    outputs: [{ type: 'string' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'getPerformers',
    outputs: [{ type: 'string[]' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'getKeywords',
    outputs: [{ type: 'string[]' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'getCategories',
    outputs: [{ type: 'string[]' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'getEventDescription',
    outputs: [{ type: 'string' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'getEventType',
    outputs: [{ type: 'string' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'getTicketCount',
    outputs: [{ type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'getTicketNames',
    outputs: [{ type: 'string[]' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [{ name: 'ticketType', type: 'uint256' }],
    name: 'getTicketName',
    outputs: [{ type: 'string' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [{ name: 'ticketType', type: 'uint256' }],
    name: 'getTicketPrice',
    outputs: [{ type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [{ name: 'ticketType', type: 'uint256' }],
    name: 'getTicketCapacity',
    outputs: [{ type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [{ name: 'ticketType', type: 'uint256' }],
    name: 'getTicketsSold',
    outputs: [{ type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [{ name: 'ticketType', type: 'uint256' }],
    name: 'getTicketFeePercentage',
    outputs: [{ type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'getTotalTicketsSold',
    outputs: [{ type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'eventBalance',
    outputs: [{ type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'locked',
    outputs: [{ type: 'bool' }],
    stateMutability: 'view',
    type: 'function',
  },
] as const;

// ERC1155Token ABI
const tokenABI = [
  {
    inputs: [],
    name: 'uri',
    outputs: [{ type: 'string' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'name',
    outputs: [{ type: 'string' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [
      { name: 'account', type: 'address' },
      { name: 'id', type: 'uint256' },
    ],
    name: 'balanceOf',
    outputs: [{ type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
] as const;

// Function to get complete event data
async function getEventData(eventDataAddress: `0x${string}`) {
  // Basic event info
  const [
    eventId,
    eventOwner,
    ticketToken,
    eventDate,
    eventName,
    venue,
    performers,
    keywords,
    categories,
    eventDescription,
    eventType,
    ticketCount,
    totalSold,
    balance,
    locked,
  ] = await Promise.all([
    publicClient.readContract({
      address: eventDataAddress,
      abi: eventDataABI,
      functionName: 'eventId',
    }),
    publicClient.readContract({
      address: eventDataAddress,
      abi: eventDataABI,
      functionName: 'eventOwner',
    }),
    publicClient.readContract({
      address: eventDataAddress,
      abi: eventDataABI,
      functionName: 'ticketToken',
    }),
    publicClient.readContract({
      address: eventDataAddress,
      abi: eventDataABI,
      functionName: 'getEventDate',
    }),
    publicClient.readContract({
      address: eventDataAddress,
      abi: eventDataABI,
      functionName: 'getEventName',
    }),
    publicClient.readContract({
      address: eventDataAddress,
      abi: eventDataABI,
      functionName: 'getVenue',
    }),
    publicClient.readContract({
      address: eventDataAddress,
      abi: eventDataABI,
      functionName: 'getPerformers',
    }),
    publicClient.readContract({
      address: eventDataAddress,
      abi: eventDataABI,
      functionName: 'getKeywords',
    }),
    publicClient.readContract({
      address: eventDataAddress,
      abi: eventDataABI,
      functionName: 'getCategories',
    }),
    publicClient.readContract({
      address: eventDataAddress,
      abi: eventDataABI,
      functionName: 'getEventDescription',
    }),
    publicClient.readContract({
      address: eventDataAddress,
      abi: eventDataABI,
      functionName: 'getEventType',
    }),
    publicClient.readContract({
      address: eventDataAddress,
      abi: eventDataABI,
      functionName: 'getTicketCount',
    }),
    publicClient.readContract({
      address: eventDataAddress,
      abi: eventDataABI,
      functionName: 'getTotalTicketsSold',
    }),
    publicClient.readContract({
      address: eventDataAddress,
      abi: eventDataABI,
      functionName: 'eventBalance',
    }),
    publicClient.readContract({
      address: eventDataAddress,
      abi: eventDataABI,
      functionName: 'locked',
    }),
  ]);

  // Get token metadata
  const tokenUri = await publicClient.readContract({
    address: ticketToken,
    abi: tokenABI,
    functionName: 'uri',
  });

  // Get ticket names
  const ticketNames = await publicClient.readContract({
    address: eventDataAddress,
    abi: eventDataABI,
    functionName: 'getTicketNames',
  });

  // Get ticket information for each ticket type
  const tickets = [];
  for (let i = 0; i < Number(ticketCount); i++) {
    const [price, capacity, sold, feePercentage] = await Promise.all([
      publicClient.readContract({
        address: eventDataAddress,
        abi: eventDataABI,
        functionName: 'getTicketPrice',
        args: [BigInt(i)],
      }),
      publicClient.readContract({
        address: eventDataAddress,
        abi: eventDataABI,
        functionName: 'getTicketCapacity',
        args: [BigInt(i)],
      }),
      publicClient.readContract({
        address: eventDataAddress,
        abi: eventDataABI,
        functionName: 'getTicketsSold',
        args: [BigInt(i)],
      }),
      publicClient.readContract({
        address: eventDataAddress,
        abi: eventDataABI,
        functionName: 'getTicketFeePercentage',
        args: [BigInt(i)],
      }),
    ]);

    tickets.push({
      id: i,
      name: ticketNames[i],
      price: price, // in USDC base units (e.g., 50000000 = 50 USDC)
      capacity: Number(capacity),
      sold: Number(sold),
      available: Number(capacity) - Number(sold),
      feePercentage: Number(feePercentage),
    });
  }

  return {
    eventId: Number(eventId),
    eventOwner,
    eventDataAddress,
    ticketToken,
    eventName,
    tokenUri,
    venue,
    performers,
    keywords,
    categories,
    eventDescription,
    eventType,
    eventDate: Number(eventDate), // Unix timestamp
    totalTicketsSold: Number(totalSold),
    eventBalance: balance, // in USDC base units
    locked,
    tickets,
  };
}
```

### 3. Get Event Metadata from Event Logs

The `EventDetailsSet` event contains additional metadata like venue, performers, etc:

```typescript
// Listen for EventDetailsSet events to get full metadata
const eventDataContractABI = [
  {
    anonymous: false,
    inputs: [
      { indexed: true, name: 'eventId', type: 'uint256' },
      { indexed: false, name: 'eventName', type: 'string' },
      { indexed: false, name: 'tokenURI', type: 'string' },
      { indexed: false, name: 'venueLocation', type: 'string' },
      { indexed: false, name: 'eventDate', type: 'uint256' },
      { indexed: false, name: 'ticketTypeCount', type: 'uint256' },
    ],
    name: 'EventDetailsSet',
    type: 'event',
  },
] as const;

// Get event logs for specific EventData contract
async function getEventMetadataFromLogs(eventDataAddress: `0x${string}`) {
  const logs = await publicClient.getLogs({
    address: eventDataAddress,
    event: {
      type: 'event',
      name: 'EventDetailsSet',
      inputs: [
        { indexed: true, name: 'eventId', type: 'uint256' },
        { indexed: false, name: 'eventName', type: 'string' },
        { indexed: false, name: 'tokenURI', type: 'string' },
        { indexed: false, name: 'venueLocation', type: 'string' },
        { indexed: false, name: 'eventDate', type: 'uint256' },
        { indexed: false, name: 'ticketTypeCount', type: 'uint256' },
      ],
    },
    fromBlock: 'earliest',
    toBlock: 'latest',
  });

  if (logs.length > 0) {
    const log = logs[0];
    return {
      eventName: log.args.eventName,
      tokenURI: log.args.tokenURI,
      venueLocation: log.args.venueLocation,
      eventDate: Number(log.args.eventDate),
      ticketTypeCount: Number(log.args.ticketTypeCount),
    };
  }
  return null;
}
```

### 4. Get User's Tickets

```typescript
async function getUserTickets(userAddress: `0x${string}`, eventDataAddress: `0x${string}`) {
  // First get the ticket token address
  const ticketToken = await publicClient.readContract({
    address: eventDataAddress,
    abi: eventDataABI,
    functionName: 'ticketToken',
  });

  // Get ticket count
  const ticketCount = await publicClient.readContract({
    address: eventDataAddress,
    abi: eventDataABI,
    functionName: 'getTicketCount',
  });

  // Check balance for each ticket type
  const userTickets = [];
  for (let i = 0; i < Number(ticketCount); i++) {
    const balance = await publicClient.readContract({
      address: ticketToken,
      abi: tokenABI,
      functionName: 'balanceOf',
      args: [userAddress, BigInt(i)],
    });

    if (balance > 0n) {
      userTickets.push({
        ticketTypeId: i,
        quantity: Number(balance),
      });
    }
  }

  return userTickets;
}
```

## Complete TypeScript Interface

```typescript
interface Event {
  eventId: number;
  eventOwner: `0x${string}`;
  eventDataAddress: `0x${string}`;
  ticketToken: `0x${string}`;
  eventName: string; // From getEventName()
  tokenUri: string;
  venue: string; // From getVenue()
  performers: string[]; // From getPerformers()
  keywords: string[]; // From getKeywords()
  categories: string[]; // From getCategories()
  eventDescription: string; // From getEventDescription()
  eventType: string; // From getEventType()
  eventDate: number; // Unix timestamp
  eventDateFormatted: string; // "2026-01-18T12:00:00Z"
  totalTicketsSold: number;
  eventBalance: bigint; // USDC in base units
  locked: boolean;
  tickets: TicketType[];
}

interface TicketType {
  id: number;
  name: string; // Now available via getTicketName() or getTicketNames()
  price: bigint; // USDC in base units (e.g., 50000000 = 50 USDC)
  priceFormatted: string; // "50.00 USDC"
  capacity: number;
  sold: number;
  available: number;
  feePercentage: number; // e.g., 10 = 10%
}

interface UserTicket {
  ticketTypeId: number;
  quantity: number;
}
```

## Utility Functions

```typescript
// Format USDC amount (6 decimals)
function formatUSDC(amount: bigint): string {
  return (Number(amount) / 1_000_000).toFixed(2);
}

// Format date
function formatEventDate(timestamp: number): string {
  return new Date(timestamp * 1000).toISOString();
}

// Calculate ticket availability
function getTicketAvailability(capacity: number, sold: number) {
  const available = capacity - sold;
  const percentSold = (sold / capacity) * 100;
  
  return {
    available,
    sold,
    capacity,
    percentSold: percentSold.toFixed(1),
    isSoldOut: available === 0,
    isAlmostSoldOut: available < capacity * 0.1, // Less than 10% remaining
  };
}
```

## React Hook Example

```typescript
import { useQuery } from '@tanstack/react-query';

export function useEvent(eventId: number) {
  return useQuery({
    queryKey: ['event', eventId],
    queryFn: async () => {
      // Get EventData address from factory
      const eventDataAddress = await publicClient.readContract({
        address: FACTORY_ADDRESS,
        abi: factoryABI,
        functionName: 'getEventData',
        args: [BigInt(eventId)],
      });

      if (eventDataAddress === '0x0000000000000000000000000000000000000000') {
        throw new Error('Event not found');
      }

      // Get complete event data
      const eventData = await getEventData(eventDataAddress);
      
      // Get metadata from logs
      const metadata = await getEventMetadataFromLogs(eventDataAddress);

      return {
        ...eventData,
        ...metadata,
        eventDateFormatted: formatEventDate(eventData.eventDate),
        tickets: eventData.tickets.map(ticket => ({
          ...ticket,
          priceFormatted: `${formatUSDC(ticket.price)} USDC`,
          availability: getTicketAvailability(ticket.capacity, ticket.sold),
        })),
      };
    },
    staleTime: 30_000, // 30 seconds
    refetchInterval: 60_000, // Refetch every minute
  });
}

export function useAllEvents() {
  return useQuery({
    queryKey: ['events', 'all'],
    queryFn: async () => {
      const eventCount = await publicClient.readContract({
        address: FACTORY_ADDRESS,
        abi: factoryABI,
        functionName: 'getEventCount',
      });

      const events = [];
      for (let i = 0; i < Number(eventCount); i++) {
        const eventDataAddress = await publicClient.readContract({
          address: FACTORY_ADDRESS,
          abi: factoryABI,
          functionName: 'getEventData',
          args: [BigInt(i)],
        });

        const eventData = await getEventData(eventDataAddress);
        const metadata = await getEventMetadataFromLogs(eventDataAddress);
        
        events.push({
          ...eventData,
          ...metadata,
        });
      }

      return events;
    },
    staleTime: 60_000, // 1 minute
  });
}

export function useUserTickets(userAddress: `0x${string}`, eventId: number) {
  return useQuery({
    queryKey: ['userTickets', userAddress, eventId],
    queryFn: async () => {
      const eventDataAddress = await publicClient.readContract({
        address: FACTORY_ADDRESS,
        abi: factoryABI,
        functionName: 'getEventData',
        args: [BigInt(eventId)],
      });

      return await getUserTickets(userAddress, eventDataAddress);
    },
    enabled: !!userAddress,
  });
}
```

## Display Component Example

```typescript
import { useEvent } from './hooks';

export function EventCard({ eventId }: { eventId: number }) {
  const { data: event, isLoading, error } = useEvent(eventId);

  if (isLoading) return <div>Loading...</div>;
  if (error) return <div>Error loading event</div>;
  if (!event) return null;

  return (
    <div className="event-card">
      <img src={event.tokenUri} alt={event.eventName} />
      <h2>{event.eventName}</h2>
      <p>Venue: {event.venue}</p>
      <p>Date: {new Date(event.eventDate * 1000).toLocaleDateString()}</p>
      <p>Type: {event.eventType}</p>
      <p>Description: {event.eventDescription}</p>
      
      <div className="performers">
        <h3>Performers:</h3>
        <ul>
          {event.performers.map((performer, i) => (
            <li key={i}>{performer}</li>
          ))}
        </ul>
      </div>

      <div className="categories">
        {event.categories.map((cat, i) => (
          <span key={i} className="badge">{cat}</span>
        ))}
      </div>
      
      <p>Total Sold: {event.totalTicketsSold} tickets</p>
      
      <div className="tickets">
        {event.tickets.map((ticket) => (
          <div key={ticket.id} className="ticket-type">
            <h3>{ticket.name}</h3>
            <p>Price: {formatUSDC(ticket.price)} USDC</p>
            <p>
              Available: {ticket.available} / {ticket.capacity}
            </p>
            {ticket.available === 0 && <span>SOLD OUT</span>}
          </div>
        ))}
      </div>

      {event.locked && <p className="warning">Event is locked</p>}
    </div>
  );
}
```

## Important Notes

### USDC Decimals
USDC uses 6 decimals, so:
- `50000000` = 50 USDC
- `100000000` = 100 USDC

Always divide by `1_000_000` to get the human-readable amount.

### Date Format
Event dates are stored as Unix timestamps (seconds since epoch). Convert to JavaScript Date:
```typescript
const date = new Date(timestamp * 1000); // Multiply by 1000 for milliseconds
```

### Gas Optimization
- Batch multiple read calls using `multicall` or Promise.all
- Cache results using React Query or SWR
- Only refetch data when necessary (e.g., after a purchase)

### Missing Data
**FIXED!** All data is now accessible via getter functions:
- ✅ Performers array - `getPerformers()`
- ✅ Keywords array - `getKeywords()`
- ✅ Categories array - `getCategories()`
- ✅ Event description - `getEventDescription()`
- ✅ Event type - `getEventType()`
- ✅ Venue location - `getVenue()`
- ✅ Ticket names - `getTicketNames()` or `getTicketName(uint256)`

No need for event logs, off-chain storage, or IPFS parsing for this data anymore!

## Next Steps

1. **Store metadata in your database** - When events are created, index the transaction and store all metadata in your DB for faster queries
2. **IPFS Integration** - Store full event details (performers, description, images) on IPFS and reference from tokenUri
3. **Indexing Service** - Use The Graph or a custom indexer to efficiently query all events and their metadata
4. **WebSocket Updates** - Listen for contract events in real-time to update UI when tickets are sold

# 🎫 Ticket Purchasing Guide

This section covers the complete flow for purchasing tickets, including USDC approval, contract interactions, error handling, and frontend implementation.

## Overview of Ticket Purchase Flow

1. **Check Ticket Availability** - Ensure tickets are available
2. **Get Ticket Price** - Calculate total cost including fees
3. **Check USDC Balance** - Verify user has sufficient funds
4. **Approve USDC Spending** - Allow factory contract to spend USDC
5. **Purchase Tickets** - Call buyTicket function
6. **Monitor Transaction** - Track transaction status
7. **Refresh Data** - Update UI with new ticket counts

## Contract Addresses & ABIs

```typescript
// Sepolia Testnet Addresses
const FACTORY_ADDRESS = "0x17a6b3aaf32b356f501e362b8e20c789347e782d";
const USDC_ADDRESS = "0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238"; // Sepolia USDC

// Complete ABIs for purchasing
export const factoryPurchaseABI = [
  {
    inputs: [
      { name: 'eventId', type: 'uint256' },
      { name: 'ticketType', type: 'uint256' },
    ],
    name: 'buyTicket',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      { name: 'eventId', type: 'uint256' },
      { name: 'ticketTypes', type: 'uint256[]' },
      { name: 'quantities', type: 'uint256[]' },
    ],
    name: 'buyTickets',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    anonymous: false,
    inputs: [
      { indexed: true, name: 'buyer', type: 'address' },
      { indexed: true, name: 'eventId', type: 'uint256' },
      { indexed: false, name: 'ticketType', type: 'uint256' },
      { indexed: false, name: 'quantity', type: 'uint256' },
      { indexed: false, name: 'totalCost', type: 'uint256' },
    ],
    name: 'TicketPurchased',
    type: 'event',
  },
] as const;

export const usdcPurchaseABI = [
  {
    inputs: [
      { name: 'spender', type: 'address' },
      { name: 'amount', type: 'uint256' },
    ],
    name: 'approve',
    outputs: [{ type: 'bool' }],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      { name: 'owner', type: 'address' },
      { name: 'spender', type: 'address' },
    ],
    name: 'allowance',
    outputs: [{ type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [{ name: 'account', type: 'address' }],
    name: 'balanceOf',
    outputs: [{ type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
] as const;
```

## Step-by-Step Purchase Implementation

### 1. Pre-Purchase Validation

```typescript
import { createPublicClient, createWalletClient, http } from 'viem';
import { sepolia } from 'viem/chains';

interface PurchaseValidation {
  canPurchase: boolean;
  reason?: string;
  ticketPrice: bigint;
  totalCost: bigint;
  userBalance: bigint;
  currentAllowance: bigint;
  needsApproval: boolean;
}

async function validatePurchase(
  userAddress: `0x${string}`,
  eventId: number,
  ticketType: number,
  quantity: number = 1
): Promise<PurchaseValidation> {
  const publicClient = createPublicClient({
    chain: sepolia,
    transport: http(),
  });

  try {
    // Get event data address
    const eventDataAddress = await publicClient.readContract({
      address: FACTORY_ADDRESS,
      abi: factoryABI,
      functionName: 'getEventData',
      args: [BigInt(eventId)],
    });

    if (eventDataAddress === '0x0000000000000000000000000000000000000000') {
      return {
        canPurchase: false,
        reason: 'Event not found',
        ticketPrice: 0n,
        totalCost: 0n,
        userBalance: 0n,
        currentAllowance: 0n,
        needsApproval: false,
      };
    }

    // Get ticket information
    const [ticketPrice, ticketCapacity, ticketsSold, isLocked] = await Promise.all([
      publicClient.readContract({
        address: eventDataAddress,
        abi: eventDataABI,
        functionName: 'getTicketPrice',
        args: [BigInt(ticketType)],
      }),
      publicClient.readContract({
        address: eventDataAddress,
        abi: eventDataABI,
        functionName: 'getTicketCapacity',
        args: [BigInt(ticketType)],
      }),
      publicClient.readContract({
        address: eventDataAddress,
        abi: eventDataABI,
        functionName: 'getTicketsSold',
        args: [BigInt(ticketType)],
      }),
      publicClient.readContract({
        address: eventDataAddress,
        abi: eventDataABI,
        functionName: 'locked',
      }),
    ]);

    // Check availability
    const available = Number(ticketCapacity) - Number(ticketsSold);
    if (available < quantity) {
      return {
        canPurchase: false,
        reason: `Only ${available} tickets available, requested ${quantity}`,
        ticketPrice,
        totalCost: ticketPrice * BigInt(quantity),
        userBalance: 0n,
        currentAllowance: 0n,
        needsApproval: false,
      };
    }

    // Check if event is locked
    if (isLocked) {
      return {
        canPurchase: false,
        reason: 'Event is locked for purchases',
        ticketPrice,
        totalCost: ticketPrice * BigInt(quantity),
        userBalance: 0n,
        currentAllowance: 0n,
        needsApproval: false,
      };
    }

    // Calculate total cost
    const totalCost = ticketPrice * BigInt(quantity);

    // Get user's USDC balance and allowance
    const [userBalance, currentAllowance] = await Promise.all([
      publicClient.readContract({
        address: USDC_ADDRESS,
        abi: usdcPurchaseABI,
        functionName: 'balanceOf',
        args: [userAddress],
      }),
      publicClient.readContract({
        address: USDC_ADDRESS,
        abi: usdcPurchaseABI,
        functionName: 'allowance',
        args: [userAddress, FACTORY_ADDRESS],
      }),
    ]);

    // Check if user has sufficient balance
    if (userBalance < totalCost) {
      return {
        canPurchase: false,
        reason: `Insufficient USDC balance. Need ${formatUSDC(totalCost)}, have ${formatUSDC(userBalance)}`,
        ticketPrice,
        totalCost,
        userBalance,
        currentAllowance,
        needsApproval: currentAllowance < totalCost,
      };
    }

    // Check if approval is needed
    const needsApproval = currentAllowance < totalCost;

    return {
      canPurchase: !needsApproval, // Can purchase immediately if no approval needed
      reason: needsApproval ? 'USDC approval required' : undefined,
      ticketPrice,
      totalCost,
      userBalance,
      currentAllowance,
      needsApproval,
    };

  } catch (error) {
    console.error('Validation error:', error);
    return {
      canPurchase: false,
      reason: 'Failed to validate purchase',
      ticketPrice: 0n,
      totalCost: 0n,
      userBalance: 0n,
      currentAllowance: 0n,
      needsApproval: false,
    };
  }
}
```

### 2. USDC Approval

```typescript
async function approveUSDC(
  walletClient: any,
  userAddress: `0x${string}`,
  amount: bigint
): Promise<{ success: boolean; txHash?: string; error?: string }> {
  try {
    // Add 10% buffer to handle any rounding or fee changes
    const approvalAmount = (amount * 110n) / 100n;

    const txHash = await walletClient.writeContract({
      address: USDC_ADDRESS,
      abi: usdcPurchaseABI,
      functionName: 'approve',
      args: [FACTORY_ADDRESS, approvalAmount],
      account: userAddress,
    });

    console.log('Approval transaction sent:', txHash);
    return { success: true, txHash };

  } catch (error) {
    console.error('Approval failed:', error);
    return { 
      success: false, 
      error: error instanceof Error ? error.message : 'Unknown error' 
    };
  }
}

// Wait for approval transaction to be mined
async function waitForApproval(
  publicClient: any,
  txHash: string,
  userAddress: `0x${string}`,
  expectedAmount: bigint
): Promise<boolean> {
  try {
    // Wait for transaction to be mined
    const receipt = await publicClient.waitForTransactionReceipt({
      hash: txHash as `0x${string}`,
      timeout: 60000, // 1 minute timeout
    });

    if (receipt.status === 'reverted') {
      console.error('Approval transaction reverted');
      return false;
    }

    // Verify the allowance was set correctly
    const allowance = await publicClient.readContract({
      address: USDC_ADDRESS,
      abi: usdcPurchaseABI,
      functionName: 'allowance',
      args: [userAddress, FACTORY_ADDRESS],
    });

    return allowance >= expectedAmount;

  } catch (error) {
    console.error('Error waiting for approval:', error);
    return false;
  }
}
```

### 3. Purchase Tickets

```typescript
interface PurchaseResult {
  success: boolean;
  txHash?: string;
  error?: string;
  ticketsPurchased?: number;
}

// Single ticket purchase
async function purchaseTicket(
  walletClient: any,
  userAddress: `0x${string}`,
  eventId: number,
  ticketType: number
): Promise<PurchaseResult> {
  try {
    const txHash = await walletClient.writeContract({
      address: FACTORY_ADDRESS,
      abi: factoryPurchaseABI,
      functionName: 'buyTicket',
      args: [BigInt(eventId), BigInt(ticketType)],
      account: userAddress,
    });

    console.log('Purchase transaction sent:', txHash);
    return { success: true, txHash, ticketsPurchased: 1 };

  } catch (error) {
    console.error('Purchase failed:', error);
    
    // Parse common error messages
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    
    if (errorMessage.includes('insufficient allowance')) {
      return { success: false, error: 'USDC approval insufficient. Please approve again.' };
    }
    if (errorMessage.includes('insufficient balance')) {
      return { success: false, error: 'Insufficient USDC balance.' };
    }
    if (errorMessage.includes('sold out')) {
      return { success: false, error: 'This ticket type is sold out.' };
    }
    if (errorMessage.includes('event locked')) {
      return { success: false, error: 'Event is currently locked for purchases.' };
    }

    return { success: false, error: errorMessage };
  }
}

// Multiple tickets purchase (batch)
async function purchaseTickets(
  walletClient: any,
  userAddress: `0x${string}`,
  eventId: number,
  ticketTypes: number[],
  quantities: number[]
): Promise<PurchaseResult> {
  try {
    if (ticketTypes.length !== quantities.length) {
      return { success: false, error: 'Ticket types and quantities arrays must have same length' };
    }

    const totalQuantity = quantities.reduce((sum, qty) => sum + qty, 0);

    const txHash = await walletClient.writeContract({
      address: FACTORY_ADDRESS,
      abi: factoryPurchaseABI,
      functionName: 'buyTickets',
      args: [
        BigInt(eventId), 
        ticketTypes.map(t => BigInt(t)), 
        quantities.map(q => BigInt(q))
      ],
      account: userAddress,
    });

    console.log('Batch purchase transaction sent:', txHash);
    return { success: true, txHash, ticketsPurchased: totalQuantity };

  } catch (error) {
    console.error('Batch purchase failed:', error);
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    return { success: false, error: errorMessage };
  }
}
```

### 4. Complete Purchase Hook

```typescript
import { useState } from 'react';
import { useWalletClient, usePublicClient, useAccount } from 'wagmi';

interface UsePurchaseTicketReturn {
  purchaseTicket: (eventId: number, ticketType: number, quantity?: number) => Promise<boolean>;
  isLoading: boolean;
  error: string | null;
  txHash: string | null;
  step: 'idle' | 'validating' | 'approving' | 'purchasing' | 'confirming' | 'success' | 'error';
}

export function usePurchaseTicket(): UsePurchaseTicketReturn {
  const { address } = useAccount();
  const { data: walletClient } = useWalletClient();
  const publicClient = usePublicClient();

  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [txHash, setTxHash] = useState<string | null>(null);
  const [step, setStep] = useState<UsePurchaseTicketReturn['step']>('idle');

  const purchaseTicket = async (
    eventId: number, 
    ticketType: number, 
    quantity: number = 1
  ): Promise<boolean> => {
    if (!address || !walletClient || !publicClient) {
      setError('Wallet not connected');
      return false;
    }

    setIsLoading(true);
    setError(null);
    setTxHash(null);

    try {
      // Step 1: Validate purchase
      setStep('validating');
      const validation = await validatePurchase(address, eventId, ticketType, quantity);

      if (!validation.canPurchase && !validation.needsApproval) {
        setError(validation.reason || 'Cannot purchase tickets');
        setStep('error');
        return false;
      }

      // Step 2: Handle USDC approval if needed
      if (validation.needsApproval) {
        setStep('approving');
        const approvalResult = await approveUSDC(walletClient, address, validation.totalCost);
        
        if (!approvalResult.success) {
          setError(approvalResult.error || 'USDC approval failed');
          setStep('error');
          return false;
        }

        // Wait for approval to be mined
        const approvalSuccess = await waitForApproval(
          publicClient, 
          approvalResult.txHash!, 
          address, 
          validation.totalCost
        );

        if (!approvalSuccess) {
          setError('USDC approval transaction failed');
          setStep('error');
          return false;
        }
      }

      // Step 3: Purchase tickets
      setStep('purchasing');
      const purchaseResult = quantity === 1 
        ? await purchaseTicket(walletClient, address, eventId, ticketType)
        : await purchaseTickets(walletClient, address, eventId, [ticketType], [quantity]);

      if (!purchaseResult.success) {
        setError(purchaseResult.error || 'Purchase failed');
        setStep('error');
        return false;
      }

      setTxHash(purchaseResult.txHash!);

      // Step 4: Wait for confirmation
      setStep('confirming');
      const receipt = await publicClient.waitForTransactionReceipt({
        hash: purchaseResult.txHash! as `0x${string}`,
        timeout: 60000,
      });

      if (receipt.status === 'reverted') {
        setError('Purchase transaction was reverted');
        setStep('error');
        return false;
      }

      setStep('success');
      return true;

    } catch (error) {
      console.error('Purchase error:', error);
      setError(error instanceof Error ? error.message : 'Unknown error occurred');
      setStep('error');
      return false;

    } finally {
      setIsLoading(false);
    }
  };

  return {
    purchaseTicket,
    isLoading,
    error,
    txHash,
    step,
  };
}
```

## React Component Examples

### Purchase Button Component

```typescript
import React from 'react';
import { usePurchaseTicket } from './hooks/usePurchaseTicket';

interface PurchaseButtonProps {
  eventId: number;
  ticketType: number;
  ticketName: string;
  price: bigint;
  available: number;
  disabled?: boolean;
  onSuccess?: () => void;
}

export function PurchaseButton({ 
  eventId, 
  ticketType, 
  ticketName, 
  price, 
  available, 
  disabled,
  onSuccess 
}: PurchaseButtonProps) {
  const { purchaseTicket, isLoading, error, txHash, step } = usePurchaseTicket();

  const handlePurchase = async () => {
    const success = await purchaseTicket(eventId, ticketType);
    if (success && onSuccess) {
      onSuccess();
    }
  };

  const getButtonText = () => {
    switch (step) {
      case 'validating': return 'Validating...';
      case 'approving': return 'Approving USDC...';
      case 'purchasing': return 'Purchasing...';
      case 'confirming': return 'Confirming...';
      case 'success': return 'Purchase Successful!';
      default: return `Buy ${ticketName} - ${formatUSDC(price)} USDC`;
    }
  };

  const isDisabled = disabled || isLoading || available === 0;

  return (
    <div className="purchase-section">
      <button
        onClick={handlePurchase}
        disabled={isDisabled}
        className={`purchase-btn ${step === 'success' ? 'success' : ''} ${isDisabled ? 'disabled' : ''}`}
      >
        {getButtonText()}
      </button>

      {available === 0 && (
        <p className="sold-out">SOLD OUT</p>
      )}

      {error && (
        <p className="error">Error: {error}</p>
      )}

      {txHash && (
        <p className="tx-hash">
          Transaction: 
          <a 
            href={`https://sepolia.etherscan.io/tx/${txHash}`} 
            target="_blank" 
            rel="noopener noreferrer"
          >
            {txHash.slice(0, 10)}...
          </a>
        </p>
      )}

      {step === 'success' && (
        <p className="success">
          🎉 Ticket purchased successfully! Check your wallet.
        </p>
      )}
    </div>
  );
}
```

### Multi-Ticket Purchase Component

```typescript
interface MultiPurchaseProps {
  eventId: number;
  tickets: TicketType[];
  onSuccess?: () => void;
}

export function MultiPurchaseComponent({ eventId, tickets, onSuccess }: MultiPurchaseProps) {
  const [quantities, setQuantities] = useState<Record<number, number>>({});
  const { purchaseTicket, isLoading, error, txHash, step } = usePurchaseTicket();

  const updateQuantity = (ticketType: number, quantity: number) => {
    setQuantities(prev => ({
      ...prev,
      [ticketType]: Math.max(0, Math.min(quantity, tickets[ticketType]?.available || 0))
    }));
  };

  const getTotalCost = () => {
    return Object.entries(quantities).reduce((total, [ticketType, quantity]) => {
      const ticket = tickets[parseInt(ticketType)];
      return total + (ticket ? ticket.price * BigInt(quantity) : 0n);
    }, 0n);
  };

  const handlePurchase = async () => {
    const purchaseItems = Object.entries(quantities)
      .filter(([_, qty]) => qty > 0)
      .map(([ticketType, quantity]) => ({ ticketType: parseInt(ticketType), quantity }));

    if (purchaseItems.length === 0) {
      alert('Please select at least one ticket');
      return;
    }

    // For simplicity, purchase one at a time (you could batch these)
    let allSuccessful = true;
    for (const { ticketType, quantity } of purchaseItems) {
      for (let i = 0; i < quantity; i++) {
        const success = await purchaseTicket(eventId, ticketType);
        if (!success) {
          allSuccessful = false;
          break;
        }
      }
      if (!allSuccessful) break;
    }

    if (allSuccessful && onSuccess) {
      onSuccess();
    }
  };

  return (
    <div className="multi-purchase">
      <h3>Select Tickets</h3>
      
      {tickets.map((ticket, index) => (
        <div key={index} className="ticket-selector">
          <div className="ticket-info">
            <h4>{ticket.name}</h4>
            <p>Price: {formatUSDC(ticket.price)} USDC</p>
            <p>Available: {ticket.available}</p>
          </div>
          
          <div className="quantity-controls">
            <button 
              onClick={() => updateQuantity(index, (quantities[index] || 0) - 1)}
              disabled={!quantities[index] || quantities[index] <= 0}
            >
              -
            </button>
            <span>{quantities[index] || 0}</span>
            <button 
              onClick={() => updateQuantity(index, (quantities[index] || 0) + 1)}
              disabled={(quantities[index] || 0) >= ticket.available}
            >
              +
            </button>
          </div>
        </div>
      ))}

      <div className="purchase-summary">
        <p>Total Cost: {formatUSDC(getTotalCost())} USDC</p>
        <button 
          onClick={handlePurchase} 
          disabled={isLoading || getTotalCost() === 0n}
          className="purchase-btn"
        >
          {isLoading ? `${step}...` : 'Purchase Selected Tickets'}
        </button>
      </div>

      {error && <p className="error">Error: {error}</p>}
      {txHash && (
        <p className="tx-hash">
          Last Transaction: 
          <a href={`https://sepolia.etherscan.io/tx/${txHash}`} target="_blank" rel="noopener noreferrer">
            View on Etherscan
          </a>
        </p>
      )}
    </div>
  );
}
```

## Error Handling & User Feedback

### Common Errors and Solutions

```typescript
export const PURCHASE_ERRORS = {
  WALLET_NOT_CONNECTED: 'Please connect your wallet',
  INSUFFICIENT_BALANCE: 'Insufficient USDC balance',
  INSUFFICIENT_ALLOWANCE: 'Please approve USDC spending',
  SOLD_OUT: 'Tickets are sold out',
  EVENT_LOCKED: 'Event is locked for purchases',
  TRANSACTION_FAILED: 'Transaction failed',
  NETWORK_ERROR: 'Network error occurred',
} as const;

export function getErrorMessage(error: any): string {
  const errorStr = error?.message || error?.toString() || '';
  
  if (errorStr.includes('User rejected')) {
    return 'Transaction was cancelled by user';
  }
  if (errorStr.includes('insufficient funds')) {
    return 'Insufficient funds for gas fees';
  }
  if (errorStr.includes('allowance')) {
    return PURCHASE_ERRORS.INSUFFICIENT_ALLOWANCE;
  }
  if (errorStr.includes('balance')) {
    return PURCHASE_ERRORS.INSUFFICIENT_BALANCE;
  }
  if (errorStr.includes('sold out')) {
    return PURCHASE_ERRORS.SOLD_OUT;
  }
  if (errorStr.includes('locked')) {
    return PURCHASE_ERRORS.EVENT_LOCKED;
  }
  
  return errorStr || PURCHASE_ERRORS.TRANSACTION_FAILED;
}
```

### Loading States Component

```typescript
export function PurchaseLoadingState({ step }: { step: string }) {
  const getStepInfo = (currentStep: string) => {
    switch (currentStep) {
      case 'validating':
        return { text: 'Checking ticket availability...', progress: 20 };
      case 'approving':
        return { text: 'Approving USDC spending...', progress: 40 };
      case 'purchasing':
        return { text: 'Purchasing tickets...', progress: 60 };
      case 'confirming':
        return { text: 'Waiting for confirmation...', progress: 80 };
      case 'success':
        return { text: 'Purchase completed!', progress: 100 };
      default:
        return { text: 'Processing...', progress: 0 };
    }
  };

  const { text, progress } = getStepInfo(step);

  return (
    <div className="purchase-loading">
      <div className="progress-bar">
        <div className="progress-fill" style={{ width: `${progress}%` }} />
      </div>
      <p>{text}</p>
    </div>
  );
}
```

## Testing Your Purchase Implementation

### 1. Test with Sepolia USDC

First, get some test USDC on Sepolia:

```typescript
// You'll need to use a Sepolia USDC faucet or mint function
// Check the USDC contract on Sepolia for available test functions

// Verify USDC balance
const balance = await publicClient.readContract({
  address: USDC_ADDRESS,
  abi: usdcPurchaseABI,
  functionName: 'balanceOf',
  args: [userAddress],
});

console.log(`USDC Balance: ${formatUSDC(balance)} USDC`);
```

### 2. Test Purchase Flow

```typescript
// Test the complete flow
async function testPurchaseFlow() {
  const eventId = 0; // Replace with actual event ID
  const ticketType = 0; // Replace with actual ticket type
  
  // 1. Validate
  const validation = await validatePurchase(userAddress, eventId, ticketType);
  console.log('Validation result:', validation);
  
  // 2. If needed, approve USDC
  if (validation.needsApproval) {
    const approval = await approveUSDC(walletClient, userAddress, validation.totalCost);
    console.log('Approval result:', approval);
  }
  
  // 3. Purchase
  const purchase = await purchaseTicket(walletClient, userAddress, eventId, ticketType);
  console.log('Purchase result:', purchase);
}
```

### 3. Monitor Transactions

```typescript
// Listen for purchase events
const unwatch = publicClient.watchContractEvent({
  address: FACTORY_ADDRESS,
  abi: factoryPurchaseABI,
  eventName: 'TicketPurchased',
  onLogs: logs => {
    logs.forEach(log => {
      console.log('Ticket purchased:', {
        buyer: log.args.buyer,
        eventId: log.args.eventId,
        ticketType: log.args.ticketType,
        quantity: log.args.quantity,
        totalCost: formatUSDC(log.args.totalCost),
      });
    });
  },
});

// Remember to unwatch when component unmounts
// unwatch();
```

## Production Checklist

- [ ] **Error Handling**: Implement comprehensive error catching and user-friendly messages
- [ ] **Loading States**: Show clear progress indicators during multi-step purchases
- [ ] **Transaction Monitoring**: Display transaction hashes and links to block explorer
- [ ] **Retry Logic**: Allow users to retry failed transactions
- [ ] **Gas Estimation**: Show estimated gas costs before transactions
- [ ] **Slippage Protection**: Handle price changes during purchase flow
- [ ] **Rate Limiting**: Implement client-side rate limiting for rapid clicks
- [ ] **Success Callbacks**: Refresh ticket counts and user balances after successful purchases
- [ ] **Mobile UX**: Ensure purchase flow works well on mobile wallets
- [ ] **Testing**: Test with different wallet types (MetaMask, WalletConnect, etc.)

# 🚨 Troubleshooting Purchase Failures

If you're getting contract reverts when purchasing tickets, here's a systematic debugging guide.

## Common Revert Causes & Solutions

### 1. **Wrong Function Name** ❌
**Error:** `"buyMultipleTickets" reverted`  
**Issue:** The function is called `buyTickets`, not `buyMultipleTickets`

```typescript
// ❌ WRONG
await walletClient.writeContract({
  address: TICKET_OPERATIONS_ADDRESS,
  abi: ticketOperationsABI,
  functionName: 'buyMultipleTickets', // This function doesn't exist!
  args: [eventId, ticketTypes, quantities],
});

// ✅ CORRECT
await walletClient.writeContract({
  address: TICKET_OPERATIONS_ADDRESS,
  abi: ticketOperationsABI,
  functionName: 'buyTickets', // Correct function name
  args: [eventId, ticketTypes, quantities],
});
```

### 2. **Calling Wrong Contract** ❌
**Issue:** You might be calling the Factory instead of TicketOperations

```typescript
// ❌ WRONG - Don't call buyTickets on Factory
const FACTORY_ADDRESS = "0x17a6b3aaf32b356f501e362b8e20c789347e782d";
await walletClient.writeContract({
  address: FACTORY_ADDRESS, // This won't work!
  functionName: 'buyTickets',
});

// ✅ CORRECT - Call TicketOperations contract
const TICKET_OPERATIONS_ADDRESS = "0x48228d825dA48B3dc99c7d29C10705c0212C79D7";
await walletClient.writeContract({
  address: TICKET_OPERATIONS_ADDRESS, // Correct contract
  functionName: 'buyTickets',
});
```

### 3. **Insufficient USDC Allowance** ❌
**Error Code:** `!P` (Payment failed)

```typescript
// Check allowance first
const allowance = await publicClient.readContract({
  address: USDC_ADDRESS,
  abi: usdcABI,
  functionName: 'allowance',
  args: [userAddress, TICKET_OPERATIONS_ADDRESS], // Note: operations contract, not factory!
});

const totalCost = ticketPrice * BigInt(quantity);
if (allowance < totalCost) {
  // Approve TicketOperations contract, not Factory!
  await walletClient.writeContract({
    address: USDC_ADDRESS,
    abi: usdcABI,
    functionName: 'approve',
    args: [TICKET_OPERATIONS_ADDRESS, totalCost * 110n / 100n], // 10% buffer
  });
}
```

### 4. **Event Doesn't Exist** ❌
**Error Code:** `!T` or generic revert

```typescript
// Check if event exists
const eventCount = await publicClient.readContract({
  address: FACTORY_ADDRESS,
  abi: factoryABI,
  functionName: 'getEventCount',
});

if (eventId >= Number(eventCount)) {
  throw new Error(`Event ${eventId} doesn't exist. Only ${eventCount} events created.`);
}
```

### 5. **Ticket Office Closed** ❌
**Error Code:** `!O` (Office closed)

```typescript
// Check if ticket office is open
const isOpen = await publicClient.readContract({
  address: FACTORY_ADDRESS,
  abi: factoryABI,
  functionName: 'ticketOfficeOpen',
});

if (!isOpen) {
  throw new Error('Ticket office is currently closed');
}
```

### 6. **Event Locked** ❌
**Error Code:** `!L` (Locked)

```typescript
// Get event data contract
const eventDataAddress = await publicClient.readContract({
  address: FACTORY_ADDRESS,
  abi: factoryABI,
  functionName: 'getEventData',
  args: [BigInt(eventId)],
});

// Check if event is locked
const isLocked = await publicClient.readContract({
  address: eventDataAddress,
  abi: eventDataABI,
  functionName: 'locked',
});

if (isLocked) {
  throw new Error('Event is locked for purchases');
}
```

### 7. **Invalid Ticket Type** ❌
**Error Code:** `!T` (Invalid ticket type)

```typescript
// Check ticket count for the event
const ticketCount = await publicClient.readContract({
  address: eventDataAddress,
  abi: eventDataABI,
  functionName: 'getTicketCount',
});

if (ticketType >= Number(ticketCount)) {
  throw new Error(`Invalid ticket type ${ticketType}. Event only has ${ticketCount} ticket types (0-${ticketCount-1})`);
}
```

### 8. **Insufficient Ticket Capacity** ❌
**Error Code:** `!Q` (Quantity/capacity exceeded)

```typescript
// Check availability
const [capacity, sold] = await Promise.all([
  publicClient.readContract({
    address: eventDataAddress,
    abi: eventDataABI,
    functionName: 'getTicketCapacity',
    args: [BigInt(ticketType)],
  }),
  publicClient.readContract({
    address: eventDataAddress,
    abi: eventDataABI,
    functionName: 'getTicketsSold',
    args: [BigInt(ticketType)],
  }),
]);

const available = Number(capacity) - Number(sold);
if (quantity > available) {
  throw new Error(`Only ${available} tickets available, requested ${quantity}`);
}
```

## Complete Pre-Purchase Validation Function

```typescript
interface ValidationResult {
  canPurchase: boolean;
  error?: string;
  details: {
    eventExists: boolean;
    officeOpen: boolean;
    eventLocked: boolean;
    validTicketType: boolean;
    sufficientCapacity: boolean;
    sufficientBalance: boolean;
    sufficientAllowance: boolean;
  };
}

async function validateTicketPurchase(
  userAddress: `0x${string}`,
  eventId: number,
  ticketTypes: number[],
  quantities: number[]
): Promise<ValidationResult> {
  const result: ValidationResult = {
    canPurchase: false,
    details: {
      eventExists: false,
      officeOpen: false,
      eventLocked: false,
      validTicketType: false,
      sufficientCapacity: false,
      sufficientBalance: false,
      sufficientAllowance: false,
    },
  };

  try {
    // 1. Check if event exists
    const eventCount = await publicClient.readContract({
      address: FACTORY_ADDRESS,
      abi: factoryABI,
      functionName: 'getEventCount',
    });

    if (eventId >= Number(eventCount)) {
      result.error = `Event ${eventId} doesn't exist`;
      return result;
    }
    result.details.eventExists = true;

    // 2. Check if office is open
    const isOfficeOpen = await publicClient.readContract({
      address: FACTORY_ADDRESS,
      abi: factoryABI,
      functionName: 'ticketOfficeOpen',
    });

    if (!isOfficeOpen) {
      result.error = 'Ticket office is closed';
      return result;
    }
    result.details.officeOpen = true;

    // 3. Get event data
    const eventDataAddress = await publicClient.readContract({
      address: FACTORY_ADDRESS,
      abi: factoryABI,
      functionName: 'getEventData',
      args: [BigInt(eventId)],
    });

    // 4. Check if event is locked
    const isLocked = await publicClient.readContract({
      address: eventDataAddress,
      abi: eventDataABI,
      functionName: 'locked',
    });

    if (isLocked) {
      result.error = 'Event is locked';
      return result;
    }
    result.details.eventLocked = false;

    // 5. Check ticket types and capacity
    const ticketCount = await publicClient.readContract({
      address: eventDataAddress,
      abi: eventDataABI,
      functionName: 'getTicketCount',
    });

    for (const ticketType of ticketTypes) {
      if (ticketType >= Number(ticketCount)) {
        result.error = `Invalid ticket type ${ticketType}`;
        return result;
      }
    }
    result.details.validTicketType = true;

    // Check capacity for each ticket type
    let totalCost = 0n;
    for (let i = 0; i < ticketTypes.length; i++) {
      const ticketType = ticketTypes[i];
      const quantity = quantities[i];

      const [price, capacity, sold] = await Promise.all([
        publicClient.readContract({
          address: eventDataAddress,
          abi: eventDataABI,
          functionName: 'getTicketPrice',
          args: [BigInt(ticketType)],
        }),
        publicClient.readContract({
          address: eventDataAddress,
          abi: eventDataABI,
          functionName: 'getTicketCapacity',
          args: [BigInt(ticketType)],
        }),
        publicClient.readContract({
          address: eventDataAddress,
          abi: eventDataABI,
          functionName: 'getTicketsSold',
          args: [BigInt(ticketType)],
        }),
      ]);

      const available = Number(capacity) - Number(sold);
      if (quantity > available) {
        result.error = `Only ${available} tickets available for type ${ticketType}, requested ${quantity}`;
        return result;
      }

      totalCost += price * BigInt(quantity);
    }
    result.details.sufficientCapacity = true;

    // 6. Check USDC balance
    const balance = await publicClient.readContract({
      address: USDC_ADDRESS,
      abi: usdcABI,
      functionName: 'balanceOf',
      args: [userAddress],
    });

    if (balance < totalCost) {
      result.error = `Insufficient USDC balance. Need ${formatUSDC(totalCost)}, have ${formatUSDC(balance)}`;
      return result;
    }
    result.details.sufficientBalance = true;

    // 7. Check USDC allowance for TicketOperations contract
    const allowance = await publicClient.readContract({
      address: USDC_ADDRESS,
      abi: usdcABI,
      functionName: 'allowance',
      args: [userAddress, TICKET_OPERATIONS_ADDRESS],
    });

    if (allowance < totalCost) {
      result.error = `Insufficient USDC allowance. Need ${formatUSDC(totalCost)}, have ${formatUSDC(allowance)}`;
      return result;
    }
    result.details.sufficientAllowance = true;

    result.canPurchase = true;
    return result;

  } catch (error) {
    result.error = `Validation failed: ${error instanceof Error ? error.message : 'Unknown error'}`;
    return result;
  }
}
```

## Debug Your Specific Error

Based on your error log, here's what to check:

```typescript
// Your call: buyMultipleTickets(1, ["0"], ["2"])
// Contract: 0x48228d825dA48B3dc99c7d29C10705c0212C79D7
// Sender: 0x0000000650D7c65Aff5D0EacA6F345bbB6b83783

const debugInfo = await validateTicketPurchase(
  "0x0000000650D7c65Aff5D0EacA6F345bbB6b83783", // Your address
  1, // Event ID 1
  [0], // Ticket type 0
  [2]  // Quantity 2
);

console.log('Debug Results:', debugInfo);

// Also check contract addresses
console.log('Factory address expected:', FACTORY_ADDRESS);
console.log('TicketOps address calling:', "0x48228d825dA48B3dc99c7d29C10705c0212C79D7");

// Check what factory this TicketOps points to
const factory = await publicClient.readContract({
  address: "0x48228d825dA48B3dc99c7d29C10705c0212C79D7",
  abi: [{ 
    inputs: [], 
    name: 'factory', 
    outputs: [{ type: 'address' }], 
    stateMutability: 'view', 
    type: 'function' 
  }],
  functionName: 'factory',
});
console.log('TicketOps points to factory:', factory);
```

## Quick Fix for Your Error

1. **Change function name to `buyTickets`**
2. **Make sure you're approving the TicketOperations contract, not Factory**
3. **Verify event ID 1 actually exists**

```typescript
// ✅ Corrected call
await walletClient.writeContract({
  address: "0x48228d825dA48B3dc99c7d29C10705c0212C79D7", // TicketOperations
  abi: ticketOperationsABI,
  functionName: 'buyTickets', // NOT buyMultipleTickets
  args: [BigInt(1), [BigInt(0)], [BigInt(2)]], // Ensure BigInt conversion
});
```

## Cast Commands for Manual Testing

```bash
# Check if event 1 exists
cast call FACTORY_ADDRESS "getEventCount()" --rpc-url $RPC_URL

# Check if ticket office is open  
cast call FACTORY_ADDRESS "ticketOfficeOpen()" --rpc-url $RPC_URL

# Get event data address for event 1
cast call FACTORY_ADDRESS "getEventData(uint256)" 1 --rpc-url $RPC_URL

# Check if event is locked
cast call EVENT_DATA_ADDRESS "locked()" --rpc-url $RPC_URL

# Check your USDC balance
cast call USDC_ADDRESS "balanceOf(address)" YOUR_ADDRESS --rpc-url $RPC_URL

# Check USDC allowance for TicketOperations (NOT Factory!)
cast call USDC_ADDRESS "allowance(address,address)" YOUR_ADDRESS 0x48228d825dA48B3dc99c7d29C10705c0212C79D7 --rpc-url $RPC_URL
```

# 🎟️ NFT Ticket Balance Queries

This section shows how to check NFT ticket balances that were minted when users purchased tickets. Each ticket purchase mints an ERC1155 NFT to the buyer's wallet.

## ERC1155 Token Contract Structure

When an event is created, it generates:
- **EventData Contract** - Stores all event metadata and ticket information
- **ERC1155Token Contract** - The NFT contract that holds all ticket tokens

Each ticket type has a unique token ID:
- Ticket Type 0 (e.g., "General Admission") = Token ID 0
- Ticket Type 1 (e.g., "VIP") = Token ID 1
- etc.

## Getting the Token Contract Address

First, you need to get the ERC1155 token contract address from the EventData contract:

```typescript
// Get EventData address from factory
const eventDataAddress = await publicClient.readContract({
  address: FACTORY_ADDRESS,
  abi: factoryABI,
  functionName: 'getEventData',
  args: [BigInt(eventId)],
});

// Get token contract address from EventData
const tokenContractAddress = await publicClient.readContract({
  address: eventDataAddress,
  abi: eventDataABI,
  functionName: 'ticketToken',
});

console.log('ERC1155 Token Contract:', tokenContractAddress);
```

## Single User Balance Query

### Check Single Ticket Type Balance

```typescript
// Check how many GA tickets (token ID 0) a user owns
const gaBalance = await publicClient.readContract({
  address: tokenContractAddress,
  abi: erc1155TokenABI,
  functionName: 'balanceOf',
  args: [userAddress, BigInt(0)], // Token ID 0 = GA tickets
});

console.log(`User owns ${gaBalance} GA tickets`);

// Check VIP tickets (token ID 1)
const vipBalance = await publicClient.readContract({
  address: tokenContractAddress,
  abi: erc1155TokenABI,
  functionName: 'balanceOf',
  args: [userAddress, BigInt(1)], // Token ID 1 = VIP tickets
});

console.log(`User owns ${vipBalance} VIP tickets`);
```

### Check All Ticket Types for a User

```typescript
async function getUserTicketBalances(
  userAddress: `0x${string}`,
  eventId: number
): Promise<Array<{ ticketType: number; ticketName: string; balance: number }>> {
  // Get contracts
  const eventDataAddress = await publicClient.readContract({
    address: FACTORY_ADDRESS,
    abi: factoryABI,
    functionName: 'getEventData',
    args: [BigInt(eventId)],
  });

  const [tokenContractAddress, ticketCount, ticketNames] = await Promise.all([
    publicClient.readContract({
      address: eventDataAddress,
      abi: eventDataABI,
      functionName: 'ticketToken',
    }),
    publicClient.readContract({
      address: eventDataAddress,
      abi: eventDataABI,
      functionName: 'getTicketCount',
    }),
    publicClient.readContract({
      address: eventDataAddress,
      abi: eventDataABI,
      functionName: 'getTicketNames',
    }),
  ]);

  // Check balance for each ticket type
  const balances = [];
  for (let ticketType = 0; ticketType < Number(ticketCount); ticketType++) {
    const balance = await publicClient.readContract({
      address: tokenContractAddress,
      abi: erc1155TokenABI,
      functionName: 'balanceOf',
      args: [userAddress, BigInt(ticketType)],
    });

    if (balance > 0n) {
      balances.push({
        ticketType,
        ticketName: ticketNames[ticketType],
        balance: Number(balance),
      });
    }
  }

  return balances;
}

// Usage
const userTickets = await getUserTicketBalances(userAddress, eventId);
console.log('User ticket balances:', userTickets);
// Example output: [
//   { ticketType: 0, ticketName: "General Admission", balance: 2 },
//   { ticketType: 1, ticketName: "VIP", balance: 1 }
// ]
```

## Batch Balance Query (More Efficient)

For checking multiple balances at once, use `balanceOfBatch`:

```typescript
async function getUserTicketBalancesBatch(
  userAddress: `0x${string}`,
  eventId: number
): Promise<Array<{ ticketType: number; ticketName: string; balance: number }>> {
  // Get contracts and ticket info
  const eventDataAddress = await publicClient.readContract({
    address: FACTORY_ADDRESS,
    abi: factoryABI,
    functionName: 'getEventData',
    args: [BigInt(eventId)],
  });

  const [tokenContractAddress, ticketCount, ticketNames] = await Promise.all([
    publicClient.readContract({
      address: eventDataAddress,
      abi: eventDataABI,
      functionName: 'ticketToken',
    }),
    publicClient.readContract({
      address: eventDataAddress,
      abi: eventDataABI,
      functionName: 'getTicketCount',
    }),
    publicClient.readContract({
      address: eventDataAddress,
      abi: eventDataABI,
      functionName: 'getTicketNames',
    }),
  ]);

  // Prepare batch query arrays
  const accounts = Array(Number(ticketCount)).fill(userAddress);
  const tokenIds = Array.from({ length: Number(ticketCount) }, (_, i) => BigInt(i));

  // Single batch call to get all balances
  const balances = await publicClient.readContract({
    address: tokenContractAddress,
    abi: erc1155TokenABI,
    functionName: 'balanceOfBatch',
    args: [accounts, tokenIds],
  });

  // Filter and format results
  return balances
    .map((balance, index) => ({
      ticketType: index,
      ticketName: ticketNames[index],
      balance: Number(balance),
    }))
    .filter(ticket => ticket.balance > 0);
}
```

## Command Line Queries (Cast)

### Get Token Contract Address
```bash
# Get EventData address for event ID 0
EVENT_DATA=$(cast call 0x17a6b3aaf32b356f501e362b8e20c789347e782d "getEventData(uint256)" 0 --rpc-url $SEPOLIA_RPC)

# Get token contract address from EventData
TOKEN_CONTRACT=$(cast call $EVENT_DATA "ticketToken()" --rpc-url $SEPOLIA_RPC)

echo "Token Contract: $TOKEN_CONTRACT"
```

### Check User Balance
```bash
# Check GA ticket balance (token ID 0) for user
cast call $TOKEN_CONTRACT "balanceOf(address,uint256)" 0x1234...USER_ADDRESS 0 --rpc-url $SEPOLIA_RPC

# Check VIP ticket balance (token ID 1) for user  
cast call $TOKEN_CONTRACT "balanceOf(address,uint256)" 0x1234...USER_ADDRESS 1 --rpc-url $SEPOLIA_RPC

# Check multiple balances at once using balanceOfBatch
# This requires creating arrays, so it's more complex with cast
```

### Get All Ticket Types
```bash
# Get number of ticket types for the event
cast call $EVENT_DATA "getTicketCount()" --rpc-url $SEPOLIA_RPC

# Get ticket names array
cast call $EVENT_DATA "getTicketNames()" --rpc-url $SEPOLIA_RPC
```

## React Hooks for NFT Balances

### Hook for Single User's Tickets

```typescript
import { useQuery } from '@tanstack/react-query';
import { useAccount } from 'wagmi';

export function useUserEventTickets(eventId: number) {
  const { address } = useAccount();

  return useQuery({
    queryKey: ['userTickets', address, eventId],
    queryFn: async () => {
      if (!address) return [];
      return await getUserTicketBalancesBatch(address, eventId);
    },
    enabled: !!address && eventId >= 0,
    staleTime: 30_000, // 30 seconds
    refetchInterval: 60_000, // Refetch every minute
  });
}

// Usage in component
function UserTicketsDisplay({ eventId }: { eventId: number }) {
  const { data: userTickets, isLoading, error } = useUserEventTickets(eventId);

  if (isLoading) return <div>Loading your tickets...</div>;
  if (error) return <div>Error loading tickets</div>;
  if (!userTickets || userTickets.length === 0) {
    return <div>You don't own any tickets for this event</div>;
  }

  return (
    <div className="user-tickets">
      <h3>Your Tickets</h3>
      {userTickets.map((ticket) => (
        <div key={ticket.ticketType} className="ticket-item">
          <span className="ticket-name">{ticket.ticketName}</span>
          <span className="ticket-count">× {ticket.balance}</span>
        </div>
      ))}
    </div>
  );
}
```

### Hook for Checking Specific Ticket Ownership

```typescript
export function useOwnsTicket(eventId: number, ticketType: number) {
  const { address } = useAccount();

  return useQuery({
    queryKey: ['ownsTicket', address, eventId, ticketType],
    queryFn: async () => {
      if (!address) return false;
      
      const eventDataAddress = await publicClient.readContract({
        address: FACTORY_ADDRESS,
        abi: factoryABI,
        functionName: 'getEventData',
        args: [BigInt(eventId)],
      });

      const tokenContractAddress = await publicClient.readContract({
        address: eventDataAddress,
        abi: eventDataABI,
        functionName: 'ticketToken',
      });

      const balance = await publicClient.readContract({
        address: tokenContractAddress,
        abi: erc1155TokenABI,
        functionName: 'balanceOf',
        args: [address, BigInt(ticketType)],
      });

      return Number(balance) > 0;
    },
    enabled: !!address && eventId >= 0 && ticketType >= 0,
  });
}

// Usage - show different UI for ticket holders
function TicketGatedContent({ eventId, ticketType, children }) {
  const { data: ownsTicket, isLoading } = useOwnsTicket(eventId, ticketType);

  if (isLoading) return <div>Checking ticket ownership...</div>;
  if (!ownsTicket) return <div>This content is only for ticket holders</div>;

  return <>{children}</>;
}
```

## Complete NFT Balance Component

```typescript
interface NFTTicketDisplayProps {
  eventId: number;
  userAddress?: `0x${string}`;
}

export function NFTTicketDisplay({ eventId, userAddress }: NFTTicketDisplayProps) {
  const [tickets, setTickets] = useState<Array<{
    ticketType: number;
    ticketName: string;
    balance: number;
    tokenId: number;
  }>>([]);
  const [loading, setLoading] = useState(true);
  const [tokenContract, setTokenContract] = useState<string>('');

  useEffect(() => {
    async function loadTickets() {
      if (!userAddress) return;
      
      try {
        setLoading(true);
        
        // Get token contract
        const eventDataAddress = await publicClient.readContract({
          address: FACTORY_ADDRESS,
          abi: factoryABI,
          functionName: 'getEventData',
          args: [BigInt(eventId)],
        });

        const tokenContractAddress = await publicClient.readContract({
          address: eventDataAddress,
          abi: eventDataABI,
          functionName: 'ticketToken',
        });

        setTokenContract(tokenContractAddress);

        // Get user's tickets
        const userTickets = await getUserTicketBalancesBatch(userAddress, eventId);
        
        // Add token IDs for easy reference
        const ticketsWithIds = userTickets.map(ticket => ({
          ...ticket,
          tokenId: ticket.ticketType,
        }));
        
        setTickets(ticketsWithIds);
      } catch (error) {
        console.error('Error loading NFT tickets:', error);
      } finally {
        setLoading(false);
      }
    }

    loadTickets();
  }, [userAddress, eventId]);

  if (loading) {
    return <div className="loading">Loading your NFT tickets...</div>;
  }

  if (tickets.length === 0) {
    return (
      <div className="no-tickets">
        <p>You don't own any NFT tickets for this event</p>
        <p>Purchase tickets to receive NFTs in your wallet</p>
      </div>
    );
  }

  return (
    <div className="nft-tickets">
      <h3>Your NFT Tickets</h3>
      <p className="contract-info">
        Token Contract: 
        <a 
          href={`https://sepolia.etherscan.io/address/${tokenContract}`}
          target="_blank"
          rel="noopener noreferrer"
          className="contract-link"
        >
          {tokenContract.slice(0, 10)}...
        </a>
      </p>
      
      {tickets.map((ticket) => (
        <div key={ticket.ticketType} className="nft-ticket-card">
          <div className="ticket-header">
            <h4>{ticket.ticketName}</h4>
            <span className="token-id">Token ID: {ticket.tokenId}</span>
          </div>
          
          <div className="ticket-details">
            <p className="balance">Quantity: {ticket.balance}</p>
            <p className="contract-call">
              Contract Call: balanceOf({userAddress.slice(0, 6)}..., {ticket.tokenId})
            </p>
          </div>

          <div className="view-links">
            <a 
              href={`https://sepolia.etherscan.io/token/${tokenContract}?a=${userAddress}`}
              target="_blank"
              rel="noopener noreferrer"
            >
              View on Etherscan
            </a>
            <a 
              href={`https://testnets.opensea.io/assets/sepolia/${tokenContract}/${ticket.tokenId}`}
              target="_blank"
              rel="noopener noreferrer"
            >
              View on OpenSea
            </a>
          </div>
        </div>
      ))}
    </div>
  );
}
```

## Advanced Queries

### Get All Holders of a Specific Ticket Type

```typescript
// This requires indexing transfer events - more complex query
async function getTicketHolders(eventId: number, ticketType: number) {
  const eventDataAddress = await publicClient.readContract({
    address: FACTORY_ADDRESS,
    abi: factoryABI,
    functionName: 'getEventData',
    args: [BigInt(eventId)],
  });

  const tokenContractAddress = await publicClient.readContract({
    address: eventDataAddress,
    abi: eventDataABI,
    functionName: 'ticketToken',
  });

  // Get TransferSingle events to find all holders
  const transferLogs = await publicClient.getLogs({
    address: tokenContractAddress,
    event: {
      type: 'event',
      name: 'TransferSingle',
      inputs: [
        { indexed: true, name: 'operator', type: 'address' },
        { indexed: true, name: 'from', type: 'address' },
        { indexed: true, name: 'to', type: 'address' },
        { indexed: false, name: 'id', type: 'uint256' },
        { indexed: false, name: 'value', type: 'uint256' },
      ],
    },
    fromBlock: 'earliest',
    toBlock: 'latest',
  });

  // Filter for specific ticket type and mint transactions (from = 0x0)
  const holders = new Set<string>();
  transferLogs.forEach(log => {
    if (Number(log.args.id) === ticketType && log.args.from === '0x0000000000000000000000000000000000000000') {
      holders.add(log.args.to);
    }
  });

  return Array.from(holders);
}
```

### Real-time Balance Updates

```typescript
// Listen for TransferSingle events to update balances in real-time
export function useRealtimeTicketBalances(userAddress: `0x${string}`, eventId: number) {
  const [balances, setBalances] = useState<Record<number, number>>({});

  useEffect(() => {
    if (!userAddress) return;

    async function setupListener() {
      const eventDataAddress = await publicClient.readContract({
        address: FACTORY_ADDRESS,
        abi: factoryABI,
        functionName: 'getEventData',
        args: [BigInt(eventId)],
      });

      const tokenContractAddress = await publicClient.readContract({
        address: eventDataAddress,
        abi: eventDataABI,
        functionName: 'ticketToken',
      });

      // Initial load
      const initialBalances = await getUserTicketBalancesBatch(userAddress, eventId);
      const balanceMap: Record<number, number> = {};
      initialBalances.forEach(ticket => {
        balanceMap[ticket.ticketType] = ticket.balance;
      });
      setBalances(balanceMap);

      // Listen for new transfers
      const unwatch = publicClient.watchContractEvent({
        address: tokenContractAddress,
        abi: erc1155TokenABI,
        eventName: 'TransferSingle',
        args: { to: userAddress },
        onLogs: (logs) => {
          logs.forEach(log => {
            const tokenId = Number(log.args.id);
            const value = Number(log.args.value);
            setBalances(prev => ({
              ...prev,
              [tokenId]: (prev[tokenId] || 0) + value,
            }));
          });
        },
      });

      return unwatch;
    }

    const cleanupPromise = setupListener();
    return () => {
      cleanupPromise.then(cleanup => cleanup());
    };
  }, [userAddress, eventId]);

  return balances;
}
```

## Summary: NFT Balance Query Methods

| Method | Use Case | Efficiency |
|--------|----------|------------|
| `balanceOf` | Single ticket type check | ⭐⭐⭐ |
| `balanceOfBatch` | Multiple ticket types for one user | ⭐⭐⭐⭐⭐ |
| Event logs | Historical analysis, all holders | ⭐⭐ |
| Real-time listeners | Live balance updates | ⭐⭐⭐⭐ |

**Key Points:**
- Each ticket purchase mints an ERC1155 NFT with `tokenId = ticketType`
- Use `balanceOf(userAddress, tokenId)` to check ownership
- Use `balanceOfBatch` for efficient multi-type queries
- NFTs are tradeable and viewable on OpenSea/Etherscan
- Balance queries work exactly like any ERC1155 token

## Testing on Sepolia

```bash
# Get event data address
EVENT_DATA=$(cast call 0x17a6b3aaf32b356f501e362b8e20c789347e782d "getEventData(uint256)" 0 --rpc-url $SEPOLIA_RPC)

# Get token contract
TOKEN=$(cast call $EVENT_DATA "ticketToken()" --rpc-url $SEPOLIA_RPC)

# Check user balance for token ID 0 (GA tickets)
cast call $TOKEN "balanceOf(address,uint256)" YOUR_ADDRESS 0 --rpc-url $SEPOLIA_RPC

# View on Etherscan
echo "View token on Etherscan: https://sepolia.etherscan.io/address/$TOKEN"
```

## Testing on Sepolia

```bash
# Get event count
cast call 0x17a6b3aaf32b356f501e362b8e20c789347e782d "getEventCount()" --rpc-url $SEPOLIA_RPC

# Get event data address for event ID 0
cast call 0x17a6b3aaf32b356f501e362b8e20c789347e782d "getEventData(uint256)" 0 --rpc-url $SEPOLIA_RPC

# Get event date from EventData contract
cast call <EVENT_DATA_ADDRESS> "getEventDate()" --rpc-url $SEPOLIA_RPC

# Check USDC balance
cast call 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238 "balanceOf(address)" <USER_ADDRESS> --rpc-url $SEPOLIA_RPC

# Check USDC allowance
cast call 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238 "allowance(address,address)" <USER_ADDRESS> 0x17a6b3aaf32b356f501e362b8e20c789347e782d --rpc-url $SEPOLIA_RPC
```
