// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract AssetRegistry {
    event AssetTransferred(
        address indexed from,
        address indexed to,
        string assetId,
        uint256 timestamp
    );

    function transfer(address to, string memory assetId) external {
        require(to != address(0), "AssetRegistry: zero address");
        require(bytes(assetId).length > 0, "AssetRegistry: empty assetId");

        emit AssetTransferred(msg.sender, to, assetId, block.timestamp);
    }
}
