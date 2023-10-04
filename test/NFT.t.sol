// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;
import {Test, console2} from "forge-std/Test.sol";
import {ERC721Marketplace} from "../src/NFT.sol";
import { ECDSA } from "../lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import { DOLNFT } from "../src/MockERC20.sol";


contract ERC721MarketplaceTest is Test {
    using ECDSA for bytes32;

    ERC721Marketplace public erc721marketplace;
    DOLNFT internal _token;
    address _seller;
        uint256 _price = 2;
        uint _deadline = 56743;
        uint _tokenId = 1;
        address _tokenAddress;
        bytes _signature;

    uint256 internal _userPrivateKey;
    uint256 internal _signerPrivateKey;
     
    function setUp() public {
        erc721marketplace = new ERC721Marketplace();
        address user = vm.addr(_userPrivateKey);
        
      
        
        _tokenAddress = 0x168Ca561E63C868b0F6cC10a711d0b4455864f17; 
        _seller = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        vm.startPrank(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        bytes32 digest = keccak256(abi.encodePacked(_seller, _tokenAddress, _tokenId, _price,  _deadline));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80, digest);
        _signature = abi.encodePacked(r, s, v);
        vm.stopPrank();
        _token.mint(user, 1e18);
        
        erc721marketplace.createOrder(_tokenAddress, _price, _signature, _deadline);
       
    }
    function testExecuteOrder() public {
        address user = vm.addr(_userPrivateKey);
        address signer = vm.addr(_signerPrivateKey);

        _tokenId = 1;
        
        vm.startPrank(signer);
        bytes32 digest = keccak256(abi.encodePacked(user, _tokenId)).toEthSignedMessageHash();
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(_signerPrivateKey, digest);
        _signature = abi.encodePacked(r, s, v);
        vm.stopPrank();
        vm.startPrank(user);
        erc721marketplace.executeOrder( _tokenId);
        vm.stopPrank();
        // ERC721Marketplace.Order memory order = ERC721Marketplace.Order({
        //     seller: _seller,
        // tokenAddress: _tokenAddress,
        // tokenId: 1,
        // price: 2,
        // signature: _signature,
        // deadline: 56743,
        // executed: false
        // });

        // bytes32 digest = erc721marketplace.getTypedDataHash(order);  
        // (uint8 v, bytes32 r, bytes32 s) = vm.sign(_userPrivateKey, digest); 

        // _token.order(
        //     _token.seller,
        //     _token.tokenId,
        //     _token.price,
        //     _token.signature,
        //     _token.deadline,
        //     _token.executed,
        //     v,
        //     r,
        //     s
        // );     

        // assertEq(token.allowance(owner, spender), 1e18);
        // assertEq(token.nonces(owner), 1);
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
   
