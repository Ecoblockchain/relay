pragma solidity ^0.4.4;

import './Relay.sol';

/* The Relay library has three methods: AddRelay, GetRelay, and TransferRelay. See Relay.sol for more details. This contract creates a relay that will allow users to trigger the Count method if they send a transaction to the proxy address (retrieved viw GetRelay('Count()'')). */
contract MyContract {
  uint public counter = 0;
  address public relayOwner;

  using Relay for Relay.Data;
  Relay.Data relay;

  function addCountRelay(address owner) {
    relayOwner = owner;
    relay.addRelay('count()', owner);
  }

  function getRelay(string methodName, address owner) constant returns (address) {
    return relay.getRelay(methodName, owner);
  }

  function transferCountRelay(address newOwner) {
    relay.transferRelay('count()', relayOwner, newOwner);
  }

  // make payable for the purpose of testing that the relay can send ether as well
  function count() payable {
    counter++;
  }
}
