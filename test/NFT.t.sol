// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;
import {ERC721Marketplace} from "../src/NFT.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {ECDSA} from "../lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import {DOLNFT} from "../src/MockERC20.sol";
import "./Helpers.sol";

contract ERC721MarketplaceTest is Helpers {
    using ECDSA for bytes32;

    ERC721Marketplace _erc721marketplace;
    DOLNFT _token;

    ERC721Marketplace.Order _order;

    address _userA;
    address _userB;

    uint256 _privKeyA;
    uint256 _privKeyB;

    function setUp() public {
        _erc721marketplace = new ERC721Marketplace();
        _token = new DOLNFT();

        (_userA, _privKeyA) = mkaddr("USERA");
        (_userB, _privKeyB) = mkaddr("USERB");

        _order = ERC721Marketplace.Order({
            seller: _userA,
            token: address(_token),
            tokenId: 1,
            price: 5 ether,
            signature: bytes(""),
            deadline: 0,
            isActive: true
        });

        _token.mint(_userA, 1);
    }

    function testNotOwner() public {
        _order.seller = _userB;
        vm.expectRevert(ERC721Marketplace.NotOwner.selector);
        _erc721marketplace.createOrder(_order);
    }

    function testNotApproved() public {
        // switchSigner(_userA);
        vm.startPrank(_userA);
        vm.expectRevert(ERC721Marketplace.NotApproved.selector);
        _erc721marketplace.createOrder(_order);
    }

    function testDeadline() public {
        vm.startPrank(_userA);
        _token.setApprovalForAll(address(_erc721marketplace), true);
        vm.expectRevert(ERC721Marketplace.DeadlinePassed.selector);
        _erc721marketplace.createOrder(_order);
    }

    function testPrice() public {
        vm.startPrank(_userA);
        _token.setApprovalForAll(address(_erc721marketplace), true);
        _order.deadline = 200;
        _order.price = 0.001 ether;
        vm.expectRevert(ERC721Marketplace.InvalidPrice.selector);
        _erc721marketplace.createOrder(_order);
    }

    function testCreateOrder() public {
        vm.startPrank(_userA);
        _token.setApprovalForAll(address(_erc721marketplace), true);
        _order.deadline = 200;

        uint currentCount = _erc721marketplace.listingId();
        uint id = _erc721marketplace.createOrder(_order);

        assertEq(currentCount, id);
    }

     function testOrderIsActive() public {
        uint orderId = _preExecute();
        _erc721marketplace.executeOrder{value: 5 ether}(orderId);
        vm.expectRevert();
         _erc721marketplace.executeOrder{value: 5 ether}(orderId);

        
    }

    function testIncorrectPrice() public {
        uint orderId = _preExecute();
        vm.expectRevert(ERC721Marketplace.IncorrectPrice.selector);
        _erc721marketplace.executeOrder{value: 4 ether}(orderId);
    }

    function testOrderExpired() public {
        uint orderId = _preExecute();
        vm.warp(250);
        vm.expectRevert(ERC721Marketplace.OrderExpired.selector);
        _erc721marketplace.executeOrder{value: 5 ether}(orderId);
    }

    function testExecute() public {
        uint orderId = _preExecute();
        _erc721marketplace.executeOrder{value: 5 ether}(orderId);

        // vm.expectRevert(ERC721Marketplace.InvalidSignature.selector);
    }

    function _preExecute() internal returns (uint _orderId) {
        vm.startPrank(_userA);
        vm.deal(_userA, 10 ether);
        _token.setApprovalForAll(address(_erc721marketplace), true);
        _order.deadline = 200;

        _order.signature = constructSig(
            _order.seller,
            _order.token,
            _order.tokenId,
            _order.price,
            _order.deadline,
            _privKeyA
        );

        _orderId = _erc721marketplace.createOrder(_order);
        vm.stopPrank();
    }
}
