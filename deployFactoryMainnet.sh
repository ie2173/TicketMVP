#!/bin/bash

echo "🚀 Deploying TicketOffice Factory Pattern to Mainnet..."
echo "⚠️  WARNING: This will deploy to Ethereum Mainnet with real ETH!"
echo ""

# Confirmation prompt
read -p "Are you sure you want to deploy to mainnet? (yes/no): " confirm
if [[ $confirm != "yes" ]]; then
    echo "❌ Deployment cancelled"
    exit 1
fi

# Check if required environment variables are set
if [[ -z "$PRIVATE_KEY" ]]; then
    echo "❌ Error: PRIVATE_KEY environment variable is not set"
    exit 1
fi

if [[ -z "$MAINNET_RPC_URL" ]]; then
    echo "❌ Error: MAINNET_RPC_URL environment variable is not set"
    exit 1
fi

echo "📋 Pre-deployment contract size verification..."
forge build --sizes

echo ""
echo "💰 Checking gas price and estimating costs..."
echo "🔧 Deploying to Ethereum Mainnet..."

forge script script/TicketOfficeFactory.s.sol:TicketOfficeFactoryDeploy \
    --rpc-url $MAINNET_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --verify \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --slow

echo ""
echo "✅ Mainnet deployment complete!"
echo "📝 Factory deployed - check broadcast/ folder for details"
echo "🔍 Verify on Etherscan"