// SPDX-License-Identifier: Apache License 2.0

pragma solidity >=0.7.0 <0.9.0;

contract BankV1 {

    string public name;

    uint256 public totalBalance;

    mapping(address => BankAccount) public bankAccounts;

    struct BankAccount {
        uint256 balance;
    }

    function setName(string memory newName) public {
        name = newName;
    }

    function deposit() public payable {
        totalBalance += msg.value;
        bankAccounts[msg.sender].balance = msg.value;
    }
}
