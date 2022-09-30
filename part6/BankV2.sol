// SPDX-License-Identifier: Apache License 2.0

pragma solidity >=0.7.0 <0.9.0;

contract BankV2 {

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

    function withdraw(uint256 amount) public {
        require(amount <bankAccounts[msg.sender].balance, "insufficient balance");

        bankAccounts[msg.sender].balance -= amount;
        payable(msg.sender).transfer(amount);

        totalBalance -= amount;
    }
}
