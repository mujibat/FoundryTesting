// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;
import {Test, console2} from "forge-std/Test.sol";
import {ERC721Marketplace} from "../src/NFT.sol";
import { ECDSA } from "../lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import { DOLNFT } from "../src/MockERC20.sol";
import "./Helpers.sol";

contract ERC721MarketplaceTest is Helpers {
    using ECDSA for bytes32;

    ERC721Marketplace public erc721marketplace;
    DOLNFT internal _token;
    address _seller;
        uint256 _price = 2;
        uint _deadline = 56743;
        uint _tokenId = 1;
        address _tokenAddress;
        bytes _signature;

        ERC721Marketplace.Order orderm;

    uint256 _userPrivateKey;
    address _user;

    uint256 _signerPrivateKey;
    address _signer;
     
    function setUp() public {
        erc721marketplace = new ERC721Marketplace();
        _token = new DOLNFT();
      
        (_user, _userPrivateKey) = mkaddr("user");
        (_signer, _signerPrivateKey) = mkaddr("signer");
        
        orderm = ERC721Marketplace.Order({
        seller: address(0),
        tokenAddress: address(_token),
        tokenId: 1,
        price: 5 ether,
        signature: bytes(""),
        deadline: 0,
        isActive: false
        });

        _token.mint(_user, 1e18);
        
        // erc721marketplace.createOrder(_tokenAddress, _price, _signature, _deadline);
       
        // _tokenAddress = 0x168Ca561E63C868b0F6cC10a711d0b4455864f17; 
        // _seller = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        // vm.startPrank(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        // bytes32 digest = keccak256(abi.encodePacked(_seller, _tokenAddress, _tokenId, _price,  _deadline));
        // (uint8 v, bytes32 r, bytes32 s) = vm.sign(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80, digest);
        // _signature = abi.encodePacked(r, s, v);
        // vm.stopPrank();
    }

    
    function testExecuteOrder() public {
        switchSigner(_user);
        _token.setApprovalForAll(address (erc721marketplace), true);
        _tokenId = 1;
        orderm.deadline = 8600;

        orderm.signature = constructSig(
        orderm.seller,
        orderm.tokenAddress,
        orderm.tokenId,
        orderm.price,
        orderm.deadline,
        orderm.privKey
        );

        uint256 orderId = erc721marketplace.createOrder(_tokenAddress, _price, _signature, _deadline);
        switchSigner(_signer);
        uint256 userBalanceBefore = _user.balance;
        erc721marketplace.executeOrder{orderm.price}(orderId);
        uint256 userBalanceAfter = user.balance;

        ERC721Marketplace.Order memory orderm = erc721marketplace.getListing(lId);
        assertEq(orderm.price, 1 ether);
        assertEq(orderm.active, false);

        assertEq(ERC721(orderm.tokenAddress).ownerOf(orderm.tokenId), _signer);
        assertEq(userABalanceAfter, userABalanceBefore + l.price);
    }
          
    // function testCreateOrder() public {
    //     erc721marketplace.createOrder(
    //         _tokenAddress, // Mock token address
    //         _price,
    //         _signature,
    //         _deadline
    //     );

    //        _order.orders(1);

    //     assertEq(_order.seller, _seller);
    //     assertEq(_order.tokenAddress, address(this));
    //    assertEq(_order.tokenId, _tokenId);
    //    assertEq(_order.price, _price);
    //   assertEq(_order.signature, _signature);
    //  assertEq(_order.deadline, _deadline);
    //   assertEq(_order.executed, false);
    // }
    
    }
   
