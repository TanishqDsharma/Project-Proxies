//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import {UUPSUpgradeable} from "../lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "../lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "../lib/openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";


contract BoxV1 is Initializable, UUPSUpgradeable,OwnableUpgradeable {

    constructor() {
        _disableInitializers();
    }
    
    function initialize() public initializer{
        __Ownable_init(msg.sender); //sets owner to msg.sender
        __UUPSUpgradeable_init();
    }

    uint256 internal number;

    function getNumber() external view returns(uint256){
        return number;
    }

    function version() external pure returns(uint256){
        return 1;
    }

    function _authorizeUpgrade(address newImplementation) internal override{
      
    }

}