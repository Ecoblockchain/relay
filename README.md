# relay

A pattern for calling ethereum contract methods by sending funds to a proxy contract.

## Why?

Downloading a full ethereum node and interacting with a contract via a web3-based dapp is currently a barrier to non-technical ethereum users. The upcoming Mist Browser and the Metamask project are good solutions for this, but they are currently in alpha and not widely available. Even when they are available, they are an extra piece of software for the user to download. This pattern allows users to call methods on a contract with only their ethereum wallet. 

- Users can send 0 ether and still trigger the method. 
- You can create relay addresses for as many methods as you would like.
- You can create a (traditional, non-dapp) web front-end that spins up arbitrary relays for more advanced interactions and then present the user with an address to send a transaction to activate.

## Methods

The Relay contract acts as a base contract via inheritance and exposes the following methods:

- `AddRelay(string methodName)` - Registers the given method as callable via a relay. Creates a proxy contract in the background. This is an internal method that is called only from the host contract.
- `GetRelay(string methodHash)` - Gets the address that can be sent transactions to call the relay method. This is a public method that the consumer is expected to call to retrieve the dynamic relay address. *(See [Known Issues](https://github.com/Shapeshift-Public/relay#known-issues) as to why this takes a methodHash instead of a methodName.)*

## Usage

```js
contract MyContract is Relay {
  uint public counter = 0;

  function MyContract() {
    AddRelay('Count()');
  }

  function Count() {
    counter++;
  }
}
```

A client can call `GetRelay.call(methodName)` to get the proxy address. Sending a transaction to the proxy address will call the method that was registered with `AddRelay` on the host contract.

```js
const proxyAddress = myContract.GetRelay.call('Count()')
web3.eth.sendTransaction({ from: web3.eth.accounts[0], to: proxyAddress })
```

See [/contracts/Relay.sol](https://github.com/Shapeshift-Public/relay/blob/master/contracts/MyContract.sol) and [/test/TestMyContract.sol](https://github.com/Shapeshift-Public/relay/blob/master/test/TestMyContract.js) for details.

## Contributing

If you think this pattern would be useful with additional functionality, please consider contributing! Please post your idea to the [issues page](https://github.com/Shapeshift-Public/relay/issues) to get feedback before creating a pull request.

#### Known issues that you could help with:

- Does not support method parameters
- Access control

## License

MIT
