'use strict';

const SmartContractForAudit = artifacts.require('SmartContractForAudit.sol');


module.exports = function(deployer, network) {
    deployer.deploy(SmartContractForAudit);
};
