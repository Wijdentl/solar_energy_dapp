import 'package:flutter/material.dart';
import 'package:solar_energy_dapp/ListOffers.dart';
import 'package:solar_energy_dapp/SolarEnergyUI.dart';

import 'package:solar_energy_dapp/widgets/EnergyChart.dart'; // Import the SolarEnergyUI page
 // Import the ProfilePage

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text("Walha Emna "), // Add user's name here
            accountEmail: Text("emna@gmail.com"), // Add user's email here
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.account_circle,
                size: 50,
                color: Colors.grey,
              ),
            ),
            decoration: BoxDecoration(
  color: Colors.orange, // Pas de const ici
),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            selected: ModalRoute.of(context)?.settings.name == '/solarEnergyUI', // Highlight if on this page
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SolarEnergyUI()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text("Visualisation"),
            selected: ModalRoute.of(context)?.settings.name == '/visualisation', // Highlight if on this page
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => EnergyChartPage()),
              );
            },
          ),
          
          
          ListTile(
            leading: const Icon(Icons.energy_savings_leaf),
            title: const Text("Offers"),
            selected: ModalRoute.of(context)?.settings.name == '/Offers', // Highlight if on this page
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) =>EnergyOfferScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Disconnect"),
            onTap: () => print("Disconnect tapped"),
          ),
        ],
      ),
    );
  }
}
