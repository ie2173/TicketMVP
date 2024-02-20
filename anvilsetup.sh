
export USDC=0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
export WHALE=0xD6153F5af5679a75cC85D8974463545181f48772
export WALLET=0x0000000650D7c65Aff5D0EacA6F345bbB6b83783
export CHEERS=0x9b20bAcE2394Dcc90183b4551b899a29f7bD1692

cast rpc anvil_impersonateAccount $WHALE
cast send $USDC --from $WHALE "transfer(address,uint256)(bool)" $WALLET 1060000088600000  --unlocked

cast send --from 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720 $WALLET --value 100ether --unlocked

cast send --from 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720 $CHEERS --value 100ether --unlocked

