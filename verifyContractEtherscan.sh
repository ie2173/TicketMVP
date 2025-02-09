ETHERSCAN_API_KEY="PRZE8GKZN1D4NQDAB6N5NF39N9H2JRKAJ8"
CONTRACT_ADDRESS=" 0x4d1ade49E7Cb61AA9e9A33B1b587750c2E8C4875"
CONTRACT_PATH="/Users/ianelliott/Documents/cr0wWeb3/cheersFinance/ticketMVP/src/TicketOffice.sol:TicketOffice"


ENCODED_ARGS=${cast abi-encode "constructor(string,address)" "Cheers Finance" 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48}

forge verify-contract --chain-id 1 $CONTRACT_ADDRESS $CONTRACT_PATH $ETHERSCAN_API_KEY --constructor-args $ENCODED_ARGS