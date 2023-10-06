// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import { ECDSA } from "../lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import {SignUtils} from "./libraries/SignUtils.sol";
contract ERC721Marketplace  {
    using ECDSA for bytes32;

    struct Order {
        address seller;
        address token;
        uint256 tokenId;
        uint256 price;
        bytes signature;
        uint256 deadline;
        bool isActive;
    }
    uint public listingId;
    mapping(uint256 => Order) public orders;

    error NotOwner();
    error DeadlinePassed();
    error InvalidPrice();
    error InvalidSignature();
    error OrderExpired();
    error IncorrectPrice();
    error NotApproved();


    function createOrder(Order calldata order) external returns (uint256 orderId){
        
        if(ERC721(order.token).ownerOf(order.tokenId) != msg.sender) revert NotOwner();
        if(ERC721(order.token).isApprovedForAll(msg.sender, address(this))) revert NotApproved();        
        if(block.timestamp < order.deadline) revert DeadlinePassed();
        if (order.price <= 0 ether) revert InvalidPrice();
        if (
            !SignUtils.isValid(
                SignUtils.constructMessageHash(
                    order.seller,
                    order.token,
                    order.tokenId,
                    order.price,
                    order.deadline
                    
                ),
                order.signature,
                msg.sender
            )
        ) revert InvalidSignature();

        Order storage _order = orders[listingId];
         _order.seller = order.seller;
         _order.token = order.seller;
         _order.tokenId = order.tokenId;
         _order.price = order.price;
         _order.signature = order.signature;
         _order.deadline = order.deadline;
         _order.isActive = order.isActive;

         orderId = listingId;
         listingId++;
         return orderId;
    }
   

    function executeOrder(uint256 orderId) external payable {
        Order storage order = orders[orderId];
        if(msg.value == order.price) revert IncorrectPrice();
        if(block.timestamp > order.deadline) revert OrderExpired();
    
        ERC721(order.token).transferFrom(order.seller, msg.sender, order.tokenId);
        payable(order.seller).transfer(order.price);

        order.isActive = false;
    }

   
}




