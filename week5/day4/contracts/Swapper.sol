pragma solidity 0.8.17;

interface IERC20 {
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);
}

interface UniV3Router {
    function exactInputSingle(
        ExactInputSingleParams calldata params
    ) external payable returns (uint256 amountOut);

    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }
}

contract Swapper {
    UniV3Router public constant uniV3Router =
        UniV3Router(0xE592427A0AEce92De3Edee1F18E0157C05861564);

    function swap(UniV3Router.ExactInputSingleParams calldata params) external {
        IERC20(params.tokenIn).transferFrom(
            msg.sender,
            address(this),
            params.amountIn
        );
        IERC20(params.tokenIn).approve(address(uniV3Router), params.amountIn);
        uniV3Router.exactInputSingle(params);
    }
}
