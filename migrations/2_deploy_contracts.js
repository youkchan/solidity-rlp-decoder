const RLPDecoder = artifacts.require("RLPDecoder");
const helper = artifacts.require("Helper");
 
module.exports = function(deployer) {
  deployer.deploy(RLPDecoder);
  deployer.link(RLPDecoder, helper);
  deployer.deploy(helper);
};
