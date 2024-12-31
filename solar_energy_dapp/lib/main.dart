import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
// Import your existing services and UI components
import 'widgets/auth/authentification_service.dart';
import 'widgets/auth/authentificationUI.dart';
import 'MetaMaskService.dart';
import 'ethereum_service.dart';
import 'SolarEnergyUI.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthentificationService(),
        ),
        ChangeNotifierProvider(create: (_) => MetaMaskProvider()),
        ChangeNotifierProvider(
          create: (_) => ContractLinking(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solar Energy',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      routes: {
        '/SolarEnergyUI': (context) => SolarEnergyUI(),
      },
      home: const HomePage(),
    );
  }
}

void _showAuthDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AuthentificationUI();
    },
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('../assets/background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.orange.withOpacity(0.2), // Adjust opacity as needed
              BlendMode.srcATop,
            ),
          ),
        ),
        child: Stack(
          children: [
            // Blurred overlay for futuristic effect
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0.1),
                ),
              ),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    'Solar Energy',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description Paragraph
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Text(
                      'Track your solar energy consumption and production, purchase additional energy when needed, and manage it all with secure blockchain technology.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Sign In/Register Button
                  ElevatedButton(
                    onPressed: () => _showAuthDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      foregroundColor: Colors
                          .white, // Use foregroundColor instead of onPrimary
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
