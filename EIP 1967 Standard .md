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

