import 'package:flutter/foundation.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import 'config.dart';

class ContractLinking extends ChangeNotifier {
  late Web3Client _client;
  late String _abiCode;
  late EthereumAddress _contractAddress;
  late Credentials _credentials;
  late EthereumAddress _userAddress;
  late DeployedContract _contract;

  late ContractFunction _recordEnergyProduction;
  late ContractFunction _getEnergyRecords;
  late ContractFunction _getTotalProduction;
  late ContractFunction _getTotalConsumption;
  late ContractFunction _getNetEnergy;
  late ContractFunction _buyEnergy;
  late ContractFunction _getEnergyDataForGraph;
  late ContractFunction _getMissingEnergy;
  late ContractFunction _createEnergyOffer;
  late ContractFunction _getEnergyOffers;
  late ContractFunction _editEnergyOffer;
  late ContractFunction _deleteEnergyOffer;

  bool isLoading = true;

  ContractLinking() {
    initialSetup();
  }

  Future<void> initialSetup() async {
    _client = Web3Client(rpcUrl, http.Client(), socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });
    await getAbi();
    await getCredentials();
    await getDeployedContract();
  }

  Web3Client get web3Client => _client;

  // Load ABI from the asset bundle
  Future<void> getAbi() async {
    final abiStringFile =
        await rootBundle.loadString("assets/EnergySolar.json");
    final jsonAbi = jsonDecode(abiStringFile);
    _abiCode = jsonEncode(jsonAbi["abi"]);
    _contractAddress =
        EthereumAddress.fromHex(jsonAbi["networks"]["5777"]["address"]);
  }

  // Retrieve the user's credentials (private key) and Ethereum address
  Future<void> getCredentials() async {
    _credentials = await _client.credentialsFromPrivateKey(privateKey);
    _userAddress = await _credentials.extractAddress();
    print("User address: $_userAddress");
  }

  EthereumAddress get userAddress => _userAddress;

  // Fetch the deployed contract instance
  Future<void> getDeployedContract() async {
    _contract = DeployedContract(
      ContractAbi.fromJson(_abiCode, "EnergySolar"),
      _contractAddress,
    );

    _recordEnergyProduction = _contract.function("recordEnergyProduction");
    _getEnergyRecords = _contract.function("getEnergyRecords");
    _getTotalProduction = _contract.function("getTotalProduction");
    _getTotalConsumption = _contract.function("getTotalConsumption");
    _getNetEnergy = _contract.function("getNetEnergy");
    _buyEnergy = _contract.function("buyEnergy");
    _getEnergyDataForGraph = _contract.function("getEnergyDataForGraph");
    _getMissingEnergy = _contract.function("getMissingEnergy");
    _createEnergyOffer = _contract.function("createEnergyOffer");
    _getEnergyOffers = _contract.function("getEnergyOffers");
    _editEnergyOffer = _contract.function("editEnergyOffer");
    _deleteEnergyOffer = _contract.function("deleteEnergyOffer");

    await getData();
  }

  Future<void> createEnergyOffer(BigInt energy, BigInt price) async {
    isLoading = true;
    notifyListeners();

    try {
      await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
          contract: _contract,
          function: _createEnergyOffer,
          parameters: [energy, price],
        ),
        chainId: 1337,
      );
    } catch (e) {
      print("Erreur lors de la création de l'offre : $e");
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> getEnergyOffers(
      EthereumAddress userAddress) async {
    try {
      final result = await _client.call(
        contract: _contract,
        function: _getEnergyOffers,
        params: [userAddress],
      );

      return (result.first as List<dynamic>).map((offer) {
        final offerList = offer as List<dynamic>;
        return {
          'id': BigInt.parse(offerList[0].toString()), // Offer ID
          'energyAmount':
              BigInt.parse(offerList[1].toString()), // Energy Amount
          'pricePerUnit':
              BigInt.parse(offerList[2].toString()), // Price Per Unit
          'timestamp': BigInt.parse(offerList[3].toString()), // Timestamp
          'owner':
              EthereumAddress.fromHex(offerList[4].toString()), // Owner Address
          // IsActive status
        };
      }).toList();
    } catch (e) {
      print("Erreur lors de la récupération des offres : $e");
      return [];
    }
  }

  Future<Map<String, List<BigInt>>> getEnergyDataForGraph() async {
    try {
      List<BigInt> productionData = [];
      List<BigInt> consumptionData = [];
      List<BigInt> timestampsData = [];

      List result = await _client.call(
        contract: _contract,
        function: _getEnergyDataForGraph,
        params: [_userAddress],
      );

      productionData = List<BigInt>.from(result[0] as List);
      consumptionData = List<BigInt>.from(result[1] as List);
      timestampsData = List<BigInt>.from(result[2] as List);

      return {
        'production': productionData,
        'consumption': consumptionData,
        'timestamps': timestampsData,
      };
    } catch (e) {
      print("Error fetching energy data for graph: $e");
      return {
        'production': [],
        'consumption': [],
        'timestamps': [],
      };
    }
  }

  Future<BigInt> getMissingEnergy(EthereumAddress userAddress) async {
    final response = await _client.call(
      contract: _contract,
      function: _getMissingEnergy,
      params: [_userAddress],
    );
    return response[0] as BigInt;
  }

  Future<void> getData() async {
    try {
      List energyRecords = await _client.call(
        contract: _contract,
        function: _getEnergyRecords,
        params: [_userAddress],
      );
      print("Energy Records: $energyRecords");

      isLoading = false;
      notifyListeners();
    } catch (e) {
      print("Error getting data: $e");
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> recordEnergyProduction(BigInt produced, BigInt consumed) async {
    isLoading = true;
    notifyListeners();

    try {
      await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
          contract: _contract,
          function: _recordEnergyProduction,
          parameters: [produced, consumed],
        ),
        chainId: 1337, // Replace with the appropriate chain ID
      );
      await getData();
    } catch (e) {
      print("Error recording production: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<BigInt> getTotalProduction(EthereumAddress address) async {
    try {
      List result = await _client.call(
        contract: _contract,
        function: _getTotalProduction,
        params: [address],
      );
      return result[0] as BigInt;
    } catch (e) {
      print("Error getting total production: $e");
      return BigInt.zero;
    }
  }

  Future<BigInt> getTotalConsumption(EthereumAddress address) async {
    try {
      List result = await _client.call(
        contract: _contract,
        function: _getTotalConsumption,
        params: [address],
      );
      return result[0] as BigInt;
    } catch (e) {
      print("Error getting total consumption: $e");
      return BigInt.zero;
    }
  }

  Future<BigInt> getNetEnergy(EthereumAddress address) async {
    try {
      List result = await _client.call(
        contract: _contract,
        function: _getNetEnergy,
        params: [address],
      );
      return result[0] as BigInt;
    } catch (e) {
      print("Error getting net energy: $e");
      return BigInt.zero;
    }
  }

  Future<void> buyEnergy(
      EthereumAddress seller, BigInt offerId, BigInt energyAmount) async {
    isLoading = true;
    notifyListeners();

    try {
      // Fetch the energy offer from the smart contract
      final energyOffer = await _client.call(
        contract: _contract,
        function:
            _getEnergyOffers, // Ensure this returns energy offer details for the seller
        params: [seller],
      );

      if (energyOffer.isNotEmpty && energyOffer[0] != null) {
        // Assuming pricePerUnit is returned in Ether, convert it to Wei for the transaction
        final pricePerUnitInEther =
            double.parse(energyOffer[0][0][2].toString());
        final pricePerUnitInWei =
            EtherAmount.fromUnitAndValue(EtherUnit.ether, pricePerUnitInEther)
                .getInWei;

        // Calculate total price in Wei
        final totalPriceInWei = energyAmount * pricePerUnitInWei;

        // Convert total price back to Ether for display
        final totalPriceInEther =
            EtherAmount.inWei(totalPriceInWei).getValueInUnit(EtherUnit.ether);

        print("Price (in Wei) for $energyAmount kWh: $totalPriceInWei");
        print("Price (in Ether) for $energyAmount kWh: $totalPriceInEther");

        // Ensure parameters are valid before proceeding
        if (seller != null &&
            offerId != null &&
            energyAmount != null &&
            totalPriceInWei > BigInt.zero) {
          final transaction = Transaction.callContract(
              contract: _contract,
              function: _buyEnergy, // The smart contract function to buy energy
              parameters: [seller, offerId, energyAmount],
              value: EtherAmount.inWei(
                  totalPriceInWei) // Set the Ether value for the transaction in Wei
              );

          // Print the transaction parameters (optional for debugging)
          print("Transaction parameters:");
          print(
              "Seller: $seller, OfferId: $offerId, EnergyAmount: $energyAmount, Price (in Wei): $totalPriceInWei");

          // Send the transaction
          await _client.sendTransaction(
            _credentials,
            transaction,
            chainId:
                1337, // Adjust the chain ID for the correct Ethereum network (Ganache uses 1337 by default)
          );
          print("Transaction sent successfully.");

          // Fetch updated data after the transaction
          await getData();
          print("Data retrieved successfully.");
        } else {
          print("Error: Invalid parameters for the energy purchase.");
        }
      } else {
        print("Error: Energy offer not found or invalid.");
      }
    } catch (e) {
      print("Error occurred: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> editEnergyOffer(
      BigInt offerId, BigInt newEnergyAmount, BigInt newPricePerUnit) async {
    isLoading = true;
    notifyListeners();
    final transaction = Transaction.callContract(
      contract: _contract,
      function: _editEnergyOffer,
      parameters: [offerId, newEnergyAmount, newPricePerUnit],
    );

    try {
      await _client.sendTransaction(_credentials, transaction, chainId: 1337);
      await getData();
    } catch (e) {
      print('Error while editing energy offer: $e');
      rethrow;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteEnergyOffer(BigInt offerId) async {
    isLoading = true;
    notifyListeners();
    final transaction = Transaction.callContract(
      contract: _contract,
      function: _deleteEnergyOffer,
      parameters: [offerId],
    );

    try {
      await _client.sendTransaction(_credentials, transaction, chainId: 1337);
      await getData();
    } catch (e) {
      print('Error while deleting energy offer: $e');
      rethrow;
    }

    isLoading = false;
    notifyListeners();
  }
  // Ajoutez cette méthode à la classe ContractLinking
}
