#!/bin/bash

echo "🔍 Finding Sepolia deployment addresses..."
echo ""

# Check if there are any Sepolia deployment artifacts
if [ -d "broadcast" ]; then
    echo "📁 Checking broadcast directory for Sepolia deployments..."
    find broadcast -name "*.json" -path "*/11155111/*" | head -5
    echo ""
fi

echo "🔧 To update the Sepolia script with correct addresses:"
echo ""
echo "1. Find your Sepolia Factory address:"
echo "   - Check broadcast/DeployNewArchitecture.s.sol/11155111/run-latest.json"
echo "   - Look for TicketOfficeFactory address"
echo ""
echo "2. Find your old Sepolia TicketOperations address:"
echo "   - Same file, look for TicketOperations address"
echo ""
echo "3. Update script/RedeployTicketOperationsSepolia.s.sol:"
echo "   - Replace FACTORY address"
echo "   - Replace OLD_TICKET_OPS address"
echo ""
echo "4. Then run:"
echo "   chmod +x redeployTicketOperationsSepolia.sh"
echo "   ./redeployTicketOperationsSepolia.sh"