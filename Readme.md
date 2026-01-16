Vunerabilities:

1. Possible reentrancy of the 1155 token for the tickets.
2. WithdrawFunds() and possibily unsafely state change and brick refund payments.
3. Permissions for Mint would allow owners to mint unlimited tickets, look at making sure only the ticket office can lock up.
