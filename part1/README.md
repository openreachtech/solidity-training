# ブロックチェーンを立ち上げて、コントラクトを動かしてみよう

## Steps
1. ブロックチェーンを起動
2. 送金トランザクション
3. 簡単なコントラクトの開発
4. コントラクトのデプロイ
5. コントラクトの実行

## 1. ブロックチェーンを起動
Solidityが書けるエンジニアではなく、ブロックチェーンエンジニアになるために、まずはブロックチェーンを起動できるようになります。
まずは、GethというEthereumのコントラクトを実行する環境を、[公式サイト](https://geth.ethereum.org/docs/install-and-build/installing-geth#macos-via-homebrew)に従ってダウンロードします
```sh
# gethがインストールされたか確認
geth version
```

[The Merge](https://geth.ethereum.org/docs/interface/merge)以前は、Gethがコンセンサスも担当していましたが、The Merge以降は、コントラクトの実行だけを担います。

ローカルでのプライベートなEthereumネットワークをプライベートネットといいます。
ブライベートネットの設定ファイルを`puppeth`で作ります。これは、Gethをインストールした時に付属しているはずです。
```sh
# puppethが入っているか確認
puppeth --help

# gethフォルダに移動
cd geth

# 事前に１つアカウントを作っておきます
# - パスワードは空で大丈夫です
# - アドレスが表示されるので、メモしておきます
geth --datadir . account new
# --- output --- 
Password: 
Repeat password: 

Your new key was generated

Public address of the key:   0xc8037cb594FEB3d3454850d42CAb0497Dd04a134 # このアドレス！
Path of the secret key file: keystore/UTC--2022-08-16T03-53-21.309842000Z--c8037cb594feb3d3454850d42cab0497dd04a134

- You can share your public address with anyone. Others need it to interact with you.
- You must NEVER share the secret key with anyone! The key controls access to your funds!
- You must BACKUP your key file! Without the key, it's impossible to access account funds!
- You must REMEMBER your password! Without the password, it's impossible to decrypt the key!

# 設定ファイルを作ります
puppeth --network private
# --- output --- 
What would you like to do? (default = stats)
 1. Show network stats
 2. Configure new genesis
 3. Track new remote server
 4. Deploy network components
> 2 # 2を選びます

What would you like to do? (default = create)
 1. Create new genesis from scratch
 2. Import already existing genesis
> 1 # 1を選びます

Which consensus engine to use? (default = clique)
 1. Ethash - proof-of-work
 2. Clique - proof-of-authority
> 2 # 2を選びます。
    # - 1はマイニングを行います。CPUを消費するので、開発用途では使いません。
    # - 2はマイニングを行いません。CPUを消費しないので、開発用途で使います。

How many seconds should blocks take? (default = 15)
> 3 # ブロックの生成間隔です。開発用途なので短めに設定します。

Which accounts are allowed to seal? (mandatory at least one)
> 0xc8037cb594FEB3d3454850d42CAb0497Dd04a134 # 事前に作ったアカウントのアドレスを指定します
> 0x                                         # このアカウントが全てのトランザクションを承認します

Which accounts should be pre-funded? (advisable at least one)
> 0xc8037cb594FEB3d3454850d42CAb0497Dd04a134 # 同じアドレスを指定します。
> 0                                          # 最初から大量のETHがデポジットされます

Should the precompile-addresses (0x1 .. 0xff) be pre-funded with 1 wei? (advisable yes)
> # 何も入力しません

Specify your chain/network ID if you want an explicit one (default = random)
> 15 # 任意のプライベートネットワークIDを入力します。今回は15を指定します。
INFO [08-16|11:01:29.505] Configured new genesis block # 設定ファイルが作られました。
                                                       # 続けてexportします。

What would you like to do? (default = stats)
 1. Show network stats
 2. Manage existing genesis
 3. Track new remote server
 4. Deploy network components
> 2 # 2を選びます

 1. Modify existing configurations
 2. Export genesis configurations
 3. Remove genesis configuration
> 2 # 2を選びます

Which folder to save the genesis specs into? (default = current)
  Will create private.json, private-aleth.json, private-harmony.json, private-parity.json
> # 何も入力しません。
INFO [08-16|11:05:53.146] Saved native genesis chain spec          path=private.json # これを使います
ERROR[08-16|11:05:53.146] Failed to create Aleth chain spec        err="unsupported consensus engine"
ERROR[08-16|11:05:53.146] Failed to create Parity chain spec       err="unsupported consensus engine"
INFO [08-16|11:05:53.148] Saved genesis chain spec                 client=harmony path=private-harmony.json
```
`private.json`という名前のファイルが生成されます。こちらを使います。
他にも、`private-harmony.json`が生成されました。これは`Harmony`という名前のEthereumクライアント用の設定ファイルです。


ブロックチェーンを初期化します。
```sh
geth --datadir ./ init ./private.json
```

ブロックチェーンを起動します。
```sh
geth --datadir ./ --networkid 15
```

起動すると`geth.ipc`という名前のファイルが作られます。これはUNIXドメインソケットです。
このファイルディスクリプタを通じてGethと通信します。
別のターミナルを開いて、Gethに接続します。
```sh
geth attach geth.ipc
# --- output --- 
# アカウントを表示します。最初に作ったアドレスが表示されるはずです
> eth.accounts
["0xc8037cb594feb3d3454850d42cab0497dd04a134"]

# パスワードでLockされているので、Unlockします
# ""の部分にパスワードを入力します
> personal.unlockAccount(eth.accounts[0], "", 86400)
true

# 現在のBlock高さは０です。
> eth.blockNumber
0

# ブロックの生成を開始します。
> miner.start()
null

# ブロック高さが変化したのがわかります。
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
Password: 
Repeat password: 


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
9.04625697166532776746648320380374280103671755200316906558262375061821325312e+74

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

# ブロックの生成を停止します
> miner.stop()
null
```
