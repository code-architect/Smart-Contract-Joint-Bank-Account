// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12 <0.9.0;

contract BankAccount {
    
    event Deposite(
        address indexed user,
        uint indexed accountId,
        uint value,
        uint timestamp
    );

    event WithdrawRequested(
        address indexed user,
        uint indexed accountId,
        uint indexed withdrawId,
        uint amount,
        uint timestamp
    );

    event Withdraw(
        uint indexed withdrawId, 
        uint timestamp
    );

    event AccountCreated(
        address[] owners, // multiple owners, so multiple accounts
        uint indexed id, // the id of the account
        uint timestamp
    );

    struct WithdrawRequest
    {
        address user;   // the address whcih is requesting Withdrawl
        uint amount;    // the amount which they have requested
        uint approvals; // number of approvials required
        mapping(address => bool) ownersApproved;    // which owners have approved this Withdraw rerquest
        bool approved;  // if the request is approved
    }

    struct Account {
        address[] owners;   // owners of the account
        uint balance;   // total balance of the account
        mapping(uint => WithdrawRequest) withdrawRequests;  // the uint are going to be the ids of the WithdrawRequest
    }

    //Associate account id and withdraw ids 
    mapping(uint => Account) accounts;
    mapping(address => uint[]) userAccounts; // store ids of the accounts a user owned

    uint nextAccountId;
    uint nextWithdrawId;

    //=================================================== Modefiers ===========================================================
    modifier accountOwner(uint accountId)
    {
        bool isOwner;
        // check if the account id matches with any of the owner of the given account
        for(uint idx; idx < accounts[accountId].owners.length; idx++)
        {
            if(accounts[accountId].owners[idx] == msg.sender)
            {
                isOwner = true;
                break;
            }
        }
        require(isOwner, "You are not an owner of this account");
        _;
    }

    modifier validOwners(address[] calldata owners)
    {
        // check numbers of owners are valid
        require(owners.length + 1 <= 4, "maximum of four owners per account");
        for (uint i; i < owners.length; i++) 
        {
            // we are using this second loop to check forword if any of the ele,ments matches 
            for (uint j = i + 1; j < owners.length; j++)
            {
                if(owners[i] == owners[j])
                {
                    revert("No duplicate owners");
                }
            }
        }
        _;
    }

    modifier sufficientBalance(uint accountId, uint amount)
    {
        require(accounts[accountId].balance >= amount, "Insufficient balance in the account");
        _;
    }

    modifier canApprove(uint accountId, uint withdrawId)
    {
        // if this request is already approved or not
        require(!accounts[accountId].withdrawRequests[withdrawId].approved, "This request is already approved");
        // if the user sending this approval is not the person who made the request then he/she cannot make an approval
        require(accounts[accountId].withdrawRequests[withdrawId].user != msg.sender, "You cannot approve this request");
        // if the user is 0 address, that mean we haven created the request yet, because as soon as we create it we will mark the user of the user of the request
        //as the person made the request
        require(accounts[accountId].withdrawRequests[withdrawId].user != address(0), "This request does not exists");
        // check if you have already approved it
        require(!accounts[accountId].withdrawRequests[withdrawId].ownersApproved[msg.sender], "You have already approved");
        _;
    }

    modifier canWithdraw(uint accountId, uint withdrawId)
    {
        // check if you are the owner
        require(accounts[accountId].withdrawRequests[withdrawId].user == msg.sender, "You did not create this request");
        require(accounts[accountId].withdrawRequests[withdrawId].approved, "This request is not approved");
        _;
    }
    
    //================================================ Modefiers Ends =========================================================
    //=================================================== Functions ===========================================================
    /*
    User can have multiple accounts, so need to specify account id
    */    
    function deposit(uint accountId) external payable accountOwner(accountId)
    {
        // add to the existing balance
        accounts[accountId].balance += msg.value;
    }


    /*
    Take in all of the owners, the person who calles this function will be automatically be the owner of the account
    and this is external because this is not suppose to be called inside of the contract
    */
    function createAccount(address[] calldata otherOwners) external validOwners(otherOwners)
    {
        // make sure each owner is unique
        // one owner is creating an array which contains all of the owners, and one of the owners will be the creater himself. So thats why +1
        address[] memory owners = new address[](otherOwners.length + 1);        
        owners[otherOwners.length] = msg.sender;

        // get the id for my account
        uint id = nextAccountId;
        // go through every owner to make sure they do not have more then three account
        for(uint idx; idx < owners.length; idx++)
        {
            // this line is to exclude our selfs from copying, because we added ourself previously
            if(idx < owners.length - 1)
            {
                owners[idx] = otherOwners[idx];
            }
            // we are going to go to user accounts, which is gonna contain an array, which specifies all of the accounts this use is owner of
            // we are going to check if they are owner of three max accounts
            // and this is valid to do because unwanted owners will be removed at the beggening we can proceed with valid owners
            if(userAccounts[owners[idx]].length > 2)
            {
                revert("Each user can have a max 3 accounts");
            }
            userAccounts[owners[idx]].push(id);
        }
        accounts[id].owners = owners;
        nextAccountId++;
        emit AccountCreated(owners, id, block.timestamp);
    }


    function requestWithdrawl(uint accountId, uint amount) external accountOwner(accountId) sufficientBalance(accountId, amount)
    {
        uint id = nextWithdrawId;
        // This is making a reference to the WithdrawRequest struct, that is going to store the id in the mapping withdrawRequests of the account associated with the account id
        // The location is storage, so that anything is being done on the request object is going to modify whats inside of this mapping "accounts.[accountId].withdrawRequests[id]",
        // hence it will change what is inside of the account struct
        WithdrawRequest storage request = accounts[accountId].withdrawRequests[id];
        request.user = msg.sender;
        request.amount = amount;
        nextWithdrawId++;
        emit WithdrawRequested(msg.sender, accountId, id, amount, block.timestamp);
    }


    /*
    We need to know which withdraw in the account we need to approve, because at a time multiple withdrawl request can exist
    */
    function approveWithdrawl(uint accountId, uint withdrawId) external accountOwner(accountId) canApprove(accountId, withdrawId)
    {
        WithdrawRequest storage request = accounts[accountId].withdrawRequests[withdrawId];
        // incrimenting number of approvals we have
        request.approvals++;
        request.ownersApproved[msg.sender] = true;

        // we are checking this because the length of owners -1 because who ever makes the request has already made an aproval, so we are counthing total -1 number of approvals
        if(request.approvals == accounts[accountId].owners.length - 1)
        {
            request.approved = true;
        }
    }


    /*
    This will give you money once the a withdrawl is approved
    */
    function withdraw(uint accountId, uint withdrawId) external canWithdraw(accountId, withdrawId)
    {
        // make sure if have sufficient balance, checking here because within the time of the withdrawl request money could have been taken out, 
        //because we can make multiple withdrawl request
        uint amount =  accounts[accountId].withdrawRequests[withdrawId].amount;
        require(accounts[accountId].balance >= amount, "insufficient balance");

        // substract the balance and reset(delete) the withdrawRequests struct, so cannot draw multiple times
        accounts[accountId].balance -= amount;
        delete accounts[accountId].withdrawRequests[withdrawId];

        // Pay the person and emit it
        (bool sent,) = payable(msg.sender).call{value: amount}("");
        require(sent);

        emit Withdraw(withdrawId, block.timestamp);
    }


    function getBalance(uint accountId) public view returns (uint)
    {
        return accounts[accountId].balance;
    }


    /*
    This will tell us what owners are associated with an account
    */
    function getOwners(uint accountId) public view returns (address[] memory)
    {
        return accounts[accountId].owners;
    }


    /*
    This will return number of approvals not whose approved
    */
    function getApprovals(uint accountId, uint withdrawId) public view returns (uint)
    {
        return accounts[accountId].withdrawRequests[withdrawId].approvals;
    }


    /*
    This will return ids of the account that this specific user is owner of
    */
    function getAccount() public view returns (uint[] memory) 
    {
        return userAccounts[msg.sender];
    }

}
