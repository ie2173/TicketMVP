#!/usr/bin/env bash
set -euo pipefail

# Deploy using Foundry keystore account (no password-file embedded)
# Usage:
#   export KEYSTORE_ACCOUNT=cheersFinance.eth.json
#   export MAINNET_RPC_URL=...
#   ./deployMainnetWithKeystore.sh

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

if [ -z "${KEYSTORE_ACCOUNT:-}" ]; then
  echo "Set KEYSTORE_ACCOUNT to the keystore filename (e.g. cheersFinance.eth.json)" >&2
  exit 1
fi

echo "Using keystore account: $KEYSTORE_ACCOUNT"

set -o allexport
source .env || true
set +o allexport

echo "Starting dry-run (simulation) on mainnet fork..."
forge script script/DeployNewArchitecture.s.sol:DeployNewArchitecture \
  --fork-url "$MAINNET_RPC_URL" -vvvv

echo "Dry-run complete. When ready, run the broadcast step and provide the keystore password interactively."

echo "Broadcasting to mainnet using keystore account (you will be prompted for password)..."
forge script script/DeployNewArchitecture.s.sol:DeployNewArchitecture \
  --rpc-url "$MAINNET_RPC_URL" \
  --broadcast \
  --account "$KEYSTORE_ACCOUNT" \
  -vvvv

echo "Deployment script finished. Check broadcast/ for receipts." 
