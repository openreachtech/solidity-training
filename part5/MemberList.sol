// SPDX-License-Identifier: Apache License 2.0

pragma solidity >=0.7.0 <0.9.0;

contract MemberList {
    address public immutable trustedRelayer;


    constructor(address relayer) {
        trustedRelayer = relayer;
    }

    struct Member {
        string name;
        uint8  age;
        bool   isMale;
    }

    mapping(address => Member) public list;

    function regist(string memory name, uint8 age, bool isMale) public {
        address account = originalSender();
        list[account].name = name;
        list[account].age = age;
        list[account].isMale = isMale;
    }

    function originalSender() internal view returns (address sender) {
        if (msg.sender == trustedRelayer) {
            // The assembly code is more direct than the Solidity version using `abi.decode`.
            assembly {
                sender := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            return msg.sender;
        }
    }
}
