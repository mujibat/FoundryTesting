// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;
import {Test, console2} from "forge-std/Test.sol";
import {ERC721Marketplace} from "../src/NFT.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import { ECDSA } from "../lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import { DOLNFT } from "../src/MockERC20.sol";
import "./Helpers.sol";

contract ERC721MarketplaceTest is Helpers {
    using ECDSA for bytes32;

    ERC721Marketplace erc721marketplace;
    DOLNFT _token;

        ERC721Marketplace.Order order;

    
    address userA;
    address userB;

    uint256 privKeyA;
    uint256 privKeyB;
    
     
    function setUp() public {
        erc721marketplace = new ERC721Marketplace();
        _token = new DOLNFT();
      
        (userA, privKeyA) = mkaddr("USERA");
        (userB, privKeyB) = mkaddr("USERB");
        
        order = ERC721Marketplace.Order({
        seller: address(0),
        token: address(_token),
        tokenId: 1,
        price: 5 ether,
        signature: bytes(""),
        deadline: 0,
        isActive: false
        });

        _token.mint(userA, 1);
        

    }

   function testNotOwner() public {
        order.seller = userB;
        switchSigner(userB);
        vm.expectRevert(ERC721Marketplace.NotOwner.selector);
        erc721marketplace.createOrder(order);
   }
   function testDeadline() public {
        switchSigner(userA);
        _token.setApprovalForAll(address(erc721marketplace), true);
        vm.expectRevert(ERC721Marketplace.DeadlinePassed.selector);
        erc721marketplace.createOrder(order);
   }
   function testPrice() public {
    switchSigner(userA);
    _token.setApprovalForAll(address(erc721marketplace), true);
    order.price = 0;
    vm.expectRevert(ERC721Marketplace.InvalidPrice.selector);
        erc721marketplace.createOrder(order);

   } 
   function testValidSignature() public {
    switchSigner(userA);
    _token.setApprovalForAll(address(erc721marketplace), true);
    order.deadline = block.timestamp + 80 minutes;
    order.signature = constructSig(
        order.seller,
        order.token,
        order.tokenId,
        order.price,
        order.deadline,
        privKeyB
    );
     vm.expectRevert(ERC721Marketplace.InvalidSignature.selector);
        erc721marketplace.createOrder(order);
   }

   function testOrderExpired() public {
    switchSigner(userA);
    _token.setApprovalForAll(address(erc721marketplace), true);
   }

   function testExecute() public {
    switchSigner(userA);
    _token.setApprovalForAll(address(erc721marketplace), true);
    order.deadline = block.timestamp + 80 minutes;
    order.signature = constructSig(
        order.seller,
        order.token,
        order.tokenId,
        order.price,
        order.deadline,
        privKeyA
    );
    uint256 orderId = erc721marketplace.createOrder(order);
    switchSigner(userB);
    uint256 userABalanceBefore = userA.balance;

        erc721marketplace.executeOrder{value: order.price}(orderId);

        uint256 userABalanceAfter = userA.balance;
        assertEq(ERC721(order.token).ownerOf(order.tokenId), userB);
        assertEq(userABalanceAfter, userABalanceBefore + order.price);
   } 
    
    }
   
