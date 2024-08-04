# ブロックチェーンを立ち上げて、コントラクトを動かしてみよう

## Steps
1. ブロックチェーンを起動
2. 送金トランザクション
3. 簡単なコントラクトの開発
4. コントラクトのデプロイ
5. コントラクトの実行

## 1. ブロックチェーンを起動
Solidityが書けるエンジニアではなく、ブロックチェーンエンジニアになるために、まずはブロックチェーンを起動できるようになります。
まずは、GethというEthereumのコントラクトを実行するプログラムを、[公式サイト](https://geth.ethereum.org/downloads)からダウンロードします。
最新バージョンではなく、v1.13をダウンロードしてください。
[The Merge](https://geth.ethereum.org/docs/interface/merge)という大型アップデート以降、Gethを単体で動かす機能が制限されるようになりました。そのため、古いバージョンである必要があります。今日のEthereumはGethとコンセンサスを行う２つのプログラムで稼働します。今回は単純化のため、Gethのみを使用します。

解答した中身にgethというプログラムが入っています。実行環境で動作するか確認します。
```sh
# gethがインストールされたか確認
geth version
```


ローカルでのプライベートなEthereumネットワークをプライベートネットといいます。
プライベートネットを起動するにはマイナーのアカウントが必要です。インストールしたgethを使って作ります。
```sh
# - パスワードの入力を求められるので、任意の値を指定します。
# - アドレスが表示されるので、メモしておきます
geth --datadir . account new
# --- output ---
Password: 12345
Repeat password: 12345

Your new key was generated

Public address of the key:   0x77497Dc42E9C55AB9503135b7cbe9e1830895235 # このアドレス！
Path of the secret key file: keystore/UTC--2024-08-03T11-36-06.056219000Z--77497dc42e9c55ab9503135b7cbe9e1830895235

- You can share your public address with anyone. Others need it to interact with you.
- You must NEVER share the secret key with anyone! The key controls access to your funds!
- You must BACKUP your key file! Without the key, it's impossible to access account funds!
- You must REMEMBER your password! Without the password, it's impossible to decrypt the key!
```
ブロックチェーンのアカウントは秘密鍵で表現されます。生成された秘密鍵は`keystore`フォルダ配下にJSON形式のファイルとして入っています。
この秘密鍵に対応する公開鍵から生成された文字列がアドレスです。上のアウトプットの`Public address of the key` に続くランダムな文字列がアドレスです。
ブロックチェーンではアカウントをこのアドレスで識別します。

次に、このアドレスに初期デポジットとして100ETHが付与されるように設定します。
`genesis.json`を編集して、`[miner address]`を生成されたアドレスで置き換えてください。先頭の`0x`を抜いた形とし、２箇所入れ替えます。
このファイルにチェーンを立ち上げる時の設定を記載します。
```json
{
  "extradata": "0x0000000000000000000000000000000000000000000000000000000000000000[miner address]0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
  "alloc": {
    "0x[miner address]": {
      "__name__": "Miner Account",
      "balance": "0x64"
    }
  }
}
```

ブロックチェーンを初期化します。
```sh
# 初期化
geth --datadir ./ init ./genesis.json
```
パスワードファイルを作ります。
```sh
echo 123455 > ./password.txt
```
起動します。
```sh
# 起動
geth --datadir ./ --mine --miner.etherbase 0x[miner address] --unlock 0 --password ./password.txt
```

起動すると`geth.ipc`という名前のファイルが作られます。これはUNIXドメインソケットです。
このファイルディスクリプタを通じてGethと通信します。
別のターミナルを開いて、Gethに接続します。
```sh
geth attach geth.ipc
# --- output ---
# アカウントを表示します。最初に作ったアドレスが表示されるはずです
> eth.accounts
["0x77497Dc42E9C55AB9503135b7cbe9e1830895235"]

# ブロック高さを確認できます
> eth.blockNumber
3

```

## 2. 送金トランザクション
プライベートチェーンでETHを送ってみます。
別のコーンソールを開いて、相手のアカウントを作ります。
```sh
geth --datadir . account new
# --- output ---
INFO [08-16|11:48:18.836] Maximum peer count                       ETH=50 LES=0 total=50
Your new account is locked with a password. Please give a password. Do not forget this password.
Password: 12345
Repeat password: 12345

Your new key was generated

Public address of the key:   0xe4b1DEfd7E585f0fce7B96B7Af154DC2CDFf21aa # 相手のアドレスをメモ
Path of the secret key file: keystore/UTC--2022-08-16T04-48-20.146220000Z--e4b1defd7e585f0fce7b96b7af154dc2cdff21aa

- You can share your public address with anyone. Others need it to interact with you.
- You must NEVER share the secret key with anyone! The key controls access to your funds!
- You must BACKUP your key file! Without the key, it's impossible to access account funds!
- You must REMEMBER your password! Without the password, it's impossible to decrypt the key!
```

Gethに接続されたコンソールに戻ります。
```sh
# まずは、自分のアカウントバランスを確認します。
> eth.getBalance(eth.accounts[0])
100000000000000000000

# 相手のアカウントバランスは0です
> eth.getBalance("0xe4b1DEfd7E585f0fce7B96B7Af154DC2CDFf21aa")
0

# 1ETH、送ります
> eth.sendTransaction({from: eth.accounts[0], to: "0xe4b1DEfd7E585f0fce7B96B7Af154DC2CDFf21aa", value: web3.toWei(1,"ether")})
"0x85c6d69c17f420803eac40d2449b6e09ecb1167f74d343df19a5dbada527f82f" # これは送金トランザクションのトランザクションハッシュです

# 相手のバランスが更新されます
> eth.getBalance("0xe4b1DEfd7E585f0fce7B96B7Af154DC2CDFf21aa")
1000000000000000000 # weiという単位で表示されます。1ETH=10**18 weiなので、0が18個並んでいます。
```

## 3. 簡単なコントラクトを開発
データを入れて、表示するだけの簡単なコントラクトを開発します。
[Storage.sol](./Storage.sol)

開発したコントラクトをコンパイルします。
まずはコンパイラーをインストールします。
```sh
# インストール
npm install -g solc

# 確認
solc --version
```
[Installing the Solidity Compiler](https://docs.soliditylang.org/en/v0.8.16/installing-solidity.html#npm-node-js)

コンパイルします。
```sh
solc --output-dir ./ --bin --abi --overwrite Storage.sol
```
currentディレクトリに`bin`と`abi`ファイルが作られます。
`bin`がコンパイルされたバイナリファイルです。
`abi`の方が、コントラクトを実行するためのI/Oが定義されたファイルです。

## 4. コントラクトのデプロイ
プライベートネットにStorageコントラクトをデプロイします。
Gethに接続しているターミナルを開きます。
```sh
# eth.contract(<ここにStorage.abiの中身を入れます>)
storage = eth.contract([{"inputs":[],"name":"retrieve","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"num","type":"uint256"}],"name":"store","outputs":[],"stateMutability":"nonpayable","type":"function"}])

# "0x" + "<ここにStorage.binの中身を入れます>"
compiled = "0x" + "608060405234801561001057600080fd5b50610150806100206000396000f3fe608060405234801561001057600080fd5b50600436106100365760003560e01c80632e64cec11461003b5780636057361d14610059575b600080fd5b610043610075565b60405161005091906100a1565b60405180910390f35b610073600480360381019061006e91906100ed565b61007e565b005b60008054905090565b8060008190555050565b6000819050919050565b61009b81610088565b82525050565b60006020820190506100b66000830184610092565b92915050565b600080fd5b6100ca81610088565b81146100d557600080fd5b50565b6000813590506100e7816100c1565b92915050565b600060208284031215610103576101026100bc565b5b6000610111848285016100d8565b9150509291505056fea26469706673582212206713dacf42c74711b2f76573c9cdded1022c2aec004e46a23af6f351978fca0964736f6c634300080a0033"


# コントラクトをデプロイします
storage = storage.new({from: eth.accounts[0], data: compiled, gas: 1000000}, function(err, contract) {
	if (err) { console.log(err); return; }
	if(!contract.address) { console.log("transaction send: transactionHash: " + contract.transactionHash); return; }
	console.log("contract mined! address: " + contract.address);
})
# --- output ---
transaction send: transactionHash: 0x171f42fa371ca2bdf23821aa7e06e2c4841d97f90d19762cd3aa967534d37292 # デプロイトランザクションのハッシュ
{
  abi: [{
      inputs: [],
      name: "retrieve",
      outputs: [{...}],
      stateMutability: "view",
      type: "function"
  }, {
      inputs: [{...}],
      name: "store",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function"
  }],
  address: undefined,
  transactionHash: "0x171f42fa371ca2bdf23821aa7e06e2c4841d97f90d19762cd3aa967534d37292"
}
> contract mined! address: 0x972edc90a4ed0d9f841979cb6bdf9a7eb26bbbb4 #デプロイされたコントラクトのアドレス
```


## 5. コントラクトの実行
デプロイしたコントラクトを実行します
```sh
# "storage"という変数にコントラクトの情報が入っていることを確認します
> storage
# --- output ---
{
  abi: [{
      inputs: [],
      name: "retrieve",
      outputs: [{...}],
      stateMutability: "view",
      type: "function"
  }, {
      inputs: [{...}],
      name: "store",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function"
  }],
  address: "0x972edc90a4ed0d9f841979cb6bdf9a7eb26bbbb4",
  transactionHash: "0x171f42fa371ca2bdf23821aa7e06e2c4841d97f90d19762cd3aa967534d37292",
  allEvents: function bound(),
  retrieve: function bound(),
  store: function bound()
}

# もし入っていない場合、作り直します
# storage = eth.contract(<abiの内容>).at(<コントラクトのアドレス>);

# '123'という数値を格納してみます
storage.store(123, {from: eth.accounts[0]}, function(err, result) {
	if (err) { console.log(err); return; }
	console.log("transaction hash: ", result);
});
# --- output ---
transaction hash:  0x537c0a1d644ea357ad15e851f7a1207260d40b59391a7666ec79420b4d48a307

# '123'が格納されたことを確認します。
> storage.retrieve.call()
123
```
