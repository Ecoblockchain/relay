/* The Relay contract serves as a base contract for any contract that wishes to expose methods through relay addresses.*/
library Relay {

  struct Data {
    // a mapping of methodId => proxy address
    mapping (bytes4 => mapping(address => address)) relays;
  }

  /** Adds a relay for the given method. */
  function addRelay(Data storage self, string methodName, address owner) {
    bytes4 methodId = bytes4(sha3(methodName));
    self.relays[methodId][owner] = address(new Proxy(methodId, this, owner));
  }

  /** Retrieves the dynamic contract address that can be sent a transaction to trigger the given method. */
  function getRelay(Data storage self, string methodName, address owner) constant returns (address) {
    return self.relays[bytes4(sha3(methodName))][owner];
  }

  /** Transfers a relay to a different owner. */
  function transferRelay(Data storage self, string methodName, address oldOwner, address newOwner) {
    bytes4 methodId = bytes4(sha3(methodName));
    Proxy proxy = Proxy(self.relays[methodId][oldOwner]);
    proxy.transferOwner(newOwner);
  }
}

/** The Proxy contract represents a single method on a host contract. It stores the address of the host contract and the method id of the method so that it can invoke the method when a user sends funds to this contract's address. Note: This version is permission-less. Most use cases would require an authorized owner contract. */
contract Proxy {

  /* The address of the relay owner (who has permission to trigger it). */
  address owner;

  /* The address of the host contract. */
  address host;

  /* The methodId of the host contract method. This is equivalent to bytes4(sha3(methodName)) where the method name includes the parentheses as if you were calling the function. */
  bytes4 methodId;

  function Proxy(bytes4 _methodId, address _host, address _owner) {
    host = _host;
    owner = _owner;
    methodId = _methodId;
  }

  function transferOwner(address newOwner) {
    owner = newOwner;
  }

  function() {

    // make sure the sender is authorized
    if(msg.sender != owner) throw;

    // if host call throws, throw this transaction as well
    if(!host.call(methodId)) throw;

    // forward ETH to host
    if(msg.value > 0) {
      host.send(msg.value);
    }
  }
}
