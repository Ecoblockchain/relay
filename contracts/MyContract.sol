import './Relay.sol';

/* An example contrat that inherits from Relay gains two methods: AddRelay (internal) and GetRelay (public). See Relay.sol for more details. This contract creates a relay that will allow users to trigger the Count method if they send a transaction to the proxy address (retrieved viw GetRelay('Count()'')). */
contract MyContract is Relay {
  uint public counter = 0;

  function MyContract() {
    AddRelay('Count()');
  }

  function Count() {
    counter++;
  }
}
