/**
 * Complete ABIs for Cheers Finance Ticket System
 * Copy these into your frontend project
 */

// ============ FACTORY ABI ============
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

// ============ EVENT DATA ABI ============
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

// ============ ERC1155 TOKEN ABI ============
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

// ============ TICKET OPERATIONS ABI ============
export const ticketOperationsABI = [
  {
    inputs: [{ name: '_factory', type: 'address' }],
    stateMutability: 'nonpayable',
    type: 'constructor',
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
  {
    inputs: [{ name: '_newFactory', type: 'address' }],
    name: 'setFactory',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    anonymous: false,
    inputs: [
      { indexed: true, name: 'eventId', type: 'uint256' },
      { indexed: true, name: 'buyer', type: 'address' },
      { indexed: false, name: 'ticketType', type: 'uint256' },
      { indexed: false, name: 'quantity', type: 'uint256' },
    ],
    name: 'TicketPurchased',
    type: 'event',
  },
] as const;

// ============ ADMIN OPERATIONS ABI ============
export const adminOperationsABI = [
  {
    inputs: [{ name: '_factory', type: 'address' }],
    stateMutability: 'nonpayable',
    type: 'constructor',
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
      { name: 'eventId', type: 'uint256' },
      { name: 'user', type: 'address' },
      { name: 'ticketType', type: 'uint256' },
    ],
    name: 'addCompTicket',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [{ name: 'eventId', type: 'uint256' }],
    name: 'lockEvent',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      { name: 'eventId', type: 'uint256' },
      { name: 'performer', type: 'string' },
    ],
    name: 'addPerformer',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
] as const;

// ============ USDC ABI (ERC20) ============
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
    inputs: [
      { name: 'to', type: 'address' },
      { name: 'amount', type: 'uint256' },
    ],
    name: 'transfer',
    outputs: [{ type: 'bool' }],
    stateMutability: 'nonpayable',
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
  {
    anonymous: false,
    inputs: [
      { indexed: true, name: 'from', type: 'address' },
      { indexed: true, name: 'to', type: 'address' },
      { indexed: false, name: 'value', type: 'uint256' },
    ],
    name: 'Transfer',
    type: 'event',
  },
] as const;

// ============ CONTRACT ADDRESSES ============
export const CONTRACT_ADDRESSES = {
  sepolia: {
    factory: '0x17a6b3aaf32b356f501e362b8e20c789347e782d',
    ticketOperations: '0x...', // Add after deployment
    adminOperations: '0x...', // Add after deployment
    usdc: '0x...', // Your USDC address on Sepolia
  },
  mainnet: {
    factory: '0x...', // Add after mainnet deployment
    ticketOperations: '0x...',
    adminOperations: '0x...',
    usdc: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48', // Real USDC on mainnet
  },
} as const;

// ============ TYPESCRIPT TYPES ============
export interface EventDetails {
  name: string;
  owner: `0x${string}`;
  eventDate: bigint;
  ticketInformation: {
    ticketNames: string[];
    ticketCapacities: bigint[];
    ticketPrices: bigint[];
    ticketsSold: bigint[];
    feePercentages: bigint[];
  };
  locationDetails: {
    venue: string;
  };
  performers: string[];
  keywords: string[];
  categories: string[];
  eventDescription: string;
  eventType: string;
}
