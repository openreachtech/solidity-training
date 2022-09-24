// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Relayer {

    function execute(
        address to,
        address sender,
        bytes calldata data,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        // 署名の検証
        require(
            verify(sender, data, v, r, s),
            "signature does not match request"
        );

        // calldataの末尾にオリジナルの関数実行者のアドレスを付与
        bytes memory cdata = abi.encodePacked(data, sender);

        // 外部関数のコール
        (bool success, bytes memory returndata) = to.call(cdata);

        // 失敗した場合はrevert
        if (!success) {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            }
            revert("call reverted without message");
        }
    }

    function verify(
        address sender,
        bytes calldata data,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (bool) {
        // calldataのハッシュ値を計算
        bytes32 hash = keccak256(data);
        // hash値をメッセージでラップ
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        // ecrecoverでsingerを復元
        address signer = ecrecover(ethSignedMessageHash, v, r, s);
        // signerがオリジナルの実行者と同じであることを確認
        return signer == sender;
    }
}
