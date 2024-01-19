// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23;

import { BaseSablierAlert } from "../base/BaseAlert.sol";

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
