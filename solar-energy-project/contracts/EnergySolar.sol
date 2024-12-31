//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EnergySolar {
    constructor(){
        UserCount = 0;     
    }
    
    // Structure pour stocker la production et la consommation d'énergie
    struct EnergyRecord {
        uint256 produced;  // Energie produite en kWh
        uint256 consumed;  // Energie consommée en kWh
        uint256 timestamp; // Horodatage de l'enregistrement
    }

    struct EnergyOffer {
        uint256 id;             // Identifiant unique de l'offre
        uint256 energyAmount;   // Quantité d'énergie de l'offre en kWh
        uint256 pricePerUnit;   // Prix par unité d'énergie en Wei (ou autre devise)
        uint256 timestamp;      // Horodatage de la création de l'offre
        address owner;
        bool isActive;          // Propriétaire de l'offre
    }
    struct User {
        uint256 id;
        string name;
        string password;
        string phone;
    }
    //authentification
    mapping (address => uint) public userBalances;
    uint256 public UserCount;
    event UserAdded(uint256 _id);
    event UserDeleted(uint256 _id);
    event UserEdited(uint256 _id);
    mapping(uint256 => User) public users;

    // Mappages pour stocker les offres d'énergie, les enregistrements d'énergie, etc.
    mapping(address => EnergyOffer[]) public energyOffers;
    mapping(address => EnergyRecord[]) public energyRecords;
    mapping(address => uint256) public balances;
    mapping(address => uint256) public missingEnergyRecords;

    uint256 private offerCounter = 0;  // Compteur pour générer des IDs uniques d'offres

    event EnergyUpdated(address indexed user, uint256 produced, uint256 consumed, uint256 netEnergy, uint256 timestamp);
    event MissingEnergy(address indexed user, uint256 missingEnergy, uint256 timestamp);
    event EnergyBought(address indexed buyer, address indexed seller, uint256 energyAmount, uint256 price, uint256 timestamp);
    event EnergyOfferCreated(address indexed seller, uint256 offerId, uint256 energyAmount, uint256 pricePerUnit, uint256 timestamp);
    event OfferUpdated(uint256 offerId, uint256 newEnergyAmount, uint256 newPricePerUnit);
    event OfferDeleted(uint256 offerId);  // Déclaration de l'événement OfferDeleted corrigée

    // Créer une offre d'énergie
    function createEnergyOffer(uint256 energyAmount, uint256 pricePerUnit) public {
        require(energyAmount > 0, "Energy amount must be greater than zero.");
        require(pricePerUnit > 0, "Price per unit must be greater than zero.");

        int256 netEnergy = getNetEnergy(msg.sender);
        require(netEnergy >= int256(energyAmount), "Offer energy exceeds net energy available.");

        uint256 offerId = offerCounter;  // Utiliser la valeur actuelle de offerCounter comme offerId
        offerCounter++;  // Incrémenter offerCounter après l'avoir utilisé pour générer offerId

        energyOffers[msg.sender].push(EnergyOffer({
            id: offerId,
            energyAmount: energyAmount,
            pricePerUnit: pricePerUnit,
            timestamp: block.timestamp,
            owner: msg.sender,
            isActive: true
        }));

        emit EnergyOfferCreated(msg.sender, offerId, energyAmount, pricePerUnit, block.timestamp);
    }

    // Obtenir toutes les offres d'énergie pour un utilisateur
    function getEnergyOffers(address user) public view returns (EnergyOffer[] memory) {
        return energyOffers[user];
    }

    // Enregistrer la production et la consommation d'énergie
    function recordEnergyProduction(uint256 produced, uint256 consumed) public {
        energyRecords[msg.sender].push(EnergyRecord({
            produced: produced,
            consumed: consumed,
            timestamp: block.timestamp
        }));

        uint256 totalProduced = getTotalProduction(msg.sender);
        uint256 totalConsumed = getTotalConsumption(msg.sender);

        int256 netEnergy = int256(totalProduced) - int256(totalConsumed);

        if (netEnergy < 0) {
            uint256 missingEnergy = uint256(-netEnergy);
            missingEnergyRecords[msg.sender] = missingEnergy;
            delete energyRecords[msg.sender];
            emit MissingEnergy(msg.sender, missingEnergy, block.timestamp);
            emit EnergyUpdated(msg.sender, 0, 0, 0, block.timestamp);
        } else if (netEnergy == 0) {
            delete energyRecords[msg.sender];
            emit EnergyUpdated(msg.sender, 0, 0, 0, block.timestamp);
        } else {
            emit EnergyUpdated(msg.sender, totalProduced, totalConsumed, uint256(netEnergy), block.timestamp);
        }
    }

    function getMissingEnergy(address user) public view returns (uint256) {
        return missingEnergyRecords[user];
    }

    // Function to buy energy from a seller
function buyEnergy(address seller, uint256 offerId, uint256 energyAmount) public payable {
    // Get the energy offer from the seller's offer list using the offerId
    EnergyOffer storage offer = energyOffers[seller][offerId];
    
    // Ensure the offer is still active
    require(offer.isActive, "Offer is no longer active");
    
    // Check if the seller has enough energy available in the offer
    require(offer.energyAmount >= energyAmount, "Not enough energy available for this offer");

    // Calculate the total price for the energy being purchased
    uint256 price = energyAmount * offer.pricePerUnit;
    
    // Ensure the buyer has sent enough Ether to cover the cost of the energy
    require(msg.value >= price, "Insufficient funds to buy the energy.");

    // Ensure the seller has energy records
    require(energyRecords[seller].length > 0, "Seller has no energy records.");

    // Reduce the available energy in the seller's offer
    offer.energyAmount -= energyAmount;

    // If the energy offer is depleted, deactivate the offer
    if (offer.energyAmount == 0) {
        offer.isActive = false;
        emit OfferDepleted(seller, offerId, block.timestamp); // Emit event when the offer is exhausted
    }

    // Record the energy consumption for both the seller and buyer
    energyRecords[seller].push(EnergyRecord({
        produced: 0,
        consumed: energyAmount,
        timestamp: block.timestamp
    }));

    energyRecords[msg.sender].push(EnergyRecord({
        produced: energyAmount,
        consumed: 0,
        timestamp: block.timestamp
    }));
     
    // Transfer the Ether to the seller
    
    (bool success, ) = payable(seller).call{value: msg.value}("");
    require(success, "Failed to transfer Ether to seller.");

    // Emit an event to log the energy purchase
    emit EnergyBought(msg.sender, seller, energyAmount, price, block.timestamp);
}

// Event to notify when an energy offer is depleted
event OfferDepleted(address indexed seller, uint256 offerId, uint256 timestamp);

    // Obtenir tous les enregistrements d'énergie pour un utilisateur
    function getEnergyRecords(address user) public view returns (EnergyRecord[] memory) {
        return energyRecords[user];
    }

    function getTotalProduction(address user) public view returns (uint256 totalProduced) {
        EnergyRecord[] memory records = energyRecords[user];
        for (uint256 i = 0; i < records.length; i++) {
            totalProduced += records[i].produced;
        }
    }

    function getTotalConsumption(address user) public view returns (uint256 totalConsumed) {
        EnergyRecord[] memory records = energyRecords[user];
        for (uint256 i = 0; i < records.length; i++) {
            totalConsumed += records[i].consumed;
        }
    }
   

    function getNetEnergy(address user) public view returns (int256) {
        uint256 totalProduced = getTotalProduction(user);
        uint256 totalConsumed = getTotalConsumption(user);
        return int256(totalProduced) - int256(totalConsumed);
    }

    function getEnergyDataForGraph(address user) 
        public 
        view 
        returns (uint256[] memory productions, uint256[] memory consumptions, uint256[] memory timestamps) 
    {
        uint256 recordCount = energyRecords[user].length;
        productions = new uint256[](recordCount);
        consumptions = new uint256[](recordCount);
        timestamps = new uint256[](recordCount);

        uint256 cumulativeProduction = 0;
        uint256 cumulativeConsumption = 0;

        for (uint256 i = 0; i < recordCount; i++) {
            EnergyRecord memory record = energyRecords[user][i];

            cumulativeProduction += record.produced;
            cumulativeConsumption += record.consumed;

            productions[i] = cumulativeProduction;
            consumptions[i] = cumulativeConsumption;
            timestamps[i] = record.timestamp;
        }

        return (productions, consumptions, timestamps);
    }

    // Modifier une offre d'énergie
    function editEnergyOffer(
        uint256 offerId,
        uint256 newEnergyAmount,
        uint256 newPricePerUnit
    ) public {
        bool offerExists = false;

        // Parcourir les offres d'énergie de l'utilisateur
        for (uint256 i = 0; i < energyOffers[msg.sender].length; i++) {
            // Vérifier si l'ID de l'offre correspond
            if (energyOffers[msg.sender][i].id == offerId) {
                offerExists = true;

                // Mettre à jour l'offre avec les nouveaux paramètres
                energyOffers[msg.sender][i].energyAmount = newEnergyAmount;
                energyOffers[msg.sender][i].pricePerUnit = newPricePerUnit;

                // Émettre un événement pour notifier que l'offre a été mise à jour
                emit OfferUpdated(offerId, newEnergyAmount, newPricePerUnit);
                break;
            }
        }

        // Si l'offre n'existe pas, lever une exception
        require(offerExists, "Offer does not exist");
    }

    // Supprimer une offre d'énergie
    function deleteEnergyOffer(uint256 offerId) public {
        bool offerExists = false;
        uint256 offerIndex = 0;

        // Parcourir les offres d'énergie de l'utilisateur pour trouver l'offre à supprimer
        for (uint256 i = 0; i < energyOffers[msg.sender].length; i++) {
            if (energyOffers[msg.sender][i].id == offerId) {
                offerExists = true;
                offerIndex = i;
                break;
            }
        }

        // Si l'offre n'existe pas, lever une exception
        require(offerExists, "Offer does not exist");

        // Supprimer l'offre en déplaçant le dernier élément à l'index de l'offre à supprimer
        energyOffers[msg.sender][offerIndex] = energyOffers[msg.sender][energyOffers[msg.sender].length - 1];
        energyOffers[msg.sender].pop(); // Retirer le dernier élément

        // Émettre un événement pour signaler que l'offre a été supprimée
        emit OfferDeleted(offerId);
    }
    function getUserCount() public view returns (uint256) {
        return UserCount;
    }

    function addUser(
        string memory _name,
        string memory _password,
        string memory _phone
    ) public {
        users[UserCount] = User(
            UserCount,
            _name,
            _password,
            _phone
        );
        userBalances[msg.sender] = ++UserCount;

        emit UserAdded(UserCount);
    }

    function deleteUser(uint256 _id) public {
        delete users[_id];
        UserCount--;
        emit UserDeleted(_id);
    }

    function editUser(
        uint256 _id,
        string memory _name,
        string memory _password,
        string memory _phone
    ) public {
        users[_id] = User(_id, _name, _password, _phone);
        emit UserEdited(_id);
    }

    function signin(string memory _name, string memory _password) public view returns (bool) {
        for (uint256 i = 0; i < UserCount; i++) {
            if (keccak256(bytes(users[i].name)) == keccak256(bytes(_name)) &&
                keccak256(bytes(users[i].password)) == keccak256(bytes(_password))) {
                return true;
            }
        }
        return false;
    }
}
