# Wagmi Integration Guide - TicketOffice Factory Pattern

Complete guide for integrating the new TicketOfficeFactory and EventContract system with wagmi v2.

## Table of Contents
1. [Setup & Configuration](#setup--configuration)
2. [Contract ABIs](#contract-abis)
3. [Reading Contract Data](#reading-contract-data)
4. [Writing to Contracts](#writing-to-contracts)
5. [Complete Workflows](#complete-workflows)
6. [Custom Hooks](#custom-hooks)
7. [TypeScript Types](#typescript-types)
8. [Error Handling](#error-handling)

---

## Setup & Configuration

### Installation
```bash
npm install wagmi viem@2.x @tanstack/react-query
```

### Wagmi Config
```typescript
import { http, createConfig } from 'wagmi'
import { mainnet, sepolia } from 'wagmi/chains'
import { injected, walletConnect } from 'wagmi/connectors'

export const config = createConfig({
  chains: [mainnet, sepolia],
  connectors: [
    injected(),
    walletConnect({ projectId: 'YOUR_PROJECT_ID' }),
  ],
  transports: {
    [mainnet.id]: http(),
    [sepolia.id]: http(),
  },
})
```

### Contract Addresses
```typescript
export const ADDRESSES = {
  mainnet: {
    factory: '0x...', // Your mainnet factory address
    usdc: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
  },
  sepolia: {
    factory: '0x17a6B3AAf32b356f501E362B8E20C789347E782D',
    usdc: '0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238',
  },
} as const
```

---

## Contract ABIs

### TicketOfficeFactory ABI
```typescript
export const FACTORY_ABI = [
  {
    type: 'function',
    name: 'registerEvent',
    inputs: [{ name: 'eventContract', type: 'address' }],
    outputs: [{ name: '', type: 'uint256' }],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'getEventContract',
    inputs: [{ name: 'eventId', type: 'uint256' }],
    outputs: [{ name: '', type: 'address' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    name: 'getAllEventContracts',
    inputs: [],
    outputs: [{ name: '', type: 'address[]' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    name: 'toggleOffice',
    inputs: [],
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'ticketOfficeOpen',
    inputs: [],
    outputs: [{ name: '', type: 'bool' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    name: 'nextEventId',
    inputs: [],
    outputs: [{ name: '', type: 'uint256' }],
    stateMutability: 'view',
  },
] as const
```

### EventContract ABI (Essential Functions)
```typescript
export const EVENT_CONTRACT_ABI = [
  // View functions
  {
    type: 'function',
    name: 'getEventDetails',
    inputs: [],
    outputs: [
      {
        name: '',
        type: 'tuple',
        components: [
          { name: 'eventName', type: 'string' },
          { name: 'eventSymbol', type: 'string' },
          { name: 'venueLocation', type: 'string' },
          { name: 'eventDate', type: 'uint256' },
          { name: 'eventCapacity', type: 'uint256' },
          { name: 'ticketsSold', type: 'uint256' },
          { name: 'ticketContractAddress', type: 'address' },
        ],
      },
    ],
    stateMutability: 'view',
  },
  {
    type: 'function',
    name: 'getTicketPrice',
    inputs: [{ name: 'ticketType', type: 'uint256' }],
    outputs: [{ name: '', type: 'uint256' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    name: 'getTicketQuantity',
    inputs: [{ name: 'ticketType', type: 'uint256' }],
    outputs: [{ name: '', type: 'uint256' }],
    stateMutability: 'view',
  },
  // Write functions
  {
    type: 'function',
    name: 'buyTicket',
    inputs: [{ name: 'ticketType', type: 'uint256' }],
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'buyTickets',
    inputs: [
      { name: 'ticketTypes', type: 'uint256[]' },
      { name: 'quantities', type: 'uint256[]' },
    ],
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'redeemCompTicket',
    inputs: [{ name: 'ticketType', type: 'uint256' }],
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'issueRefund',
    inputs: [
      { name: 'user', type: 'address' },
      { name: 'ticketType', type: 'uint256' },
      { name: 'quantity', type: 'uint256' },
    ],
    outputs: [],
    stateMutability: 'nonpayable',
  },
] as const
```

### USDC ABI (ERC20)
```typescript
export const USDC_ABI = [
  {
    type: 'function',
    name: 'approve',
    inputs: [
      { name: 'spender', type: 'address' },
      { name: 'amount', type: 'uint256' },
    ],
    outputs: [{ name: '', type: 'bool' }],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'allowance',
    inputs: [
      { name: 'owner', type: 'address' },
      { name: 'spender', type: 'address' },
    ],
    outputs: [{ name: '', type: 'uint256' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    name: 'balanceOf',
    inputs: [{ name: 'account', type: 'address' }],
    outputs: [{ name: '', type: 'uint256' }],
    stateMutability: 'view',
  },
] as const
```

---

## Reading Contract Data

### Get Event Contract Address
```typescript
import { useReadContract } from 'wagmi'
import { ADDRESSES, FACTORY_ABI } from './config'

function useEventContract(eventId: number) {
  const { data: eventAddress, isLoading, error } = useReadContract({
    address: ADDRESSES.sepolia.factory,
    abi: FACTORY_ABI,
    functionName: 'getEventContract',
    args: [BigInt(eventId)],
    chainId: sepolia.id,
  })

  return { eventAddress, isLoading, error }
}
```

### Get Event Details
```typescript
function useEventDetails(eventAddress: `0x${string}` | undefined) {
  const { data: eventDetails, isLoading } = useReadContract({
    address: eventAddress,
    abi: EVENT_CONTRACT_ABI,
    functionName: 'getEventDetails',
    enabled: !!eventAddress, // Only fetch if address exists
  })

  return {
    eventDetails: eventDetails as EventDetails | undefined,
    isLoading,
  }
}
```

### Get Ticket Price
```typescript
function useTicketPrice(eventAddress: `0x${string}` | undefined, ticketType: number) {
  const { data: price } = useReadContract({
    address: eventAddress,
    abi: EVENT_CONTRACT_ABI,
    functionName: 'getTicketPrice',
    args: [BigInt(ticketType)],
    enabled: !!eventAddress,
  })

  return price // Returns bigint (USDC has 6 decimals)
}
```

### Check Office Status
```typescript
function useOfficeStatus() {
  const { data: isOpen } = useReadContract({
    address: ADDRESSES.sepolia.factory,
    abi: FACTORY_ABI,
    functionName: 'ticketOfficeOpen',
  })

  return isOpen ?? false
}
```

### Get All Events
```typescript
function useAllEvents() {
  const { data: eventAddresses, refetch } = useReadContract({
    address: ADDRESSES.sepolia.factory,
    abi: FACTORY_ABI,
    functionName: 'getAllEventContracts',
  })

  return {
    eventAddresses: (eventAddresses as `0x${string}`[]) ?? [],
    refetch,
  }
}
```

---

## Writing to Contracts

### Buy Single Ticket
```typescript
import { useWriteContract, useWaitForTransactionReceipt } from 'wagmi'

function useBuyTicket() {
  const { data: hash, writeContract, isPending } = useWriteContract()

  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash,
  })

  const buyTicket = async (
    eventAddress: `0x${string}`,
    ticketType: number
  ) => {
    writeContract({
      address: eventAddress,
      abi: EVENT_CONTRACT_ABI,
      functionName: 'buyTicket',
      args: [BigInt(ticketType)],
    })
  }

  return {
    buyTicket,
    hash,
    isPending,
    isConfirming,
    isSuccess,
  }
}
```

### Buy Multiple Tickets
```typescript
function useBuyTickets() {
  const { data: hash, writeContract, isPending } = useWriteContract()

  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash,
  })

  const buyTickets = async (
    eventAddress: `0x${string}`,
    ticketTypes: number[],
    quantities: number[]
  ) => {
    writeContract({
      address: eventAddress,
      abi: EVENT_CONTRACT_ABI,
      functionName: 'buyTickets',
      args: [ticketTypes.map(BigInt), quantities.map(BigInt)],
    })
  }

  return { buyTickets, hash, isPending, isConfirming, isSuccess }
}
```

### Approve USDC Spending
```typescript
function useApproveUSDC() {
  const { data: hash, writeContract, isPending } = useWriteContract()

  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash,
  })

  const approve = async (
    spender: `0x${string}`, // EventContract address
    amount: bigint
  ) => {
    writeContract({
      address: ADDRESSES.sepolia.usdc,
      abi: USDC_ABI,
      functionName: 'approve',
      args: [spender, amount],
    })
  }

  return { approve, hash, isPending, isConfirming, isSuccess }
}
```

### Check USDC Allowance
```typescript
function useUSDCAllowance(
  owner: `0x${string}` | undefined,
  spender: `0x${string}` | undefined
) {
  const { data: allowance, refetch } = useReadContract({
    address: ADDRESSES.sepolia.usdc,
    abi: USDC_ABI,
    functionName: 'allowance',
    args: owner && spender ? [owner, spender] : undefined,
    enabled: !!(owner && spender),
  })

  return { allowance: allowance as bigint | undefined, refetch }
}
```

---

## Complete Workflows

### Complete Ticket Purchase Flow
```typescript
import { useAccount } from 'wagmi'
import { parseUnits } from 'viem'

function TicketPurchase({ eventId, ticketType }: { eventId: number; ticketType: number }) {
  const { address } = useAccount()
  
  // Step 1: Get event contract address
  const { eventAddress } = useEventContract(eventId)
  
  // Step 2: Get ticket price
  const { data: ticketPrice } = useReadContract({
    address: eventAddress,
    abi: EVENT_CONTRACT_ABI,
    functionName: 'getTicketPrice',
    args: [BigInt(ticketType)],
    enabled: !!eventAddress,
  })
  
  // Step 3: Check USDC allowance
  const { allowance, refetch: refetchAllowance } = useUSDCAllowance(
    address,
    eventAddress
  )
  
  // Step 4: Approve USDC
  const {
    approve,
    isPending: isApproving,
    isConfirming: isApprovingConfirming,
    isSuccess: isApproved,
  } = useApproveUSDC()
  
  // Step 5: Buy ticket
  const {
    buyTicket,
    isPending: isBuying,
    isConfirming: isBuyingConfirming,
    isSuccess: isPurchased,
  } = useBuyTicket()
  
  const needsApproval = allowance !== undefined && 
                        ticketPrice !== undefined && 
                        allowance < ticketPrice
  
  const handlePurchase = async () => {
    if (!eventAddress || !ticketPrice) return
    
    // If insufficient allowance, approve first
    if (needsApproval) {
      await approve(eventAddress, ticketPrice * 10n) // Approve 10x for future purchases
      await refetchAllowance()
    }
    
    // Then buy ticket
    await buyTicket(eventAddress, ticketType)
  }
  
  return (
    <div>
      <p>Price: {ticketPrice ? Number(ticketPrice) / 1e6 : '...'} USDC</p>
      
      <button
        onClick={handlePurchase}
        disabled={isApproving || isApprovingConfirming || isBuying || isBuyingConfirming}
      >
        {isApproving || isApprovingConfirming
          ? 'Approving USDC...'
          : isBuying || isBuyingConfirming
          ? 'Buying Ticket...'
          : needsApproval
          ? 'Approve & Buy Ticket'
          : 'Buy Ticket'}
      </button>
      
      {isPurchased && <p>✅ Ticket purchased successfully!</p>}
    </div>
  )
}
```

### Display All Events
```typescript
function EventsList() {
  const { eventAddresses } = useAllEvents()
  
  return (
    <div>
      <h2>All Events ({eventAddresses.length})</h2>
      {eventAddresses.map((address, index) => (
        <EventCard key={address} eventAddress={address} eventId={index} />
      ))}
    </div>
  )
}

function EventCard({ eventAddress, eventId }: { 
  eventAddress: `0x${string}`
  eventId: number 
}) {
  const { eventDetails, isLoading } = useEventDetails(eventAddress)
  
  if (isLoading) return <div>Loading...</div>
  if (!eventDetails) return null
  
  return (
    <div>
      <h3>{eventDetails.eventName}</h3>
      <p>Location: {eventDetails.venueLocation}</p>
      <p>Date: {new Date(Number(eventDetails.eventDate) * 1000).toLocaleDateString()}</p>
      <p>Tickets: {Number(eventDetails.ticketsSold)} / {Number(eventDetails.eventCapacity)}</p>
      <Link to={`/event/${eventId}`}>View Event</Link>
    </div>
  )
}
```

### Batch Purchase Multiple Tickets
```typescript
function BatchTicketPurchase({ 
  eventId, 
  selections 
}: { 
  eventId: number
  selections: { ticketType: number; quantity: number }[] 
}) {
  const { address } = useAccount()
  const { eventAddress } = useEventContract(eventId)
  
  // Calculate total cost
  const ticketPrices = selections.map(({ ticketType }) =>
    useReadContract({
      address: eventAddress,
      abi: EVENT_CONTRACT_ABI,
      functionName: 'getTicketPrice',
      args: [BigInt(ticketType)],
      enabled: !!eventAddress,
    })
  )
  
  const totalCost = ticketPrices.reduce((sum, { data: price }, index) => {
    if (!price) return sum
    return sum + (price * BigInt(selections[index].quantity))
  }, 0n)
  
  const { allowance } = useUSDCAllowance(address, eventAddress)
  const { approve, isConfirming: isApprovingConfirming } = useApproveUSDC()
  const { buyTickets, isPending, isSuccess } = useBuyTickets()
  
  const needsApproval = allowance !== undefined && allowance < totalCost
  
  const handleBatchPurchase = async () => {
    if (!eventAddress) return
    
    if (needsApproval) {
      await approve(eventAddress, totalCost * 2n) // Approve 2x
    }
    
    const ticketTypes = selections.map(s => s.ticketType)
    const quantities = selections.map(s => s.quantity)
    
    await buyTickets(eventAddress, ticketTypes, quantities)
  }
  
  return (
    <div>
      <p>Total: {Number(totalCost) / 1e6} USDC</p>
      <button 
        onClick={handleBatchPurchase}
        disabled={isPending || isApprovingConfirming}
      >
        {needsApproval ? 'Approve & Buy Tickets' : 'Buy Tickets'}
      </button>
      {isSuccess && <p>✅ Tickets purchased!</p>}
    </div>
  )
}
```

---

## Custom Hooks

### useEvent - Complete Event Data Hook
```typescript
function useEvent(eventId: number) {
  const { eventAddress, isLoading: isLoadingAddress } = useEventContract(eventId)
  const { eventDetails, isLoading: isLoadingDetails } = useEventDetails(eventAddress)
  
  return {
    eventAddress,
    eventDetails,
    isLoading: isLoadingAddress || isLoadingDetails,
  }
}
```

### useTicketPurchase - Complete Purchase Hook
```typescript
function useTicketPurchase(eventId: number) {
  const { address } = useAccount()
  const { eventAddress } = useEventContract(eventId)
  const { allowance, refetch: refetchAllowance } = useUSDCAllowance(address, eventAddress)
  const { approve, ...approveState } = useApproveUSDC()
  const { buyTicket, ...buyState } = useBuyTicket()
  
  const purchaseTicket = async (ticketType: number, ticketPrice: bigint) => {
    if (!eventAddress) throw new Error('Event address not found')
    
    // Check and handle approval
    if (!allowance || allowance < ticketPrice) {
      await approve(eventAddress, ticketPrice * 10n)
      await refetchAllowance()
    }
    
    // Purchase ticket
    await buyTicket(eventAddress, ticketType)
  }
  
  return {
    purchaseTicket,
    isProcessing: approveState.isPending || 
                  approveState.isConfirming || 
                  buyState.isPending || 
                  buyState.isConfirming,
    isSuccess: buyState.isSuccess,
    hash: buyState.hash,
  }
}

// Usage:
function TicketButton({ eventId, ticketType, price }: Props) {
  const { purchaseTicket, isProcessing, isSuccess } = useTicketPurchase(eventId)
  
  return (
    <button 
      onClick={() => purchaseTicket(ticketType, price)}
      disabled={isProcessing}
    >
      {isProcessing ? 'Processing...' : 'Buy Ticket'}
    </button>
  )
}
```

### useCompTicket - Redeem Comp Ticket
```typescript
function useCompTicket() {
  const { data: hash, writeContract, isPending } = useWriteContract()
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash })
  
  const redeemCompTicket = async (
    eventAddress: `0x${string}`,
    ticketType: number
  ) => {
    writeContract({
      address: eventAddress,
      abi: EVENT_CONTRACT_ABI,
      functionName: 'redeemCompTicket',
      args: [BigInt(ticketType)],
    })
  }
  
  return { redeemCompTicket, isPending, isConfirming, isSuccess, hash }
}
```

---

## TypeScript Types

```typescript
export type EventDetails = {
  eventName: string
  eventSymbol: string
  venueLocation: string
  eventDate: bigint
  eventCapacity: bigint
  ticketsSold: bigint
  ticketContractAddress: `0x${string}`
}

export type TicketSelection = {
  ticketType: number
  quantity: number
}

export type PurchaseState = {
  isPending: boolean
  isConfirming: boolean
  isSuccess: boolean
  error: Error | null
}

export type EventContractAddresses = readonly `0x${string}`[]

// Helper to format USDC (6 decimals)
export const formatUSDC = (amount: bigint): string => {
  return (Number(amount) / 1e6).toFixed(2)
}

// Helper to parse USDC
export const parseUSDC = (amount: string): bigint => {
  return parseUnits(amount, 6)
}

// Helper to format date
export const formatEventDate = (timestamp: bigint): string => {
  return new Date(Number(timestamp) * 1000).toLocaleDateString('en-US', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })
}
```

---

## Error Handling

### Handling Contract Errors
```typescript
import { BaseError, ContractFunctionRevertedError } from 'viem'

function handleContractError(error: unknown): string {
  if (error instanceof BaseError) {
    const revertError = error.walk(err => err instanceof ContractFunctionRevertedError)
    
    if (revertError instanceof ContractFunctionRevertedError) {
      const errorName = revertError.data?.errorName
      
      // Map error codes to user-friendly messages
      const errorMessages: Record<string, string> = {
        '!O': 'Ticket office is closed',
        '!A': 'You do not have permission',
        '!C': 'Event capacity exceeded',
        '!T': 'Invalid ticket type',
        '!Q': 'Not enough tickets available',
        '!L': 'Event is locked',
        '!B': 'Insufficient USDC balance',
        '!AL': 'Insufficient USDC allowance',
      }
      
      return errorMessages[errorName || ''] || 'Transaction failed'
    }
  }
  
  return 'An unexpected error occurred'
}

// Usage in component
function TicketPurchaseWithErrorHandling() {
  const [error, setError] = useState<string | null>(null)
  const { buyTicket } = useBuyTicket()
  
  const handlePurchase = async () => {
    try {
      setError(null)
      await buyTicket(eventAddress, ticketType)
    } catch (err) {
      setError(handleContractError(err))
    }
  }
  
  return (
    <div>
      <button onClick={handlePurchase}>Buy Ticket</button>
      {error && <p style={{ color: 'red' }}>{error}</p>}
    </div>
  )
}
```

### Transaction Status Component
```typescript
function TransactionStatus({ hash }: { hash: `0x${string}` | undefined }) {
  const { isLoading, isSuccess, isError } = useWaitForTransactionReceipt({ hash })
  
  if (!hash) return null
  
  return (
    <div>
      {isLoading && (
        <div>
          <Spinner />
          <p>Confirming transaction...</p>
          <a 
            href={`https://sepolia.etherscan.io/tx/${hash}`} 
            target="_blank" 
            rel="noopener noreferrer"
          >
            View on Etherscan
          </a>
        </div>
      )}
      
      {isSuccess && (
        <div style={{ color: 'green' }}>
          ✅ Transaction confirmed!
        </div>
      )}
      
      {isError && (
        <div style={{ color: 'red' }}>
          ❌ Transaction failed
        </div>
      )}
    </div>
  )
}
```

---

## Key Differences from Old Contract

### Old Pattern (Monolithic)
```typescript
// ❌ Old: Direct call with eventId parameter
const { data } = useReadContract({
  address: TICKET_OFFICE_ADDRESS,
  abi: OLD_ABI,
  functionName: 'getEventDetails',
  args: [eventId], // eventId parameter
})
```

### New Pattern (Factory)
```typescript
// ✅ New: Two-step lookup
// Step 1: Get event contract address
const { data: eventAddress } = useReadContract({
  address: FACTORY_ADDRESS,
  abi: FACTORY_ABI,
  functionName: 'getEventContract',
  args: [eventId],
})

// Step 2: Call event contract (no eventId needed)
const { data } = useReadContract({
  address: eventAddress,
  abi: EVENT_CONTRACT_ABI,
  functionName: 'getEventDetails',
  args: [], // No eventId parameter!
})
```

### USDC Approval Target Changed
```typescript
// ❌ Old: Approve factory contract
approve(FACTORY_ADDRESS, amount)

// ✅ New: Approve specific event contract
approve(eventAddress, amount)
```

---

## Testing Checklist

- [ ] Connect wallet (MetaMask, WalletConnect)
- [ ] Switch to Sepolia testnet
- [ ] Get Sepolia USDC from faucet
- [ ] Read factory data (ticketOfficeOpen, getAllEventContracts)
- [ ] Get event contract address for eventId
- [ ] Read event details from event contract
- [ ] Check USDC balance
- [ ] Approve USDC for event contract
- [ ] Buy single ticket
- [ ] Buy multiple tickets (batch)
- [ ] Redeem comp ticket (if available)
- [ ] Handle errors gracefully
- [ ] Verify tickets in wallet (ERC1155 NFTs)

---

## Resources

- **Wagmi Docs:** https://wagmi.sh
- **Viem Docs:** https://viem.sh
- **Factory Contract:** [0x17a6B3AAf32b356f501E362B8E20C789347E782D](https://sepolia.etherscan.io/address/0x17a6b3aaf32b356f501e362b8e20c789347e782d)
- **Sepolia USDC:** 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238
- **Sepolia Etherscan:** https://sepolia.etherscan.io
- **Sepolia Faucet:** https://sepoliafaucet.com

---

## Quick Start Example

```typescript
import { WagmiProvider } from 'wagmi'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { config } from './wagmiConfig'

const queryClient = new QueryClient()

function App() {
  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <EventsList />
      </QueryClientProvider>
    </WagmiProvider>
  )
}

function EventsList() {
  const { eventAddresses } = useAllEvents()
  
  return (
    <div>
      {eventAddresses.map((address, idx) => (
        <EventCard key={address} eventId={idx} />
      ))}
    </div>
  )
}

function EventCard({ eventId }: { eventId: number }) {
  const { eventAddress, eventDetails, isLoading } = useEvent(eventId)
  const { purchaseTicket, isProcessing } = useTicketPurchase(eventId)
  
  if (isLoading) return <div>Loading...</div>
  
  return (
    <div>
      <h2>{eventDetails?.eventName}</h2>
      <button 
        onClick={() => purchaseTicket(0, parseUSDC('50'))}
        disabled={isProcessing}
      >
        Buy GA Ticket - $50
      </button>
    </div>
  )
}
```

---

**Happy Building! 🎟️**
