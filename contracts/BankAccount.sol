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
    mapping(address => uint[]) userAccount; // store ids of the accounts a user owned

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
        _;
    }
    
    //=========================================================================================================================
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
    function createAccount(address[] calldata otherOwners) external
    {
        // make sure each owner is unique
        // one owner is creating an array which contains all of the owners, and one of the owners will be the creater himself. SO rthats why +1
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
            if(userAccount[owners[idx]].length > 2)
            {
                revert("Each user can have a max 3 accounts");
            }
            userAccount[owners[idx]].push(id);
        }
        accounts[id].owners = owners;
        nextAccountId++;
        emit AccountCreated(owners, id, block.timestamp);
    }


    function requestWithdrawl(uint accountId, uint ammount) external 
    {

    }


    /*
    We need to know which withdraw in the account we need to approve, because at a time multiple withdrawl request can exist
    */
    function approveWithdrawl(uint accountId, uint withdrawlId) external 
    {

    }


    /*
    This will give you money once the a withdrawl is approved
    */
    function withdraw(uint accountId, uint withdrawlId) external 
    {

    }


    function getBalance(uint accountId) public view returns (uint)
    {

    }


    /*
    This will tell us what owners are associated with an account
    */
    function getOwners(uint accountId) public view returns (address[] memory)
    {

    }


    /*
    This will return number of approvals not whose approved
    */
    function getApprovals(uint accountId, uint withdrawlId) public view returns (uint)
    {

    }


    /*
    This will return ids of the account that this specific user is owner of
    */
    function getAccount() public view returns (uint[] memory) 
    {
        
    }

}
