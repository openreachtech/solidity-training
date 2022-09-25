# ロイヤリティスタンダードに対応したNFTマーケットプレイスを作ってみよう

## Steps
1. ロイヤリティスタンダードとは
2. EIP-2981の仕様解説
3. EIP-2981準拠のNFTを実装
4. 簡単なマーケットプレイスを作る

## 1. ロイヤリティスタンダードとは
一言でいうと、NFTが売買された時にクリエイターに支払われるロイヤリティ（報酬）の額を規定した規格です。
[EIP-2981](https://eips.ethereum.org/EIPS/eip-2981)で定義されています。
これはNFTのクリエイターに持続的に報酬を与える仕組みで、NFTが転売された時に売却価格の数パーセントがクリエイターに支払われます。意図としては、クリエイターに強いモチベーションを与えることで、多くのNFTを作成してもらい、市場を活性化することです。ポイントとなるのは、支払うかどうかは任意であり、強制されないということです。規格化により、NFTのマーケットプレイス間の互換性が担保され、クリエイターが報酬を受け取り損ねるリスクを低減します。

## 2. EIP-2981の仕様解説
- TokenのIDと売却価格を入力に報酬を計算して、報酬の支払い額と支払い先アドレスを返却する
  - `royaltyAmount = (salePrice * feeRate) / 10000`
```solidity
interface IERC2981 is IERC165 {
    /// ERC165 bytes to add to interface array - set in parent contract
    /// implementing this standard
    ///
    /// bytes4(keccak256("royaltyInfo(uint256,uint256)")) == 0x2a55205a
    /// bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;
    /// _registerInterface(_INTERFACE_ID_ERC2981);

    /// @notice Called with the sale price to determine how much royalty
    //          is owed and to whom.
    /// @param _tokenId - the NFT asset queried for royalty information
    /// @param _salePrice - the sale price of the NFT asset specified by _tokenId
    /// @return receiver - address of who should be sent the royalty payment
    /// @return royaltyAmount - the royalty payment amount for _salePrice
    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) external view returns (
        address receiver,
        uint256 royaltyAmount
    );
}
```
- EIP-2981のインターフェースをサポートする
  - これはマーケットプレイスに対して、NFTがEIP-2981に準拠していることを知らせるためのもの
  - [EIP-165](https://eips.ethereum.org/EIPS/eip-165)で規格化されている
    - 自分のコントラクトが何のインターフェースをサポートしているか、別のコントラクトに知らせる仕組みを提供
    - `interfaceID`はすべての関数のfunction selectorのXOR
      - function selectorは関数のI/Oをkeccak256でハッシュ化したものの最初の４バイト
        - `bytes4(keccak256("royaltyInfo(uint256,uint256)")) == 0x2a55205a`
    - `interfaceID`を引数に`supportsInterface`を呼び出した時に`true`ならinterfaceIDに対応するinterfaceをサポートしているとみなす
    - EIP-2981のinterfaceIDは`0x2a55205a`
```solidity
interface IERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}
```

## 3. EIP-2981準拠のNFTを実装
まず、EIP-2981に準拠した[RoyaltyStandard.sol](./RoyaltyStandard.sol)を実装します。
そして、RoyaltyStandardを継承したNFTとして[SimpleNFT.sol](./SimpleNFT.sol)を実装します。


## 4. 簡単なマーケットプレイスを作る
ロイヤリティーの分配を試すために簡単なマーケットプレイスを作ります。
仕様としては「指定の価格でNFTを出品して落札できる」とします。

## 5. コントラクトを動かしてみる
実際にNFTを発行してマーケットプレースで売買します。

### 手順
1. NFTとマーケットプレイスをデプロイ
    - マーケットプレイスコントラクトの引数にNFTのアドレスを指定
2. NFTを発行
    - SimpleNFT@mint
3. NFTコントラクトでマーケットプレースのアドレスをapprove
    - SimpleNFT@approve
4. マーケットプレースに出品
    - SimpleMarketplace@sell
5. マーケットプレースで購入
    - SimpleMarketplace@buy
