// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract FunctionReturn {

    
    function callGetterSolidity() public pure returns(uint value) {
        value = getValueSolidity();
    }

    function callGetterAssembly() public pure returns(uint value) {
        getValueAssembly();
        assembly {
            value := mload(mload(0x40))
        }
    }

    function getValueSolidity() public pure returns(uint value) {
        value = 100;
        return value;
    }

    function getValueAssembly() public pure {
        uint value = 100;
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, value)
        }
    }

}