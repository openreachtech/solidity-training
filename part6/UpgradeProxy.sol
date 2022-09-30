// SPDX-License-Identifier: Apache License 2.0

pragma solidity >=0.7.0 <0.9.0;

import "./Proxy.sol";

contract UpgradeProxy is Proxy {

    struct AddressSlot {
        address value;
    }

    // "eip1967.proxy.implementation"のハッシュ値
    //  bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1))
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    // "eip1967.proxy.admin"のハッシュ値
    //  bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1))
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    event Upgraded(address indexed implementation);
    event AdminChanged(address previousAdmin, address newAdmin);

    modifier onlyAdmin() {
        require(msg.sender == admin(), "caller should be admin");
        _;
    }

    constructor(address _implementation) {
        _upgradeTo(_implementation);
        // deployしたユーザをadminユーザとしてセット
        _changeAdmin(msg.sender);
    }

    function implementation() public view override returns (address) {
        return getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    // adminユーザのみ実行可能
    function upgradeTo(address newImplementation) public onlyAdmin {
        _upgradeTo(newImplementation);
    }

    function _upgradeTo(address newImplementation) internal {
        require(isContract(newImplementation), "new implementation is not contract");
        // "_IMPLEMENTATION_SLO"を"AddressSlot"のアドレスとして初期化し、
        // AddressSlotの中身にロジックコントラクトのアドレスを格納
        getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
        emit Upgraded(newImplementation);
    }

    function admin() public view returns (address) {
        return getAddressSlot(_ADMIN_SLOT).value;
    }

    // adminユーザのみ実行可能
    function changeAdmin(address newAdmin) public onlyAdmin {
        _changeAdmin(newAdmin);
    }

    function _changeAdmin(address newAdmin) internal {
        address oldAdmin = admin();
        // "_ADMIN_SLOT"を"AddressSlot"のアドレスとして初期化し、
        // AddressSlotの中身にadminユーザのアカウントアドレスを格納
        getAddressSlot(_ADMIN_SLOT).value = newAdmin;
        emit AdminChanged(oldAdmin, newAdmin);
    }

    // 引数で渡されたslotを"AddressSlot"のアドレスとして使う
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        // "AddressSlot"の変数rを格納するslotを指定する
        assembly {
            r.slot := slot
        }
    }

    function isContract(address account) internal view returns (bool) {
        // extcodesizeがゼロの場合、コントラクトとみなす
        return account.code.length > 0;
    }
}
