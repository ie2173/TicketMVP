#!/bin/bash

echo "🚀 Deploying New Architecture to Sepolia..."
echo "📦 This will deploy:"
echo "   1. TicketOfficeFactory"
echo "   2. TicketOperations"
echo "   3. AdminOperations"
echo "   4. Register operation contracts"
echo ""

forge script script/DeployNewArchitecture.s.sol \
  --rpc-url sepolia \
  --account cheersFinance.eth \
  --broadcast \
  --verify \
  -vvvv

echo ""
echo "✅ Deployment complete! Check the output above for contract addresses."
echo "📝 Save these addresses for your frontend configuration."
