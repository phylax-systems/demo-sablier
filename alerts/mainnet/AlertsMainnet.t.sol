// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23;

import { MainnetAddresses } from "./MainnetAddresses.t.sol";
import { BaseSablierAlert } from "../base/BaseAlert.sol";

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
