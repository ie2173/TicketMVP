CONTRACT_ADDRESS=0x26d98cd401716eeeefa12b94d8dd64c2b3e1eeb2
RPC_ENDPOINT="https://eth-sepolia.g.alchemy.com/v2/PCeUnACiFHmOit6YLq5AmvgWBlAB6nCr"

# The struct needs to match:
# createEvent((((string[],uint256[],uint256[],uint256[]),string,address,uint256,(string,string),string[],string[],string[],string),string))

STRUCT_ARGUMENT="((
['General Admission', 'VIP Admission', 'Backstage Pass'],
[100,10,5],
[5,10,100],
[0,0,0]
),'Demo Event 1',
0x70AFEF91DAe765B1E45A9736c21D7cd061EAf205,
1745157600,
('Golden Gate Park','37.7827081,-122.4097966'),
['The Ramones','The Beatles','The Rolling Stones'],
['Rock Music'],
['Concert'],
'Live'
)"




cast call 0x26d98CD401716eEeEfA12B94d8Dd64C2b3E1eEB2 0x1e271217 "((['General Admission','vip Admission'],[100,20],[1,2],[1,1]),'Event Name',0x70AFEF91DAe765B1E45A9736c21D7cd061EAf205,123,('somewhere','somewhere'),['someone','someone2'],['something'],['something'],'Live'),'hello')" --rpc-url "https://eth-sepolia.g.alchemy.com/v2/PCeUnACiFHmOit6YLq5AmvgWBlAB6nCr" --account cheersfinance.eth