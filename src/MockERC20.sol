// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
contract DOLNFT is ERC20{
    
    address _nftaddr;

    string public baseTokenURI;

     constructor() ERC20("DOLNFT", "DLNFT"){
        _nftaddr = msg.sender; 
    
    }
    function mint(address _to, uint value) external payable {}
} 