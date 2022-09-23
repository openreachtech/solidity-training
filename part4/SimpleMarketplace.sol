// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.7.3/contracts/token/ERC721/IERC721.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.7.3/contracts/interfaces/IERC2981.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.7.3/contracts/utils/introspection/IERC165.sol";

contract SimpleMarketplace {

    address public immutable nft;

    struct Sale {
        address seller;
        uint256 price;
    }

    mapping(uint256 => Sale) public sales;


    event Selling(uint256 indexed tokenId, address seller, uint256 price);
    event Sold(uint256 indexed tokenId, address buyer);

    constructor(address _nft) {
        nft = _nft;
    }

    function sell(uint256 tokenId, uint256 price) public {
        require(0 < price, "price is zero");

        // NFTをマーケットプレイスコントラクトの移す
        IERC721(nft).transferFrom(msg.sender, address(this), tokenId);
        // セール情報を記録
        sales[tokenId].seller = msg.sender;
        sales[tokenId].price = price;

        emit Selling(tokenId, msg.sender, price);
    }


    function buy(uint256 tokenId) public payable {
        uint256 price = sales[tokenId].price;
        address seller = sales[tokenId].seller;
        address buyer = msg.sender;
        require(price != 0, "nft on sele not found");
        require(msg.value == price, "sent eth dosen't match with price");

        // セール情報の初期化
        sales[tokenId].price = 0;
        sales[tokenId].seller = address(0);

        uint256 payment = price;

        // ERC-2981をサポートしているかチェック
        if (IERC165(nft).supportsInterface(type(IERC2981).interfaceId)) {
            (address receiver, uint256 royaltyAmount) = IERC2981(nft).royaltyInfo(tokenId, price);
            // サポートしていれば、ロイヤリティを支払う
            payment -= royaltyAmount;
            payable(receiver).transfer(royaltyAmount);
        }

        // 代金をsellerに支払う
        payable(seller).transfer(payment);
        // NFTをbuyerに移転する
        IERC721(nft).safeTransferFrom(address(this), buyer, tokenId);

        emit Sold(tokenId, buyer);
    }
}
