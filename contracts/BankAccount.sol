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

    //==========================================================================================================================
    /*
    User can have multiple accounts, so need to specify account id
    */    
    function deposit(uint accountId) external payable 
    {

    }


    /*
    Take in all of the owners, the person who calles this function will be automatically be the owner of the account
    and this is external because this is not suppose to be called inside of the contract
    */
    function createAccount(address[] calldata otherOwners) external
    {

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
