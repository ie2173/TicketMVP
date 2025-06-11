✅ Test Get Event Name
returns the name of the event
test get ticket names
test Event Owner
test get erc1155 address
get individual ticket price
get total event ticket prices
get the capacity of all tickets for events
get the tickets that have been sold
get the event date
get the event location
get the performers for the event
get the users' ticket balance
get the owner address of an event
verifys user has a specific ticket
get if user has been issues a ticket
get authorized treasurer for event
get the funds raised by event

    test create event
     ✅ Works under ideal conditions
     ✅ Reverts if within 3 days of current date

    test minting a single ticket
    ✅ works under ideal conditions
    ✅ reverts if event frozen
    ✅ reverts if event not created
    ✅ reverts if USDC not approved
    ✅ reverts if insufficient USDC
    ✅ reverts if sold out

    test minting multiple tickets
    ✅ works under ideal conditions
    ✅ reverts if event does not exist
    ✅ reverts if event frozen
    ✅ reverts if USDC not approved
    ✅ reverts if insufficient USDC
    ✅ reverts if sold out

    test redeeming a ticket
    ✅ works under ideal conditions
    ✅ reverts if event frozen
    ✅ reverts if user is not offered a comp

    issue a refund for event
    ✅ works under ideal conditions
    ✅ reverts if event not frozen
    ✅ reverts if user was comped a ticket

    lock an event so people can't buy tickets
    ✅ works under ideal conditions
    ✅ reverts if not event owner or Contract Owner

    unlock an event so people can return
    ✅ works under ideal conditions
    ✅ reverts if not event owner or Contract Owner

    designated a new treasurer for an event
    ✅ works under ideal conditions
    ✅ reverts if not event owner

    comp one ticket to a user
    ✅ works under ideal conditions
    ✅ reverts if not owner or treasurer

    comp many tickets to users
    ✅ works under ideal conditions
    ✅ reverts if not owner or treasurer


    edit an event
    ✅ works under ideal conditions
    ✅ reverts if not owner or treasurer
    ✅ reverts if within 3 days of event
    ✅ reverts if attempt to swap owner.
    ✅ reverts if the event is locked

    change the image for an event
    ✅ works under ideal conditions
    ✅ reverts if not owner or treasurer



    withdraw funds from an event
    ✅ works under ideal conditions
    ✅ reverts if not owner or treasurer
    ✅ reverts if before time lock
    ✅ reverts if event is locked

    revoke tickets purchased by a user
