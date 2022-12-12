//SPDX-License-Identifier: Unlicense
pragma solidity >=0.7.0 <0.9.0;

import "github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.7.3/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol) payable ERC20(name, symbol) {
        _mint(_msgSender(), 1_000_000);
    }

    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }

    // decimalは”0”にしておく
    function decimals() public pure override returns (uint8) {
        return 0;
    }
}
