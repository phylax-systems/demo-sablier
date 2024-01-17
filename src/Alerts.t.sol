// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23;

import { Alert } from "phylax-std/src/Alert.sol";
import { console2 } from "forge-std/console2.sol";

import { Mainnet_Addresses } from "./MainnetAddresses.t.sol";

abstract contract Base_Sablier_Alert is Alert {
    address _dai;
    address _usdc;
    address _usdt;

    constructor(address dai_, address usdc_, address usdt_) {
        _dai = dai_;
        _usdc = usdc_;
        _usdt = usdt_;
    }

    function test_balance_alert(address token, address sablier_contract) internal {
        uint256 current_balance = IERC20Like(token).balanceOf(sablier_contract);

        // roll back 5 blocks
        vm.rollFork({ blockNumber: block.number - 5 });

        uint256 previous_balance = IERC20Like(token).balanceOf(sablier_contract);

        // check if the previous balance is 30% less than the current balance
        bool alert = current_balance * 70 / 100 > previous_balance;

        string memory token_symbol = IERC20Like(token).symbol();

        string memory has_or_has_not = alert ? " has " : " has not ";

        string memory s =
            string.concat("The balance of ", token_symbol, has_or_has_not, "decreased by 30% in the last 5 blocks");

        console2.log(s);

        assertTrue(true);
    }

    function test_stablecoin_alert(address token, address sablier_contract) internal {
        uint256 current_stream_id = ISablierV2LockupLike(sablier_contract).nextStreamId();

        // roll back 5 blocks
        vm.rollFork({ blockNumber: block.number - 5 });

        uint256 previous_stream_id = ISablierV2LockupLike(sablier_contract).nextStreamId();

        uint256 deposited_sum;

        for (uint256 i = previous_stream_id; i < current_stream_id; ++i) {
            address asset = ISablierV2LockupLike(sablier_contract).getAsset(i);

            if (asset == token) {
                deposited_sum += ISablierV2LockupLike(sablier_contract).getDepositedAmount(i);
            }
        }

        uint8 decimals = IERC20Like(token).decimals();

        // check if there has been deposited more than 50k
        bool alert = 10 ** decimals * 50_000 < deposited_sum;

        string memory token_symbol = IERC20Like(token).symbol();
        string memory has_or_has_not = alert ? " has " : " has not ";

        string memory s = string.concat(
            "There", has_or_has_not, "been deposited more than 50k ", token_symbol, " in the last 5 blocks"
        );

        console2.log(s);

        assertTrue(true);
    }

    function test_stablecoins_alert(address sablier_contract) internal {
        test_stablecoin_alert(_dai, sablier_contract);
        test_stablecoin_alert(_usdc, sablier_contract);
        test_stablecoin_alert(_usdt, sablier_contract);
    }
}

contract Alerts_Mainnet is Mainnet_Addresses, Base_Sablier_Alert {
    constructor()
        Base_Sablier_Alert(
            0x6B175474E89094C44Da98b954EedeAC495271d0F,
            0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
            0xdAC17F958D2ee523a2206206994597C13D831ec7
        )
    { }

    uint256 mainnet;

    function setUp() public {
        mainnet = enableChain("mainnet");
    }

    function test_tokens_balance_mainnet() public chain(mainnet) {
        // v1.0 tokens
        for (uint256 i; i < tokens_v10.length; ++i) {
            test_balance_alert(tokens_v10[i], sablier_v10);
        }

        // v1.1 tokens
        for (uint256 i; i < tokens_v11.length; ++i) {
            test_balance_alert(tokens_v11[i], sablier_v11);
        }

        // v2.0 tokens
        for (uint256 i; i < tokens_v20.length; ++i) {
            test_balance_alert(tokens_v20[i], sablier_v20_linear);
        }
    }

    function test_stablecoins_mainnet() public chain(mainnet) {
        test_stablecoins_alert(sablier_v21_linear);
    }
}

contract Alerts_Optimism is Base_Sablier_Alert {
    address exa = 0x1e925De1c68ef83bD98eE3E130eF14a50309C01B;

    address sablier_v20_linear = 0xB10daee1FCF62243aE27776D7a92D39dC8740f95;
    address sablier_v21_linear = 0x4b45090152a5731b5bc71b5baF71E60e05B33867;

    constructor()
        Base_Sablier_Alert(
            0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1,
            0x0b2C639c533813f4Aa9D7837CAf62653d097Ff85,
            0x94b008aA00579c1307B0EF2c499aD98a8ce58e58
        )
    { }

    uint256 optimism;

    function setUp() public {
        optimism = enableChain("optimism");
    }

    function test_tokens_balance_optimism() public chain(optimism) {
        test_balance_alert(exa, sablier_v20_linear);
    }

    function test_stablecoins_optimism() public chain(optimism) {
        test_stablecoins_alert(sablier_v21_linear);
    }
}

contract Alerts_Arbitrum is Base_Sablier_Alert {
    address sablier_v20_linear = 0xB10daee1FCF62243aE27776D7a92D39dC8740f95;
    address sablier_v21_linear = 0xFDD9d122B451F549f48c4942c6fa6646D849e8C1;

    constructor()
        Base_Sablier_Alert(
            0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1,
            0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9,
            0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9
        )
    { }

    uint256 arbitrum;

    function setUp() public {
        arbitrum = enableChain("arbitrum");
    }

    function test_stablecoins_arbitrum() public chain(arbitrum) {
        test_stablecoins_alert(sablier_v21_linear);
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
