/* The Relay contract serves as a base contract for any contract that wishes to expose methods through relay addresses.*/
contract Relay {

  // a mapping of methodId => proxy address
  mapping (bytes4 => address) relays;

  /** Adds a relay for the given method. */
  function AddRelay(string methodName) internal {
    bytes4 methodId = bytes4(sha3(methodName));
    relays[methodId] = address(new Proxy(methodId));
  }

  /** Retrieves the dynamic contract address that can be sent a transaction to trigger the given method. */
  function GetRelay(string methodName) constant returns (address) {
    return relays[bytes4(sha3(methodName))];
  }
}

/** The Proxy contract represents a single method on a host contract. It stores the address of the host contract and the method id of the method so that it can invoke the method when a user sends funds to this contract's address. Note: This version is permission-less. Most use cases would require an authorized owner contract. */
contract Proxy {

  /* The address of the host contract. */
  address host;

  /* The methodId of the host contract method. This is equivalent to bytes4(sha3(methodName)) where the method name includes the parentheses as if you were calling the function. */
  bytes4 methodId;

  function Proxy(bytes4 _methodId) {
    host = msg.sender;
    methodId = _methodId;
  }

  function() {

    // if host call throws, throw this transaction as well
    if(!host.call(methodId)) {
      throw;
    }

    // forward ETH to host
    if(msg.value > 0) {
      host.send(msg.value);
    }
  }
}
