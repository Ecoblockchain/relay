import './Relay.sol';

/* The Relay library has three methods: AddRelay, GetRelay, and TransferRelay. See Relay.sol for more details. This contract creates a relay that will allow users to trigger the Count method if they send a transaction to the proxy address (retrieved viw GetRelay('Count()'')). */
contract MyContract {
  uint public counter = 0;
  address public relayOwner;

  using Relay for Relay.Data;
  Relay.Data relay;

  function AddCountRelay(address owner) {
    relayOwner = owner;
    relay.AddRelay('Count()', owner);
  }

  function GetRelay(string methodName, address owner) constant returns (address) {
    return relay.GetRelay(methodName, owner);
  }

  function TransferCountRelay(address newOwner) {
    relay.TransferRelay('Count()', relayOwner, newOwner);
  }

  function Count() {
    counter++;
  }
}
