// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

contract GasOptimizedFuntionReturn {
    
    function getX() external pure returns (uint) {
        uint x = 12345;
        return x;
    }

    function getY() external pure returns (uint y) {
        y = 12345;
    }

    function getZ() external pure {
        uint z = 12345;
        assembly {
                let ptr := mload(0x40)
                mstore(ptr, z)
                revert(ptr, 32)
        }
    }

}