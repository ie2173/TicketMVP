

# Struct Example
# "([ticketname1, ticketname2],[ticketCapacity1, ticketCapacity2],[ticketPrice1, ticketPrice2],[these must all be zeros],"Event Name",eventOwnerAddress,unixDateTime,Lattitude/Longitude in string,["group1","group2"],["keywords1","keywords2"],["caregories1","categories2"])"

CONTRACT_ADDRESS=0xb0e7a443441c237196a7d7f51e5b8abc6ee25912
STRUCT_ARGUMENT="(['General Admission', 'VIP Admission', 'Backstage Pass'],[100, 10, 5],[5,10,100],[0,0,0],'Demo Event 1',0x70AFEF91DAe765B1E45A9736c21D7cd061EAf205,1745157600,'37.7827081,-122.4097966',['The Ramones','The Beatles','The Rolling Stones'],['Rock Music'],['Concert'])"
STRING_ARGUMENT="https://silver-used-aardwolf-766.mypinata.cloud/files/bafkreie4fm5kyig2jucvn7v3kphwvn2serpfcyv6hs2lktfjylrxojekuu?X-Algorithm=PINATA1&X-Date=1737579776&X-Expires=30&X-Method=GET&X-Signature=47baa6ee3c5da1ccaf36bed4207d2b4fccd7476d817c5dd4776e1f298dad5878"
RPC_ENDPOINT="https://eth-sepolia.g.alchemy.com/v2/PCeUnACiFHmOit6YLq5AmvgWBlAB6nCr"

cast send  $CONTRACT_ADDRESS "createEvent((string[],uint256[],uint256[],uint256[],string,address,uint256,string,string[],string[],string[]),string)"  "$STRUCT_ARGUMENT" "$STRING_ARGUMENT" --rpc-url $RPC_ENDPOINT --account cheersFinance.eth