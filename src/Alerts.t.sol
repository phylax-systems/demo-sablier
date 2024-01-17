// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23;

import { Alert } from "phylax-std/src/Alert.sol";
import { console2 } from "forge-std/console2.sol";

import { MainnetAddresses } from "./MainnetAddresses.t.sol";

abstract contract BaseSablierAlert is Alert {
    address _dai;
    address _usdc;
    address _usdt;

    constructor(address dai_, address usdc_, address usdt_) {
        _dai = dai_;
        _usdc = usdc_;
        _usdt = usdt_;
    }

    function test_BalanceAlert(address token, address sablierContract) internal {
        uint256 currentBalance = IERC20Like(token).balanceOf(sablierContract);

        // roll back 5 blocks
        vm.rollFork({ blockNumber: block.number - 5 });

        uint256 previousBalance = IERC20Like(token).balanceOf(sablierContract);

        // check if the previous balance is 30% less than the current balance
        bool alert = currentBalance * 70 / 100 > previousBalance;

        string memory tokenSymbol = IERC20Like(token).symbol();

        string memory hasOrHasNot = alert ? " has " : " has not ";

        string memory s =
            string.concat("The balance of ", tokenSymbol, hasOrHasNot, "decreased by 30% in the last 5 blocks");

        console2.log(s);

        assertTrue(true);
    }

    function test_StablecoinAlert(address token, address sablierContract) internal {
        uint256 currentStreamId = ISablierV2LockupLike(sablierContract).nextStreamId();

        // roll back 5 blocks
        vm.rollFork({ blockNumber: block.number - 5 });

        uint256 previousStreamId = ISablierV2LockupLike(sablierContract).nextStreamId();

        uint256 depositedSum;

        for (uint256 i = previousStreamId; i < currentStreamId; ++i) {
            address asset = ISablierV2LockupLike(sablierContract).getAsset(i);

            if (asset == token) {
                depositedSum += ISablierV2LockupLike(sablierContract).getDepositedAmount(i);
            }
        }

        uint8 decimals = IERC20Like(token).decimals();

        // check if there has been deposited more than 50k
        bool alert = 10 ** decimals * 50_000 < depositedSum;

        string memory tokenSymbol = IERC20Like(token).symbol();
        string memory hasOrHasNot = alert ? " has " : " has not ";

        string memory s =
            string.concat("There", hasOrHasNot, "been deposited more than 50k ", tokenSymbol, " in the last 5 blocks");

        console2.log(s);

        assertTrue(true);
    }

    function test_StablecoinsAlert(address sablierContract) internal {
        test_StablecoinAlert(_dai, sablierContract);
        test_StablecoinAlert(_usdc, sablierContract);
        test_StablecoinAlert(_usdt, sablierContract);
    }
}

contract AlertsMainnet is MainnetAddresses, BaseSablierAlert {
    constructor()
        BaseSablierAlert(
            0x6B175474E89094C44Da98b954EedeAC495271d0F,
            0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
            0xdAC17F958D2ee523a2206206994597C13D831ec7
        )
    { }

    uint256 mainnet;

    function setUp() public {
        mainnet = enableChain("mainnet");
    }

    function test_TokensBalance_Mainnet() public chain(mainnet) {
        // v1.0 tokens
        for (uint256 i; i < tokensV10.length; ++i) {
            test_BalanceAlert(tokensV10[i], sablierV10);
        }

        // v1.1 tokens
        for (uint256 i; i < tokensV11.length; ++i) {
            test_BalanceAlert(tokensV11[i], sablierV11);
        }

        // v2.0 tokens
        for (uint256 i; i < tokensV20.length; ++i) {
            test_BalanceAlert(tokensV20[i], sablierV20Linear);
        }
    }

    function test_Stablecoins_Mainnet() public chain(mainnet) {
        test_StablecoinsAlert(sablierV21Linear);
    }
}

contract AlertsOptimism is BaseSablierAlert {
    address exa = 0x1e925De1c68ef83bD98eE3E130eF14a50309C01B;

    address sablierV20Linear = 0xB10daee1FCF62243aE27776D7a92D39dC8740f95;
    address sablierV21Linear = 0x4b45090152a5731b5bc71b5baF71E60e05B33867;

    constructor()
        BaseSablierAlert(
            0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1,
            0x0b2C639c533813f4Aa9D7837CAf62653d097Ff85,
            0x94b008aA00579c1307B0EF2c499aD98a8ce58e58
        )
    { }

    uint256 optimism;

    function setUp() public {
        optimism = enableChain("optimism");
    }

    function test_TokensBalance_Optimism() public chain(optimism) {
        test_BalanceAlert(exa, sablierV20Linear);
    }

    function test_Stablecoins_Optimism() public chain(optimism) {
        test_StablecoinsAlert(sablierV21Linear);
    }
}

contract AlertsArbitrum is BaseSablierAlert {
    address sablierV20Linear = 0xB10daee1FCF62243aE27776D7a92D39dC8740f95;
    address sablierV21Linear = 0xFDD9d122B451F549f48c4942c6fa6646D849e8C1;

    constructor()
        BaseSablierAlert(
            0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1,
            0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9,
            0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9
        )
    { }

    uint256 arbitrum;

    function setUp() public {
        arbitrum = enableChain("arbitrum");
    }

    function test_Stablecoins_Arbitrum() public chain(arbitrum) {
        test_StablecoinsAlert(sablierV21Linear);
    }
}

interface IERC20Like {
    function balanceOf(address) external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
}

interface ISablierV2LockupLike {
    function getAsset(uint256) external view returns (address);
    function getDepositedAmount(uint256) external view returns (uint128);
    function nextStreamId() external view returns (uint256);
}
