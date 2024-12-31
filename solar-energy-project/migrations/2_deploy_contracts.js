const EnergySolar = artifacts.require("EnergySolar");

module.exports = function(deployer) {
  // Déploiement du contrat Energy
  deployer.deploy(EnergySolar)
    .then(() => {
      console.log("Energy contract deployed successfully.");
    })
    .catch((err) => {
      console.error("Error deploying Energy contract:", err);
    });
};
