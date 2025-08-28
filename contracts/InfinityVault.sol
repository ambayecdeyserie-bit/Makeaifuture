// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/// @title Infinity Vault - Earnings splitter for IEM agents
contract InfinityVault {
    address public owner;
    address public gnosisSafe;

    // Pool addresses
    address public reinvestmentPool;
    address public agentUpgradeFund;
    address public bountyNovaRedistribution;

    event EarningsReceived(address indexed from, uint256 amount);
    event EarningsSplit(uint256 reinvestment, uint256 upgrade, uint256 bounty);

    constructor(
        address _gnosisSafe,
        address _reinvestmentPool,
        address _agentUpgradeFund,
        address _bountyNovaRedistribution
    ) {
        owner = msg.sender;
        gnosisSafe = _gnosisSafe;
        reinvestmentPool = _reinvestmentPool;
        agentUpgradeFund = _agentUpgradeFund;
        bountyNovaRedistribution = _bountyNovaRedistribution;
    }

    receive() external payable {
        emit EarningsReceived(msg.sender, msg.value);
        splitEarnings(msg.value);
    }

    /// @dev Splits incoming ETH according to the matrix: 60/30/10
    function splitEarnings(uint256 amount) internal {
        uint256 reinvestment = (amount * 60) / 100;
        uint256 upgrade = (amount * 30) / 100;
        uint256 bounty = amount - reinvestment - upgrade;

        payable(reinvestmentPool).transfer(reinvestment);
        payable(agentUpgradeFund).transfer(upgrade);
        payable(bountyNovaRedistribution).transfer(bounty);

        emit EarningsSplit(reinvestment, upgrade, bounty);
    }

    // Owner can update pool addresses
    function setPools(
        address _reinvestmentPool,
        address _agentUpgradeFund,
        address _bountyNovaRedistribution
    ) external {
        require(msg.sender == owner, "Not owner");
        reinvestmentPool = _reinvestmentPool;
        agentUpgradeFund = _agentUpgradeFund;
        bountyNovaRedistribution = _bountyNovaRedistribution;
    }
}