// SPDX-License-Identifier: Apache License 2.0

pragma solidity >=0.7.0 <0.9.0;

import "github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.7.3/contracts/token/ERC721/ERC721.sol";
import "./RoyaltyStandard.sol";

contract SimpleNFT is ERC721, RoyaltyStandard {

    // ロイヤリティは売買価格の３％とする
    uint256 public constant feeRate = 300;

    address public immutable royaltyRecipient;

    constructor() ERC721("SimpleNFT", "SFT") {
        royaltyRecipient = msg.sender;
    }

    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
        // ロイヤリティ情報を設定
        _setTokenRoyalty(tokenId, royaltyRecipient, feeRate);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, RoyaltyStandard) // RoyaltyStandardをサポートする
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}