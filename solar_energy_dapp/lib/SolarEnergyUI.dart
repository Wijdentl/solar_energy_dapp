import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:solar_energy_dapp/ListOffers.dart';
import 'package:solar_energy_dapp/config.dart';
import 'package:solar_energy_dapp/side_menu.dart';

import 'ethereum_service.dart'; // Utilisez web3dart pour EthereumAddress

class SolarEnergyUI extends StatefulWidget {
  @override
  _SolarEnergyUIState createState() => _SolarEnergyUIState();
}

class _SolarEnergyUIState extends State<SolarEnergyUI> {
  final TextEditingController _producedController = TextEditingController();
  final TextEditingController _consumedController = TextEditingController();
  final TextEditingController _energyAmountController = TextEditingController();
  final TextEditingController _pricePerUnitController = TextEditingController();

  // Show energy dialog
  void _showEnergyDialog(
      BuildContext context, String title, Function(BigInt) onSubmit) {
    final TextEditingController _energyController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: _energyController,
            decoration: InputDecoration(
              labelText: 'Enter amount (kWh)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                try {
                  final BigInt energy =
                      BigInt.from(int.parse(_energyController.text));
                  if (energy <= BigInt.zero) {
                    _showSnackBar("Invalid energy value. Must be positive.");
                  } else {
                    onSubmit(energy);
                    Navigator.of(context).pop();
                    _showSnackBar("$title submitted successfully!");
                  }
                } catch (e) {
                  _showSnackBar("Please enter a valid numeric value.");
                }
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  // Show snack bar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Submit energy offer
  void _submitEnergyOffer(ContractLinking contractLinking) async {
    final BigInt energy =
        BigInt.tryParse(_energyAmountController.text) ?? BigInt.zero;
    final BigInt price =
        BigInt.tryParse(_pricePerUnitController.text) ?? BigInt.zero;

    if (energy <= BigInt.zero || price <= BigInt.zero) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Veuillez entrer des valeurs valides pour l'énergie et le prix.")),
      );
      return;
    }

    try {
      await contractLinking.createEnergyOffer(energy, price);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Offre d'énergie soumise avec succès.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la soumission : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final contractLinking = Provider.of<ContractLinking>(context);// Ensure to pass the user's Ethereum address here
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Solar Energy Visualisation'),
      ),
      drawer: NavBar(), // Add the navigation drawer
      body: contractLinking.isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Card for Energy Data Display
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildEnergyDataDisplay(contractLinking),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Button to Add Energy Produced
                    ElevatedButton(
                      onPressed: () => _showEnergyDialog(
                        context,
                        'Add Energy Produced',
                        (BigInt value) {
                          // Uncomment when integrating with contract linking
                          contractLinking.recordEnergyProduction(
                              value, BigInt.zero);
                        },
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.orange.shade500.withOpacity(0.6),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        minimumSize: Size(0, 50),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        "Add Energy Produced",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Button to Add Energy Consumed
                    ElevatedButton(
                      onPressed: () => _showEnergyDialog(
                        context,
                        'Add Energy Consumed',
                        (BigInt value) {
                          contractLinking.recordEnergyProduction(
                              BigInt.zero, value);
                        },
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.orange.shade500.withOpacity(0.6),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        minimumSize: Size(0, 50),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        "Add Energy Consumed",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Button to Create Energy Offer
                    ElevatedButton(
                      onPressed: () {
                        // Show offer dialog for energy and price
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Create Energy Offer'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: _energyAmountController,
                                    decoration: InputDecoration(
                                      labelText: 'Enter energy amount (kWh)',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                  SizedBox(height: 10),
                                  TextField(
                                    controller: _pricePerUnitController,
                                    decoration: InputDecoration(
                                      labelText: 'Enter price per unit (ETH)',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _submitEnergyOffer(contractLinking);
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Submit Offer'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.orange.shade500.withOpacity(0.6),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        minimumSize: Size(0, 50),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        "Create Energy Offer",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  // Widget for displaying energy data
  Widget _buildEnergyDataDisplay(ContractLinking contractLinking) {
    return Column(
      children: [
        _buildFutureText("Total Energy Produced",
            contractLinking.getTotalProduction(userAddress)),
        _buildFutureText("Total Energy Consumed",
            contractLinking.getTotalConsumption(userAddress)),
        _buildNetOrMissingEnergyDisplay(contractLinking),
      ],
    );
  }

  Widget _buildFutureText(String label, Future<BigInt> future) {
    return FutureBuilder<BigInt>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('$label: Loading...', style: TextStyle(fontSize: 18));
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}',
              style: TextStyle(fontSize: 18, color: Colors.red));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Text('$label: 0 kWh', style: TextStyle(fontSize: 18));
        } else {
          return Text('$label: ${snapshot.data} kWh',
              style: TextStyle(fontSize: 18));
        }
      },
    );
  }

  Widget _buildNetOrMissingEnergyDisplay(ContractLinking contractLinking) {
    return FutureBuilder<BigInt>(
      future: contractLinking.getNetEnergy(userAddress),
      builder: (context, netSnapshot) {
        if (netSnapshot.connectionState == ConnectionState.waiting) {
          return Text('Net Energy: Loading...', style: TextStyle(fontSize: 18));
        } else if (netSnapshot.hasError) {
          return Text('Error: ${netSnapshot.error}',
              style: TextStyle(fontSize: 18, color: Colors.red));
        } else if (!netSnapshot.hasData || netSnapshot.data == null) {
          return Text('Net Energy: 0 kWh', style: TextStyle(fontSize: 18));
        } else {
          BigInt netEnergy = netSnapshot.data!;
          if (netEnergy > BigInt.zero) {
            return Text('Net Energy: $netEnergy kWh',
                style: TextStyle(fontSize: 18));
          } else if (netEnergy == BigInt.zero) {
            return FutureBuilder<BigInt>(
              future: contractLinking.getMissingEnergy(userAddress),
              builder: (context, missingSnapshot) {
                if (missingSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Text('Missing Energy: Loading...',
                      style: TextStyle(fontSize: 18));
                } else if (missingSnapshot.hasError) {
                  return Text('Error: ${missingSnapshot.error}',
                      style: TextStyle(fontSize: 18, color: Colors.red));
                } else if (!missingSnapshot.hasData ||
                    missingSnapshot.data == null ||
                    missingSnapshot.data == BigInt.zero) {
                  return Text('No Missing Energy',
                      style: TextStyle(fontSize: 18));
                } else {
                  BigInt missingEnergy = missingSnapshot.data!;
                  return GestureDetector(
                    onTap: () => _showEnergyPurchaseDialog(context),
                    child: Text(
                      'Missing Energy: ${missingEnergy} kWh',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.red,
                          fontWeight: FontWeight.bold),
                    ),
                  );
                }
              },
            );
          } else {
            return Text('Unexpected energy state.',
                style: TextStyle(fontSize: 18, color: Colors.red));
          }
        }
      },
    );
  }

  void _showEnergyPurchaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Missing Energy'),
          content: Text('Do you want to buy more energy?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                // Implémenter la logique pour gérer l'achat d'énergie
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => EnergyOfferScreen()),
                );
                _showSnackBar('Achat d\'énergie initié !');
              },
              child: Text('Oui'),
            ),
          ],
        );
      },
    );
  }
}
