// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "../lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import { ECDSA } from "../lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";


contract ERC721Marketplace is Ownable {
    using ECDSA for bytes32;

    struct Order {
        address seller;
        address tokenAddress;
        uint256 tokenId;
        uint256 price;
        bytes signature;
        uint256 deadline;
        bool isActive;
    }
    uint public _tokenId;
    mapping(uint256 => Order) public orders;

    // modifier onlyValidOrder(uint256 orderId) {
    //     require(orders[orderId].creator != address(0), "Invalid order");
    //     require(!orders[orderId].isActive, "Order already isActive");
    //     _;
    // }
    function _onlyValidOrder(uint256 orderId) internal view {
         require(orders[orderId].seller != address(0), "Invalid order");
        require(!orders[orderId].isActive, "Order already isActive");
    }

    constructor() {}

    function createOrder( address _tokenAddress, uint256 _price, bytes memory _signature,
        uint256 _deadline
    ) external {
        _tokenId++;
        IERC721 token = IERC721(_tokenAddress);
        require(token.ownerOf(_tokenId) == msg.sender, "You do not own this token");
        require(block.timestamp < _deadline, "Deadline has passed");

        orders[_tokenId] = Order({
            seller: msg.sender,
            tokenAddress: _tokenAddress,
            tokenId: _tokenId,
            price: _price,
            signature: _signature,
            deadline: _deadline,
            isActive: true
        });
    }
   

    function executeOrder(uint256 orderId) external payable {
        _onlyValidOrder(orderId);
        Order storage order = orders[orderId];
        require(msg.value == order.price, "Incorrect payment amount");
        require(block.timestamp < order.deadline, "Order expired");
    
        IERC721 token = IERC721(order.tokenAddress);
        token.safeTransferFrom(order.seller, msg.sender, order.tokenId);
        payable(order.seller).transfer(order.price);

        order.isActive = true;
    }

    function _isValidSignature(address _systemAddress, bytes32 hash, bytes memory signature) internal pure returns (bool) {
        require(_systemAddress != address(0), "Missing System Address");

        bytes32 signedHash = hash.toEthSignedMessageHash();
        return signedHash.recover(signature) == _systemAddress;
    }

    function withdrawFunds() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
/*
create an erc721 marketplace that uses onchain orders coupled with vrs signatures to create and confirm orders

- the marketplace should allow users to create erc721 orders for their erc721 tokens
- the order should have the following info 
    - order creator/token owner(obviously)
    - erc721 token address, tokenID
    - price(we'll be using only ether as currency)
    - active
    - signature(the seller must sign the previous data i.e the hash of the token address,tokenId,price,owner etc
    - deadline, if the token isn't sold before the deadline, it cannot be bought again

- when the order is being created by the buyer, the signature is being verified to be the owner's  address among other checks
- order fulfillment has its own checks too

- you are to write a test for this contract

you do not need to emit events for the contract since you're time constrained(you can decide to add events if you want your test traces to be more colorful)
*/
/*


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

*/



