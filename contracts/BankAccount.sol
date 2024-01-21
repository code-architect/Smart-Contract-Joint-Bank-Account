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
}
