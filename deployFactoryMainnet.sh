#!/bin/bash

echo "🚀 Deploying TicketOfficeFactory to Mainnet..."

forge script script/TicketOfficeFactory.s.sol \
  --rpc-url mainnet \
  --broadcast \
  --verify \
  -vvvv
