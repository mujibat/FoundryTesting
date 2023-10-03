// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC721Marketplace is Ownable, ReentrancyGuard {
    struct Order {
        address seller;
        address tokenAddress;
        uint256 tokenId;
        uint256 price;
        bytes32 signature;
        uint256 deadline;
        bool active;
    }

    mapping(bytes32 => Order) public orders;

    modifier onlyTokenOwner(address tokenAddress, uint256 tokenId) {
        require(
            IERC721(tokenAddress).ownerOf(tokenId) == msg.sender,
            "Only the token owner can create orders"
        );
        _;
    }

    constructor() {}

    function createOrder(
        address tokenAddress,
        uint256 tokenId,
        uint256 price,
        bytes32 signature,
        uint256 deadline
    ) external onlyTokenOwner(tokenAddress, tokenId) {
        bytes32 orderHash = keccak256(
            abi.encodePacked(tokenAddress, tokenId, price)
        );

        require(orders[orderHash].active == false, "Order already exists");
        require(block.timestamp < deadline, "Deadline has passed");

        orders[orderHash] = Order(
            msg.sender,
            tokenAddress,
            tokenId,
            price,
            signature,
            deadline,
            true
        );
    }

    function confirmOrder(
        address tokenAddress,
        uint256 tokenId,
        uint256 price,
        bytes32 signature
    ) external nonReentrant {
        bytes32 orderHash = keccak256(
            abi.encodePacked(tokenAddress, tokenId, price)
        );

        Order storage order = orders[orderHash];
        require(order.active, "Order does not exist");
        require(block.timestamp <= order.deadline, "Deadline has passed");

        bytes32 messageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", orderHash)
        );

        address recoveredSigner = ecrecover(
            messageHash,
            27,
            signature[0],
            signature[1]
        );

        require(
            recoveredSigner == order.seller,
            "Signature verification failed"
        );

        IERC721(order.tokenAddress).transferFrom(
            order.seller,
            msg.sender,
            order.tokenId
        );

        payable(order.seller).transfer(order.price);

        delete orders[orderHash];
    }
}
