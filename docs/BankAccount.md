# Solidity API

## BankAccount

### Contract
BankAccount : contracts/BankAccount.sol

 --- 
### Modifiers:
### accountOwner

```solidity
modifier accountOwner(uint256 accountId)
```

 --- 
### Functions:
### deposit

```solidity
function deposit(uint256 accountId) external payable
```

### createAccount

```solidity
function createAccount(address[] otherOwners) external
```

### requestWithdrawl

```solidity
function requestWithdrawl(uint256 accountId, uint256 ammount) external
```

### approveWithdrawl

```solidity
function approveWithdrawl(uint256 accountId, uint256 withdrawlId) external
```

### withdraw

```solidity
function withdraw(uint256 accountId, uint256 withdrawlId) external
```

### getBalance

```solidity
function getBalance(uint256 accountId) public view returns (uint256)
```

### getOwners

```solidity
function getOwners(uint256 accountId) public view returns (address[])
```

### getApprovals

```solidity
function getApprovals(uint256 accountId, uint256 withdrawlId) public view returns (uint256)
```

### getAccount

```solidity
function getAccount() public view returns (uint256[])
```

 --- 
### Events:
### Deposite

```solidity
event Deposite(address user, uint256 accountId, uint256 value, uint256 timestamp)
```

### WithdrawRequested

```solidity
event WithdrawRequested(address user, uint256 accountId, uint256 withdrawId, uint256 amount, uint256 timestamp)
```

### Withdraw

```solidity
event Withdraw(uint256 withdrawId, uint256 timestamp)
```

### AccountCreated

```solidity
event AccountCreated(address[] owners, uint256 id, uint256 timestamp)
```

