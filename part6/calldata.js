const Web3 = require("web3");

async function main() {
	const web3 = new Web3();

	// "setName"のcalldataを作る
	const newName = "piggy bank";
	let abiEncodedCall = web3.eth.abi.encodeFunctionCall({
	  name: 'setName',
	  type: 'function',
	  inputs: [
	  	{type: 'string', name: 'newName' },,
	  ]
	}, [newName]);
	console.log(`calldate of setName: ${abiEncodedCall}\n`)

	// "deposit"のcalldataを作る
	abiEncodedCall = web3.eth.abi.encodeFunctionCall({
	  name: 'deposit',
	  type: 'function',
	  inputs: []
	}, []);
	console.log(`calldata of deposit: ${abiEncodedCall}\n`)

	// "withdraw"のcalldataを作る
	const amount = "10000000000000000000" // 10 ETH
	abiEncodedCall = web3.eth.abi.encodeFunctionCall({
	  name: 'withdraw',
	  type: 'function',
	  inputs: [
	  	{type: 'uint256', name: 'amount' },
	  ]
	}, [amount]);
	console.log(`calldata of withdraw: ${abiEncodedCall}\n`)
}

main()
