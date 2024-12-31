import 'package:flutter/cupertino.dart';
import 'package:flutter_web3/flutter_web3.dart';  // Importez flutter_web3

class MetaMaskProvider extends ChangeNotifier {
  static const connectingField = 0;
  String currentAddress = '';
  var account = '';
  int? currentChain;

  // Vérifie si Ethereum (MetaMask) est activé
  bool get isEnabled => ethereum != null;
  
  // Vérifie si l'utilisateur est sur le bon réseau
  bool get isInOperatingChain => currentChain == connectingField;
  
  // Vérifie si l'utilisateur est connecté
  bool get isConnected => isEnabled && currentAddress.isNotEmpty;

  // Connexion à MetaMask
  Future connect() async {
    if (isEnabled) {
      // Demander les comptes de l'utilisateur
      final accs = await ethereum!.requestAccount();
      account = accs[0]; // Récupérer le premier compte
      if (accs.isNotEmpty) currentAddress = accs.first;
      
      // Récupérer l'ID du réseau actuel
      currentChain = await ethereum!.getChainId();
      
      // Notifier l'état
      notifyListeners();
    }
  }
}
