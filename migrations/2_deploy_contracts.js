const RLPDecoder = artifacts.require("RLPDecoder");
 
module.exports = function(deployer) {
  deployer.deploy(RLPDecoder);
};
