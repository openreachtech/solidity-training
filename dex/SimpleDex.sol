// SPDX-License-Identifier: Apache License 2.0
pragma solidity >=0.7.0 <0.9.0;

import "github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.7.3/contracts/token/ERC20/IERC20.sol";
import "./LiquidityToken.sol";

contract SimpleDEX {
    // LPトークンのmap
    mapping(address => mapping(address => address)) public lptokens;

    event PairCreated(address indexed token0, address indexed token1, address lptoken);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        address to
    ) public returns (uint amountA, uint amountB, uint liquidity) {
        // ソート
        // 例えば、初回にtokenA=hoge,tokenB=fugaが指定されて、２回目にtokenA=fuga,tokenB=hogeが指定されても、いいように。
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        (uint amount0Desired, uint amount1Desired) = sortAmounts(tokenA, tokenB, amountADesired, amountBDesired);

        // Liquidityを追加する
        (address lptoken, uint amount0, uint amount1) = _addLiquidity(token0, token1, amount0Desired, amount1Desired);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0); 

        // LPトークンをmintする        
        liquidity = LiquidityToken(lptoken).mint(to);
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        address to
    ) public returns (uint amountA, uint amountB) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        address lptoken = lptokens[token0][token1];

        // burnする分のLPトークンをLPコントラクトにデポジット
        LiquidityToken(lptoken).transferFrom(msg.sender, lptoken, liquidity);

        // LPトークンをburn
        (uint amount0, uint amount1) = LiquidityToken(lptoken).burn(to);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
    }

    function swap(
        uint amountIn,
        bool swapsTokenA,
        address tokenA,
        address tokenB,
        address to
    ) public returns (uint amountOut) {
        require(amountIn > 0, "insufficinet input amount");

        (address token0, address token1) = sortTokens(tokenA, tokenB);
        address lptoken = lptokens[token0][token1];

        { // ローカル変数が多いと”stack too deep”になるので、避ける
            (uint reserve0, uint reserve1) = LiquidityToken(lptoken).getReserves();
            (uint reserveIn, uint reserveOut) = (tokenA == token0 && swapsTokenA) || (tokenA != token0 && !swapsTokenA) ?  (reserve0, reserve1) : (reserve1, reserve0);
            amountOut = amountIn * reserveOut / reserveIn;
        }

        if (swapsTokenA) IERC20(tokenA).transferFrom(msg.sender, lptoken, amountIn);
        else IERC20(tokenB).transferFrom(msg.sender, lptoken, amountIn);
        
        (uint amountAOut, uint amountBOut) = swapsTokenA ? (uint(0), amountOut) : (amountOut, uint(0));
        (uint amount0Out, uint amount1Out) = sortAmounts(tokenA, tokenB, amountAOut, amountBOut);
        LiquidityToken(lptoken).swap(amount0Out, amount1Out, to);
    }

    function sortAmounts(address tokenA, address tokenB, uint amountA, uint amountB) internal pure returns (uint amount0, uint amount1) {
        require(amountA > 0 || amountB > 0, "either amount is zero");
        (amount0, amount1) = tokenA < tokenB ? (amountA, amountB) : (amountB, amountA);
    }

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "both tokens are same address");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        // もう片方のチェックはしなくてもいい。ソートしているので
        require(token0 != address(0), "one of token is zero address");
    }

    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        amountB = amountA * reserveB / reserveA;
    }

    function _addLiquidity(
        address token0,
        address token1,
        uint amount0Desired,
        uint amount1Desired
    ) private returns (address lptoken, uint amount0, uint amount1) {
        // もし、LPトークンが存在しなければ、新規作成
        lptoken = lptokens[token0][token1];
        if (lptoken == address(0)) {
            lptoken = createPair(token0, token1);
        }

        // LPトークンが持っている残高を取得
        (uint reserve0, uint reserve1) = LiquidityToken(lptoken).getReserves();

        if (reserve0 == 0 && reserve1 == 0) {
            //  残高ゼロの場合は、指定された量を(主に、新規でLPトークンを作った場合)
            (amount0, amount1) = (amount0Desired, amount1Desired);
        } else if (amount0Desired > 0) {
            // token0のamountが指定されたら
            amount0 = amount0Desired;
            amount1 = quote(amount0, reserve0, reserve1);
        } else if (amount1Desired > 0) {
            // token1のamountが指定されたら
            amount1 = amount1Desired;
            amount0 = quote(amount1Desired, reserve1, reserve0);
        } else {
            revert("no desired amount");
        }

        // Liquidityを追加する
        IERC20(token0).transferFrom(msg.sender, lptoken, amount0);
        IERC20(token1).transferFrom(msg.sender, lptoken, amount1);
    }

    function createPair(address token0, address token1) internal returns (address lptoken) {
        require(lptokens[token0][token1] == address(0), "already exist");

        // tokenペアのアドレスから決定的にLPトークンを作るために`create2`を使う
        // もし、”new”で生成してしまうと、実行者によってアドレスが変わってしまう
        bytes memory bytecode = type(LiquidityToken).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            lptoken := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        // LPトークンにトークンペアを登録
        LiquidityToken(lptoken).initialize(token0, token1);
        lptokens[token0][token1] = lptoken;

        emit PairCreated(token0, token1, lptoken);
    }

}
