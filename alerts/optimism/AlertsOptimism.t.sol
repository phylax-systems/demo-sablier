// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23;

import { BaseSablierAlert } from "../base/BaseAlert.sol";

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
