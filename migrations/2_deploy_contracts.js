module.exports = function(deployer) {
  deployer.deploy(Relay)
  deployer.autolink()
  deployer.deploy(MyContract)
}
