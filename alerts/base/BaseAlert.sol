// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23;

import { Alert } from "phylax-std/src/Alert.sol";
import { console2 } from "forge-std/console2.sol";

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

        if (alert) {
            string memory tokenSymbol = IERC20Like(token).symbol();
            string memory s = string.concat("The balance of ", tokenSymbol, "has decreased by 30% in the last 5 blocks");
            revert(s);
        }
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

        if (alert) {
            string memory tokenSymbol = IERC20Like(token).symbol();
            string memory s =
                string.concat("There has been deposited more than 50k ", tokenSymbol, " in the last 5 blocks");
            revert(s);
        }
    }

    function test_StablecoinsAlert(address sablierContract) internal {
        test_StablecoinAlert(_dai, sablierContract);
        test_StablecoinAlert(_usdc, sablierContract);
        test_StablecoinAlert(_usdt, sablierContract);
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
