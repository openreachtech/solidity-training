# ガス代を肩代わりするmeta transactionのRelayerを作ってみる

## Steps
1. meta transactionとは
2. meta transactionの作り方
3. EIP-2981準拠のNFTを実装
4. 簡単なマーケットプレイスを作る

## 1. meta transactionとは
一言でいうと「実際に実行したい処理のトランザクション」をラップしたトランザクションです。ラップすることで`実際に実行したい処理`のガス代を肩代わりすることが可能です。`実際に実行したい処理`は、その処理を実行させたいユーザによって署名されていて、そのユーザのコンテキストで実行されます。

例えば、とあるDappsの運営者が、Ethereumウォレットの扱いに不慣れであったり、ETHを所有していなユーザも取り込みたい場合に使われます。ガス代を支払うのDapps運営者で、Dapps利用者はガス代支払うことなく、サービスを利用できます。


## 2. meta transactionの作り方
```javascript

```

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
まずEIP-2981に準拠した[RoyaltyStandard.sol](./RoyaltyStandard.sol)を実装する。
次に、最低限の機能を実装したNFTとして[SimpleNFT.sol](./SimpleNFT.sol)を実装し、RoyaltyStandardコントラクトを継承する。


## 4. 簡単なマーケットプレイスを作る
ロイヤリティーの分配を試すために簡単なマーケットプレイスを作る
仕様としては、指定の価格でNFTを出品して落札できる。

## 5. コントラクトを動かしてみる
実際にNFTを発行してマーケットプレースで売買してみる

### 手順
1. NFTを発行
  - SimpleNFT@mint
2. マーケットプレースのアドレスをapproveNFT
  - SimpleNFT@approve
3. マーケットプレースに出品
  - SimpleMarketplace@sell
4. マーケットプレースで購入
  - SimpleMarketplace@buy
