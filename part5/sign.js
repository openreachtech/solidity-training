const Web3 = require("web3");

// 秘密鍵に対応するアドレス: 0xE3b0DE0E4CA5D3CB29A9341534226C4D31C9838f
const PRI_KEY = "d1c71e71b06e248c8dbe94d49ef6d6b0d64f5d71b1e33a0f39e14dadb070304a"

async function main() {
	const web3 = new Web3();
	const wallet = web3.eth.accounts.privateKeyToAccount(PRI_KEY);

	// 関数のcalldataを作る
	const name = "tom";
	const age = 21;
	const isMale = true;
	const abiEncodedCall = web3.eth.abi.encodeFunctionCall({
	  name: 'regist',
	  type: 'function',
	  inputs: [
	  	{type: 'string', name: 'name' },
	  	{type: 'uint8', name: 'age' },
	  	{type: 'bool', name: 'isMale' },
	  ]
	}, [name, age, isMale]);
	console.log(`calldate: ${abiEncodedCall}`)

	// calldataのハッシュ値に署名する
	const hash = web3.utils.soliditySha3(abiEncodedCall);
	const sig = await web3.eth.accounts.sign(hash, wallet.privateKey);
	console.log(sig)
}

main()
