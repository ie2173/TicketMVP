#!/bin/bash

echo "🚀 Deploying TicketOffice Factory Pattern to Sepolia..."

# Check if required environment variables are set
if [[ -z "$PRIVATE_KEY" ]]; then
    echo "❌ Error: PRIVATE_KEY environment variable is not set"
    exit 1
fi

if [[ -z "$SEPOLIA_RPC_URL" ]]; then
    echo "❌ Error: SEPOLIA_RPC_URL environment variable is not set"
    exit 1
fi

echo "📋 Pre-deployment contract size check..."
forge build --sizes

echo ""
echo "🔧 Deploying to Sepolia testnet..."
forge script script/TicketOfficeFactory.s.sol:TicketOfficeFactoryDeploy \
    --rpc-url $SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --verify \
    --etherscan-api-key $ETHERSCAN_API_KEY

echo ""
echo "✅ Deployment complete!"
echo "📝 Check the broadcast/ folder for deployment details"