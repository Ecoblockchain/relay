/* global MyContract, web3, contract, describe, it, assert */

describe('MyContract', () => {
  contract('MyContract', accounts => {
    it('should invoke the host function by calling the relay contract', () => {
      const myContract = MyContract.deployed()
      return myContract.GetRelay.call('Count()').then(result => {
        const relayAddress = result.valueOf()
        return myContract.counter.call()
          .then(counter => assert.equal(counter.toNumber(), 0, 'Counter did not start at 0'))
          .then(() => web3.eth.sendTransaction({ from: accounts[0], to: relayAddress }))
          .then(myContract.counter.call)
          .then(counter => assert.equal(counter.toNumber(), 1, 'Counter did not increment to 1)'))
      })
    })
  })

  contract('MyContract', accounts => {
    it('should forward sent ether to the host contract', () => {
      const myContract = MyContract.deployed()
      return myContract.GetRelay.call('Count()').then(result => {
        const relayAddress = result.valueOf()
        const balance = web3.eth.getBalance(accounts[0]).toNumber()
        web3.eth.sendTransaction({ from: accounts[0], to: relayAddress, value: 100 })
        assert.equal(web3.eth.getBalance(accounts[0]).toNumber(), balance)
        assert.equal(web3.eth.getBalance(myContract.address).toNumber(), 100)
        assert.equal(web3.eth.getBalance(relayAddress).toNumber(), 0)
      })
    })
  })
})
