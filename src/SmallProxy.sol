// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

//Importing this Proxy.sol from OpenZeppelin. OpenZeppelin has the minimalisitic proxy contract that we can
// to actually start working with this delegate call.
import {Proxy} from "../lib/openzeppelin-contracts/contracts/proxy/Proxy.sol";

// EIP - 1967 : Standard Proxy Storage Slots 
    // This is an EIP for having certain storage slots specifically used for proxies.

// So the way the proxies gonna a work is that if any contract call this proxy contract and if its not this setImplementation function 
// its going to pass it over whatever is inside the implementation slot address.

contract SmallProxy is Proxy {
    //This is _IMPLEMENTATION_SLOT is going to be location of the implementation address.
    bytes32 private constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    // This setImplementation function will change where these delegate calls are going to be sending. This could be equivalent
    // to like upgrading your smart contract and then we have implementation here to read where the implementation contract is.
    
    function setImplementation(address newImplementation) public {
        assembly {
            sstore(_IMPLEMENTATION_SLOT, newImplementation)
        }
    }

    function _implementation() internal view override returns (address implementationAddress) {
        assembly {
            implementationAddress := sload(_IMPLEMENTATION_SLOT)
        }
    }

    ///////////////////////
    // Helper Functions////
    ///////////////////////

    function getDataToTransact(uint256 numberToUpdate) public pure returns (bytes memory) {
        return abi.encodeWithSignature("setValue(uint256)", numberToUpdate);
    }

    function readStorage() public view returns (uint256 valueAtStorageSlotZero) {
        assembly {
            valueAtStorageSlotZero := sload(0)
        }
    }
}

contract ImplementationA {
    uint256 public value;

    function setValue(uint256 newValue) public {
        value = newValue;
    }
}

contract ImplementationB {
    uint256 public value;

    function setValue(uint256 newValue) public {
        value = newValue + 2;
    }
}

