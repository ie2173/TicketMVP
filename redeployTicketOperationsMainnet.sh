#!/bin/bash

echo "🚀 Redeploying TicketOperations to Mainnet..."
echo "📦 This will deploy:"
echo "   1. New TicketOperations (with claimRefund function)"
echo "   2. Register new contract with existing factory"
echo ""
echo "⚠️  Factory address: 0xE2A349548e3Aff59681f0eA1c25779F830Fb3ee0"
echo "⚠️  Old TicketOps:   0x0c931FC196D678b6F327c5d03D8253F75575B484"
echo ""

forge script script/RedeployTicketOperations.s.sol \
  --rpc-url mainnet \
  --account cheersFinance.eth \
  --broadcast \
  --verify \
  -vvvv

echo ""
echo "✅ Upgrade complete! Check the output above for the new contract address."
echo "📝 Update your frontend to use the new TicketOperations address."
