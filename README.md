# Learning About Proxies

### Smart Contract Storage Architecture:

* Variables in smart contract stores their value in two primary locations: `Storage` and `bytecode`. `Storage` holds mutable information whereas `bytecode` holds immutable information, this includes the values of immutable and constant variable types, also the compiled source code.


## Storage:

* `Storage` holds mutable information. Variables storing there values in `Storage` are also called as `State` variables. When we interact with a storage variable, under the hood we are reading/writing from `Storage`, specifically at the storage slot where the variable keeps it value.

### Storage Slots

* Smart contract `storage` is organized into `storage slots`. Each slot can hold 256 bits (32 bytes). Storage slots are indexed from `0` to `2²⁵⁶- 1`. These numbers act as a unique identifier for locating individual slots.

NOTE: The solidity compiler allocates storage space to storage variables in  a sequential and deterministic manner, based on their declaration order within the contract.

Example:

```solidity
    uint256 count;
    uint256 ticket;
```

The above example is having two storage variables declared. Since, `count` is declared first and `ticket` is declared second. `count` is allocated to the first storage slot, `slot 0` and ticket is allocated to second storage slot `slot 1`. 

Whenever, we query `count` and `ticket` storage variables, these variables are read from these storage slots. NOTE:  A variable cannot change its storage slot once the contract is deployed to the blockchain.


### Storage Packing:

1. Primitive data types suchas `uint8`,`uint32`, `uint64`, `address`, `bool` are smaller in  size and uses less storage space.
2. Since, they use less storage space they can be packed together in the same storage slot

**Important Exmaples:**

For example: A storage variable of type address will require 20 bytes of storage space to store its value,

```solidity
    address wallet =  <some address taking space upto 20bytes>;
```

In the above example, wallet will use upto 20 bytes of space from the storage slot, leaving 12 bytes of space in slot 0.

NOTE: <b>Solidity packs variables in storage slots starting from the least significant byte (right most byte) and progresses to the left.</b>

If we read the bytes32 representation of the storage slot 0 we get:

```solidity 0x000000000000<20 bytes address>```

As shown above the value of wallet is stored starting from the right most byte or the least significant byte. The remaining 12 bytes in slot 0 will be unused storage space that another variable can occupy.

Lets say, next we declared a second and third storage variable, of type bool (1 byte) and uint32 (4 bytes) , their values will be stored within the same storage slot as owner, slot 0, at the unused storage space.

```solidity
    bool Boolean = true;
    uint32 thirdvar = 5_000_000;
```
 
Boolean, the second declared storage variable, will store its value at the first byte to the left of wallet's byte sequence, or, at the least significant byte of the unused storage space. uint32 thirdVar, the third storage variable, will store its value to the left of Boolean’s byte sequence. 

Next, if we were to introduce a 4th storage variable, address burner its value will be stored in the next storage slot, slot 1. This is because burner's value in its entirety cannot fit into slot 0’s unused storage space. There are 7 bytes of storage space left but 20 bytes of consecutive storage space is needed. Therefore, instead of splitting burner's data between slot 0 and slot 1 (7 bytes in slot 0 and 13 bytes in slot 1), burner's value will be stored in a new storage slot, slot 1.

NOTE: If a variable's value cannot fit entirely into the remaining space of the current storage slot, it will be stored in the next available slot.


### Low-Level CallS

**The Four Opcodes:** EVM offers four opcodes for making calls between contracts:
1. CALL (F1)
2. CALLCODE (F2)
3. STATICCALL (FA)
4. DELEGATECALL (F4).



# Delegate Call

* A contract that makes a delegate Call to a target smart contract executes the logic of the target contract inside its own environment. One mental model is that it copies the code of the target smart contract and runs that code itself. The targeted smart contract is commonly referred to as the <b>“implementation contract”</b>.
* delegatCall also has the input data to be executed by the targetContract as a parameter

Example:

```solidity
contract Called {
  uint public number;

  function increment() public {
    number++;
  }
}
```

```solidity
contract Caller {
    uint public number;

    function callIncrement(address _calledAddress) public {
		_calledAddress.delegatecall(
			abi.encodeWithSignature("increment()")
		);
    }
}
```

This delegateCall will execute the increment function, which we result in modifying the storage of Caller contract, instead of Called. You can think it like Caller contract boorwed the increment code and executed it in its context.


# Storage Slot Collision:

The contract using the delegateCall, must be extermely cautious to predict which of its storage slots will get modified. The previous example worked perfectly because Caller didn’t use the state variable in slot 0.

```solidity

contract Called {
  uint public number;

  function increment() public {
    number++;
  }
}

contract Caller {
        // there is a new storage variable here
    address public calledAddress = 0xd9145CCE52D386f254917e481eB44e9943F39138;

    uint public myNumber; // Number vars names are different but it doen't matter what matter is the storage slots

    function callIncrement() public {        
		calledAddress.delegatecall(
			abi.encodeWithSignature("increment()")
		);
    }

}

```

Note that in the updated contract above, the content of slot 0 is the address of the Called contract, while the myNumber variable is now stored in slot 1.

If you deploy the provided contracts and execute the callIncrement function, slot 0 of the Caller storage will be incremented, but the calledAddress variable is there, not the myNumber variable.

## Decouple implementation from data

NOTE: One of the most important uses of delegatecall is to decouple the contract where the data is stored, such as Caller in this case, from the contract where the execution logic resides, such as Called. 

Therefore, if one wishes to alter the execution logic, one can simply replace Called with another contract and update the reference to the implementation contract(TARGET CONTRACT), without touching the storage. 

Caller is no longer constrained by the functions it has, it can delegatecall the functions it needs from other contracts.


Unfortunately, it's not possible to change the name of the function that will be called, as doing so would alter its signature.

In case there is a need to change the execution logic, for example, subtracting the value of myNumber by 1 unit instead of adding it, you can create a new implementation contract, as shown below.

```solidity
contract NewCalled {

    uint public number;

    function increment() public {
        number = number - 1;
    }
}

```

After creating the new implementation contract, NewCalled, one can simply deploy this new contract and change the calledAddress state variable in Caller. Of course, Caller would need to have a mechanism to change the address it is issuing the delegateCall to, which we did not include to keep the code concise.

We have successfully modified the business logic utilized by the Caller contract. Separating data from execution logic allows us to create upgradable smart contracts in Solidity.























