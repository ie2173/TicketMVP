#!/bin/bash

echo "🧪 Redeploying TicketOperations to Sepolia (TEST)..."
echo "📦 This will deploy:"
echo "   1. New TicketOperations (with claimRefund function)"
echo "   2. Register new contract with existing Sepolia factory"
echo "   3. Decommission old Sepolia TicketOperations"
echo ""
echo "⚠️  SEPOLIA ADDRESSES (UPDATE THESE IN THE SCRIPT):"
echo "⚠️  Factory:      [UPDATE_WITH_SEPOLIA_FACTORY_ADDRESS]"
echo "⚠️  Old TicketOps: [UPDATE_WITH_OLD_SEPOLIA_TICKET_OPS]"
echo ""

# Check if addresses are still placeholders
if grep -q "UPDATE_WITH" script/RedeployTicketOperationsSepolia.s.sol; then
    echo "❌ ERROR: Please update the addresses in script/RedeployTicketOperationsSepolia.s.sol"
    echo ""
    echo "Find these lines and replace with actual Sepolia addresses:"
    echo "  address public constant FACTORY = 0x[UPDATE_WITH_SEPOLIA_FACTORY_ADDRESS];"
    echo "  address public constant OLD_TICKET_OPS = 0x[UPDATE_WITH_OLD_SEPOLIA_TICKET_OPS];"
    echo ""
    exit 1
fi

forge script script/RedeployTicketOperationsSepolia.s.sol \
  --rpc-url sepolia \
  --account cheersFinance.eth \
  --broadcast \
  --verify \
  -vvvv

echo ""
echo "✅ Sepolia upgrade complete! Check the output above for the new contract address."
echo "📝 Test the claimRefund function on Sepolia before mainnet deployment."
echo "🚀 If everything works, run ./redeployTicketOperationsMainnet.sh for production."