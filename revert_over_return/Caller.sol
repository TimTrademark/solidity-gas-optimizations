// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

interface GasOptimizedContract {
    function getX() external pure returns (uint);
    function getY() external pure returns (uint);
    function getZ() external pure;
}

contract Caller {

    address private  _contract;

    constructor(address c) {
        _contract = c;
    }
    
    //Uses 109.220 gas
    function callX() external view {
        for(uint i; i < 100; ++i) {
            GasOptimizedContract(_contract).getX();
        }
    }

    //Uses 103.498 gas
    function callY() external view {
        for(uint i; i < 100; ++i) {
            GasOptimizedContract(_contract).getY();
        }
    }

    //Uses 87.436 gas
    function callZ() external view   {
        for(uint i; i < 100; ++i) {
            (,bytes memory reason) = _contract.staticcall(hex"2f135d0c");
        }
    }

}