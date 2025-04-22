cast send --account cheersFinance.eth --rpc-url https://eth-sepolia.g.alchemy.com/v2/PCeUnACiFHmOit6YLq5AmvgWBlAB6nCr 0x26d98cd401716eeeefa12b94d8dd64c2b3e1eeb2 "mintSingleTicket(uint256, uint256, uint256, address)" "0 0 1 0x70AFEF91DAe765B1E45A9736c21D7cd061EAf205"

cast send --account crowweb3.eth --rpc-url https://eth-sepolia.g.alchemy.com/v2/PCeUnACiFHmOit6YLq5AmvgWBlAB6nCr 0x1f97576daf319e69c0b920739f5b4dbbc94a2b93 "mintMultipleTickets(uint256, uint256[], uint256[], address)" "2" "[0,1,2]" "[0,0,1]" "0x70AFEF91DAe765B1E45A9736c21D7cd061EAf205" -vvv


cast call --rpc-url https://eth-sepolia.g.alchemy.com/v2/PCeUnACiFHmOit6YLq5AmvgWBlAB6nCr 0x1f97576daf319e69c0b920739f5b4dbbc94a2b93 "getTicketNames(uint256)" "2" 