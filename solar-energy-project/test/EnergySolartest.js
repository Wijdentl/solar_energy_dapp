const EnergySolar = artifacts.require("EnergySolar");

contract("EnergySolar", accounts => {
  let energySolar;

  before(async () => {
    energySolar = await EnergySolar.deployed();
  });

  it("devrait enregistrer et récupérer des données de production et consommation d'énergie", async () => {
    const produced = 10;
    const consumed = 5;

    // Enregistrer les données de production et de consommation
    await energySolar.recordEnergyProduction(produced, consumed, { from: accounts[0] });

    // Récupérer les données enregistrées
    const records = await energySolar.getEnergyRecords(accounts[0]);

    assert.equal(records.length, 1, "L'enregistrement de l'énergie échoue");
    assert.equal(records[0].produced.toString(), produced.toString(), "La production d'énergie ne correspond pas");
    assert.equal(records[0].consumed.toString(), consumed.toString(), "La consommation d'énergie ne correspond pas");
  });

  it("devrait calculer correctement la production totale", async () => {
    const totalProduced = await energySolar.getTotalProduction(accounts[0]);
    assert.equal(totalProduced.toString(), "10", "La production totale est incorrecte");
  });

  it("devrait calculer correctement la consommation totale", async () => {
    const totalConsumed = await energySolar.getTotalConsumption(accounts[0]);
    assert.equal(totalConsumed.toString(), "5", "La consommation totale est incorrecte");
  });
});
