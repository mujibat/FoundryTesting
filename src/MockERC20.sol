// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
contract DOLNFT is ERC721("DOLNFT", "DLNFT"){
    

    function mint(address recipient, uint256 tokenId) public payable {
        _mint(recipient, tokenId);
    }
} 