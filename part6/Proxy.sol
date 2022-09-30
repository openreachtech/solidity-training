// SPDX-License-Identifier: Apache License 2.0

pragma solidity >=0.7.0 <0.9.0;

abstract contract Proxy {

    function _delegate(address _implementation) internal returns (bytes memory) {
        assembly {
            // calldataをメモリにコピーする
            calldatacopy(0, 0, calldatasize())

            // delegate callの実行
            // delegatecall(消費可能なガス残量, 呼び出し先, メモリオフセット, メモリサイズ, 実行結果オフセット、実行結果サイズ)
            // 実行結果のサイズは不明なのでゼロを指定
            let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)

            // 実行結果をメモリにコピー
            returndatacopy(0, 0, returndatasize())

            switch result
            // 戻り値が“０”の場合は失敗なのでrevert
            case 0 {
                revert(0, returndatasize())
            }
            // 戻り値が“１”の場合は成功なので、結果を返却
            default {
                return(0, returndatasize())
            }
        }
    }

    function implementation() public view virtual returns (address);

    // 存在しない関数が呼ばれたときに実行される 
    // 👉 delegatecallで呼び出す先のコントラクトの関数はProxyで実装していない。したがって、fallbackが呼ばれる
    fallback() external payable virtual {
        _delegate(implementation());
    }

    // calldataなしでethが送られたときに実行される
    // 👉 delegatecallで呼び出す先のコントラクトのreceive ethを実行する
    receive() external payable virtual {
        _delegate(implementation());
    }
}
