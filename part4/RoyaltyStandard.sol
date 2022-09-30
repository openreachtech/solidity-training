// SPDX-License-Identifier: Apache License 2.0

pragma solidity >=0.7.0 <0.9.0;

import "github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.7.3/contracts/interfaces/IERC2981.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.7.3/contracts/utils/introspection/ERC165.sol";

abstract contract RoyaltyStandard is ERC165, IERC2981 {
    mapping(uint256 => RoyaltyInfo) public royalties;

    // "10000"を100%とする
    uint16 public constant INVERSE_BASIS_POINT = 10000;

    // ロイヤリティ情報として、受け取りアドレスと利率を指定
    struct RoyaltyInfo {
        address recipient;
        uint16 feeRate;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC2981).interfaceId || // ERC-2981のインターフェースをサポート
            super.supportsInterface(interfaceId);
    }

    function _setTokenRoyalty(
        uint256 tokenId,
        address recipient,
        uint256 value
    ) internal {
        royalties[tokenId] = RoyaltyInfo(recipient, uint16(value));
    }

    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        RoyaltyInfo memory royalty = royalties[tokenId];
        receiver = royalty.recipient;
        // 売却価格からロイヤリティを計算する
        royaltyAmount = (salePrice * royalty.feeRate) / INVERSE_BASIS_POINT;
    }
}
