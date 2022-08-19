# Tokenを配布してみよう

## Steps
1. Metamaskを使ってみよう
2. テストネットのETHを取得
3. Tokenをテストネットにデプロイしてみる
4. Tokenを発行してみる

## 1. Metamaskを使ってみよう
[Metamask](https://metamask.io/)はEthereumのブラウザウォレットです。ブラグインの形でインストールされます。
Chrome、Firefox、Edgeと主要なブラウザに対応していて、最も使われているウォレットです。
使いやすい反面、手数料として`0.3%`から`0.875%`を徴収されます。

## 2. テストネットのETHを取得
Ethereumのテストネットはいくつか存在します。The Merge後に多くが非推奨になります。
[NETWORKS](https://ethereum.org/en/developers/docs/networks/)

- Sepolia
 - proof-of-workなテストネット。2022年夏頃にproof-of-stakeへ移行予定。長期間にわたってメンテナンスされてゆくかは未定
- Goerli
 - proof-of-authorityなテストネット。2022年夏頃にテストネットとしては最後にproof-of-stakeに移行予定。長期間にわたってメンテナンスされてゆく予定
- Ropsten (非推奨)
 - proof-of-workなテストネットでしたが、2022年5月にproof-of-stakeに移行した。更新はされないため非推奨
- Rinkeby (非推奨)
 - proof-of-authorityなテストネット。古いバージョンのGethで運用されており、更新はされないため非推奨
- Kovan (非推奨)
 - とても古いproof-of-authorityなテストネット。更新はされないため非推奨。

[GoerliのFaucet](https://goerli-faucet.mudit.blog/)からテスト用のETHを取得します。

## 3. Tokenをテストネットにデプロイしてみる
前回開発した[Token.sol](../part2/Token.sol)をGoerliにデプロイします。
Remixを立ち上げてMetamaskと接続します。

## 4. Tokenを発行してみる
mint関数を実行してTokenを自分に配布します。配布したtokenをMetamaskに取り込んでみます。
