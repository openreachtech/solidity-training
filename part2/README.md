# Tokenコントラクトを作ってみよう

## Steps
1. Remixを使ってみよう
2. Tokenコントラクトの仕様解説
3. Tokenコントラクトの開発
4. 動かしてみよう

## 1. Remixを使ってみよう
[Remix](https://remix-project.org/)はSolidityの統合開発環境です。
ブラウザ上でコントラクトの動作確認ができます。
デフォルトで入っているプロジェクトを通して、操作感を把握します。part1で使った[Storage.sol](../part1/Storage.sol)は、ここに入ってます。

## 2. Tokenコントラクトの仕様解説
ERC20で規格されたTokenを簡略化した仕様のTokenを開発します。
まず、TokenとはEthereum上で発行するポイントのようなものです。楽天ポイントやLineポイントのように自分達で自由に発行できます。
ただ、取引所でトレードできるように、規格が統一されています。20番目に提案された規格なので`ERC20`という名前がついています。
詳しい説明は「[ERC-20Tokenの紹介](https://academy.binance.com/ja/articles/an-introduction-to-erc-20-tokens)」をご参照ください。

### 仕様
1. Tokenの名前がわかる
2. 発行できる
3. 総発行数がわかる
4. 所有数がわかる
5. Tokenを誰かに送れる

こちらの５ステップが実行できるような、Tokenの基本的な機能を実装します。

### 1. Tokenの名前がわかる
- Token名を返す関数
```javascript
function name() public view returns (string)
```

### 2. 発行できる
- 「誰(`account`)に対して、何枚(`amount`)発行する」ような関数
```javascript
function mint(address account, uint256 amount) public;
```

### 3. 総発行数がわかる
- Tokenの総発行量を返す
```javascript
function totalSupply() public view returns (uint256)
```

### 4. 所有数がわかる
- 「誰(`account`)が、何枚Tokenを持っているか」を返す関数
```javascript
function balanceOf(address account) public view returns (uint256)
```

### 5. Tokenを誰かに送れる
- 「自分の所有するTokenを、誰(`to`)に対して、何枚(`amount`)を送る」ような関数
```javascript
function transfer(address to, uint256 amount) public
```

## 3. Tokenコントラクトの開発
上の仕様を満たすコントラクトの例として、[Token.sol](./Token.sol)を開発します。
Remixでワークスペースを新設して、コードを書いてみます。コンパイルが通ることを確認します。


## 4. 動かしてみよう
Remix上で動作確認します。
前回は、プライベートネット上にデプロイして動作確認をしました。こちらの方が実際の動作環境に近いですが、手間がかかるのが難点です。
今回は、ブラウザ上で動作する仮想的なスマートコントラクトの実行環境（`Remix VM`）を使います。何といっても「deploy」ボタンを押すだけという手軽さが魅力です。
