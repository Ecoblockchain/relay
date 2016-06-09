/* global MyContract, web3, contract, describe, it, assert */

describe('MyContract', () => {
  contract('MyContract', accounts => {
    const user = accounts[1]
    it('should add and get a relay for a given function and user', () => {
      const myContract = MyContract.deployed()
      return myContract.AddCountRelay(user)
        .then(() => myContract.GetRelay.call('Count()', user))
    })
  })

  contract('MyContract', accounts => {
    const user = accounts[1]
    it('should invoke the host function by calling the relay contract', () => {
      const myContract = MyContract.deployed()
      return myContract.AddCountRelay(user)
        .then(() => myContract.GetRelay.call('Count()', user))
        .then(result => {
          const relayAddress = result.valueOf()
          return myContract.counter.call()
            .then(counter => assert.equal(counter.toNumber(), 0, 'Counter did not start at 0'))
            .then(() => web3.eth.sendTransaction({ from: user, to: relayAddress }))
            .then(myContract.counter.call)
            .then(counter => assert.equal(counter.toNumber(), 1, 'Counter did not increment to 1)'))
        })
    })
  })

  contract('MyContract', accounts => {
    const user = accounts[1]
    const other = accounts[2]
    it('should not invoke the function for unauthorized users', () => {
      const myContract = MyContract.deployed()
      return myContract.AddCountRelay(user)
        .then(() => myContract.GetRelay.call('Count()', user))
        .then(result => {
          const relayAddress = result.valueOf()
          return myContract.counter.call()
            .then(counter => assert.equal(counter.toNumber(), 0, 'Counter did not start at 0'))
            .then(() => web3.eth.sendTransaction({ from: other, to: relayAddress }))
            .then(() => { throw new Error('sendTransaction did not fail as expected') })
            .catch(err => {
              // rethrow unexepected errors
              if(!/invalid JUMP/.test(err.message)) {
                throw err;
              }
            })
        })
    })
  })

  contract('MyContract', accounts => {
    const user = accounts[1]
    it('should forward sent ether to the host contract', () => {
      const myContract = MyContract.deployed()
      return myContract.AddCountRelay(user)
        .then(() => myContract.GetRelay.call('Count()', user))
        .then(result => {
          const relayAddress = result.valueOf()
          const balance = web3.eth.getBalance(user).toNumber()
          web3.eth.sendTransaction({ from: user, to: relayAddress, value: 100 })
          assert.equal(web3.eth.getBalance(user).toNumber(), balance)
          assert.equal(web3.eth.getBalance(myContract.address).toNumber(), 100)
          assert.equal(web3.eth.getBalance(relayAddress).toNumber(), 0)
        })
    })
  })
})
