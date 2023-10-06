// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
contract DOLNFT is ERC721("DOLNFT", "DLNFT"){
    
    address _nftaddr;

    string public baseTokenURI;

    function mint(address _to, uint value) external payable {}
} 