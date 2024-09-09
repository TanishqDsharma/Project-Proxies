# EIP 1967 Storage Slots for Proxies
 
EIP1967 is a standard that tells where to store important information needed by proxy contracts. This is used by both UUPS and Transparent Upgradeable Proxy Pattern use it.  

**NOTE:**
* EIP 1967 defines a specific location in the contract storage where important information such as implementation address and admin address should be stored. EIP1967 also ensures that whenever there is a change in storage variables events related to that should be emitted.
* EIP 1967 does not defines how those storage variables are updated or who can manage them.

**There are two critical variables that proxy needs to operate:**
1. <b>Implementation Address:</b> The implementation address is where proxy is delegating calls to.
2. <b>Admin:</b> This is the entity that has the authority to make changes to the proxy, especially when upgrading the contract.

**What problem EIP1967 solves?**
The problem EIP1967 solves is related to storage collisions between the proxy contract and the implementation contract. There is a very high chance that storage variables defined in implementation contract clashes with the ones in proxy contract. For example: Storage slots 0 and 1 are typically used by most contracts for basic variables (e.g., counters, balances, addresses), making it highly likely that the implementation contract also uses these slots.If both the proxy and the implementation use the same storage slots, there can be serious issues like overwriting of data. 

**Preventing Collisions:**

An important point to note that is since the `admin` and `implmentation address` needs to change we cannot define these as immutables. These must be defined in storage slots that must not collide with variables in storage variables in implementation contract.

**Q. So, how can we achive this?**

Since, the space for storage variables are exteremly large: 2**256-1. The key idea here is that because the storage space is so vast, if you choose storage slots for the admin and implementation address in a way that is unpredictable/random (like using a hash to generate the slot), it becomes practically impossible for the implementation contract to use the same slots.

### To derive the storage slots:

To derive storage slots for variables like the admin and implementation address in a proxy contract (as per ERC 1967), the process involves using the Keccak-256 hash function and subtracting 1 from the resulting hash value

