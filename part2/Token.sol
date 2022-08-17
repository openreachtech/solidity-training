// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Token {

    string private _name;

    mapping(address => uint256) private _balances;

    uint256 private _totalSupply;

    event Mint(address indexed to, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(string memory name_) {
        _name = name_;
    }

    // 1. トークンの名前がわかる
    function name() public view returns (string memory) {
        return _name;
    }

    // 2. 発行できる
    function mint(address account, uint256 amount) public {
        require(account != address(0), "mint to the zero address");
        require(amount != 0, "mint zero amount of token");

        _totalSupply += amount;
        _balances[account] += amount;

        emit Mint(account, amount);
    }

    // 3. 総発行数がわかる
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    // 4. 所有数がわかる
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    // 5. トークンを誰かに送れる
    function transfer(address to, uint256 amount) public {
        require(to != address(0), "transfer to the zero address");
        require(amount != 0, "transfer zero amount of token");


        _balances[msg.sender] -= amount;
        _balances[to] += amount;

        emit Transfer(msg.sender, to, amount);
    }
}
