import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solar_energy_dapp/config.dart';
import 'package:solar_energy_dapp/ethereum_service.dart';
import 'package:web3dart/web3dart.dart';
import 'package:solar_energy_dapp/side_menu.dart';

class EnergyOfferScreen extends StatefulWidget {
  @override
  _EnergyOfferScreenState createState() => _EnergyOfferScreenState();
}

class _EnergyOfferScreenState extends State<EnergyOfferScreen> {
  final TextEditingController _energyAmountController = TextEditingController();
  final TextEditingController _pricePerUnitController = TextEditingController();

  @override
  void dispose() {
    _energyAmountController.dispose();
    _pricePerUnitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contractLinking = Provider.of<ContractLinking>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offres d\'énergie'),
      ),
      drawer: const NavBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: Card(
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Mes Offres',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    Expanded(
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: contractLinking.getEnergyOffers(userAddress),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Erreur : ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                                child: Text('Aucune offre disponible.'));
                          }

                          final myOffers = snapshot.data!;
                          return ListView.builder(
                            itemCount: myOffers.length,
                            itemBuilder: (context, index) {
                              final offer = myOffers[index];
                              final offerId = offer['id'] ?? BigInt.zero;
                              final energyAmount =
                                  offer['energyAmount'] ?? BigInt.zero;
                              final pricePerUnit =
                                  offer['pricePerUnit'] ?? BigInt.zero;

                              return ListTile(
                                title: Text(
                                    'ID: $offerId - Énergie: $energyAmount kWh'),
                                subtitle: Text('Prix: $pricePerUnit Wei'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () => _editEnergyOfferDialog(
                                          contractLinking, offerId),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () => _deleteEnergyOffer(
                                          contractLinking, offerId),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Offres des Autres Utilisateurs',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    Expanded(
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: _getEnergyOffersFromOtherUsers(
                            contractLinking, userAddress),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Erreur : ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                                child: Text('Aucune offre disponible.'));
                          }

                          final otherOffers = snapshot.data!;
                          return ListView.builder(
                            itemCount: otherOffers.length,
                            itemBuilder: (context, index) {
                              final offer = otherOffers[index];
                              final offerId = offer['id'] ?? BigInt.zero;
                              final owner = offer['owner'] ??
                                  (throw Exception(
                                      'Propriétaire manquant pour l\'offre $offerId.'));
                              final energyAmount =
                                  offer['energyAmount'] ?? BigInt.zero;
                              final pricePerUnit =
                                  offer['pricePerUnit'] ?? BigInt.zero;

                              return ListTile(
                                title: Text(
                                    'ID: $offerId - Énergie: $energyAmount kWh'),
                                subtitle: Text('Prix: $pricePerUnit Wei'),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    _showEnergyAmountDialog(
                                        context,
                                        contractLinking,
                                        owner,
                                        offerId,
                                        energyAmount);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: const Text('Acheter'),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editEnergyOfferDialog(
      ContractLinking contractLinking, BigInt offerId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier Offre'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _energyAmountController,
                decoration: const InputDecoration(
                    labelText: 'Nouvelle quantité d\'énergie'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _pricePerUnitController,
                decoration:
                    const InputDecoration(labelText: 'Nouveau prix par unité'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                final energyAmount = BigInt.parse(_energyAmountController.text);
                final pricePerUnit = BigInt.parse(_pricePerUnitController.text);
                await contractLinking.editEnergyOffer(
                    offerId, energyAmount, pricePerUnit);
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text('Modifier'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteEnergyOffer(
      ContractLinking contractLinking, BigInt offerId) async {
    await contractLinking.deleteEnergyOffer(offerId);
    setState(() {});
  }

  // Fonction pour récupérer les offres d'énergie des autres utilisateurs
  Future<List<Map<String, dynamic>>> _getEnergyOffersFromOtherUsers(
      ContractLinking contractLinking,
      EthereumAddress currentUserAddress) async {
    List<Map<String, dynamic>> allOffers = [];

    for (EthereumAddress userAddress in userAddresses) {
      // Comparaison de l'adresse de l'utilisateur pour exclure l'utilisateur actuel
      if (userAddress != currentUserAddress) {
        try {
          // Récupérer les offres pour chaque utilisateur, sauf l'utilisateur actuel
          List<Map<String, dynamic>> offers =
              await contractLinking.getEnergyOffers(userAddress);
          allOffers.addAll(offers);
        } catch (e) {
          print(
              'Erreur lors de la récupération des offres pour ${userAddress.hex} : $e');
        }
      }
    }

    return allOffers;
  }

  Future<void> _showEnergyAmountDialog(
      BuildContext context,
      ContractLinking contractLinking,
      EthereumAddress owner,
      BigInt offerId,
      BigInt maxEnergy) async {
    final TextEditingController _amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Acheter Énergie'),
          content: TextField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Quantité à acheter',
              hintText: 'Entrez une quantité (en kWh)',
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final input = _amountController.text;
                  if (input.isEmpty) {
                    throw Exception("Veuillez entrer une quantité valide.");
                  }

                  final amount = BigInt.parse(input);

                  if (amount <= BigInt.zero || amount > maxEnergy) {
                    throw Exception(
                        "Quantité invalide ! Assurez-vous que la quantité est comprise entre 1 et $maxEnergy kWh.");
                  }

                  // Perform the purchase
                  await contractLinking.buyEnergy(owner, offerId, amount);
                  Navigator.pop(context);

                  // Refresh UI
                  setState(() {});
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: const Text('Acheter'),
            ),
          ],
        );
      },
    );
  }
}
