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

















