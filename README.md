# relay

A pattern for calling ethereum contract methods by sending funds to a proxy contract.

## Why?

Downloading a full ethereum node and interacting with a contract via a web3-based dapp is currently a barrier to non-technical ethereum users. The upcoming Mist Browser and the Metamask project are good solutions for this, but they are currently in alpha and not widely available. Even when they are available, they are an extra piece of software for the user to download. This pattern allows users to call methods on a contract with only their ethereum wallet. 

- User can send 0 ether and still trigger the method. 
- Relays are can only be triggered by an authorized user.
- You can create a (traditional, non-dapp) web front-end that spins up arbitrary relays for more advanced interactions and then present the user with an address to send a transaction to activate.

## Methods

The Relay contract acts as a base contract via inheritance and exposes the following methods:

- `AddRelay(string methodName, address relayOwner)` - Registers the given method as callable via a relay for the given relayOwner. Creates a proxy contract in the background. This is an internal method that is called only from the host contract.
- `GetRelay(string methodName, address relayOwner)` - Gets the address that can be sent transactions by the relayOwner to call the relay method. This is a public method that the consumer is expected to call to retrieve the dynamic relay address. 
- `TransferRelay(string methodName, address oldOwner, address newOwner)` - Transfers the owner of the relay. Internal method.

## Usage

```js
contract MyContract is Relay {
  uint public counter = 0;
  address relayOwner = 0x3f89a54f3af68c83af5ac5834e735ebd89423cdc;

  function MyContract() {
    AddRelay('Count()', relayOwner);
  }

  function Count() {
    counter++;
  }
}
```

A client can call `GetRelay.call(methodName, relayOwner)` to get the proxy address. Sending a transaction to the proxy address will call `Count()`.

```js
const proxyAddress = myContract.GetRelay.call('Count()', web3.eth.accounts[0])
web3.eth.sendTransaction({ from: web3.eth.accounts[0], to: proxyAddress })
```

See [/contracts/Relay.sol](https://github.com/Shapeshift-Public/relay/blob/master/contracts/MyContract.sol) and [/test/TestMyContract.sol](https://github.com/Shapeshift-Public/relay/blob/master/test/TestMyContract.js) for details.

## Contributing

If you think this pattern would be useful with additional functionality, please consider contributing! Please post your idea to the [issues page](https://github.com/Shapeshift-Public/relay/issues) to get feedback before creating a pull request.

#### Known issues that you could help with:

- Does not support method parameters

## License

MIT
