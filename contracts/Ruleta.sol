//SPDX-License-Identifier: MatiAlvarez21
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Ruleta {
    uint public funds;

    function placeBet(uint amount) external {
        funds += amount;
    }

    function payWinner(uint amount, address payable to) external {
        require(funds >= amount, "Contract funds too low");

        to.transfer(amount);
        funds -= amount;
    }

    function getFunds() external view returns(uint) {
        return funds;
    }

    receive() external payable {}

}