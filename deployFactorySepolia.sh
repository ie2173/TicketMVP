#!/bin/bash

echo "🚀 Deploying TicketOfficeFactory to Sepolia..."

forge script script/TicketOfficeFactory.s.sol \
  --rpc-url sepolia \
  --broadcast \
  --verify \
  -vvvv
