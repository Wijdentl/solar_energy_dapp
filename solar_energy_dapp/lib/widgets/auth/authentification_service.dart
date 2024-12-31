import 'package:web3dart/web3dart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:web_socket_channel/io.dart';
import '../../config.dart';
import 'User.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class AuthentificationService extends ChangeNotifier {
  List<User> users = [];
  bool isLoading = false;
  late int count;
  late Web3Client _client;
  late Credentials _credentials;
  late DeployedContract _contract;
  late ContractFunction _count;
  late ContractFunction _users;
  late ContractFunction _addUser;
  late ContractFunction _deleteUser;
  late ContractFunction _editUser;
  late ContractFunction _signIn;
  late EthereumAddress _contractAddress;
  late String _abiCode;

  AuthentificationService() {
    init();
  }

  Future<void> init() async {
    try {
      // Initialize Web3 client
      _client = Web3Client(rpcUrl, Client(), socketConnector: () {
        return IOWebSocketChannel.connect(wsUrl).cast<String>();
      });
      // Fetch credentials before proceeding with other operations
      await getCredentials(); // Ensure credentials are fetched first

      // Load ABI and contract address
      await getAbi();
      await getDeployedContract();
    } catch (e) {
      debugPrint("Error during initialization: $e");
      rethrow;
    }
  }

  // Fetch private credentials
  Future<void> getCredentials() async {
    try {
      _credentials = EthPrivateKey.fromHex(privateKey);
      debugPrint(
          "Credentials successfully initialized: $_credentials"); // Debugging line
    } catch (e) {
      debugPrint("Error getting credentials: $e");
      rethrow;
    }
  }

  // Load ABI from asset file
  Future<void> getAbi() async {
    try {
      final abiStringFile =
          await rootBundle.loadString("assets/EnergySolar.json");
      final jsonAbi = jsonDecode(abiStringFile);
      _abiCode = jsonEncode(jsonAbi["abi"]);
      _contractAddress =
          EthereumAddress.fromHex(jsonAbi["networks"]["5777"]["address"]);
    } catch (e) {
      debugPrint("Error loading ABI: $e");
      rethrow;
    }
  }

  // Initialize deployed contract
  Future<void> getDeployedContract() async {
    try {
      _contract = DeployedContract(
        ContractAbi.fromJson(_abiCode, "EnergySolar"),
        _contractAddress,
      );
      debugPrint("Contract successfully deployed: $_contract");

      // Bind contract functions
      _count = _contract.function("UserCount");
      _users = _contract.function("users");
      _addUser = _contract.function("addUser");
      _deleteUser = _contract.function("deleteUser");
      _editUser = _contract.function("editUser");
      _signIn = _contract.function("signin");

      // Fetch initial user data
      await getUsers();
    } catch (e) {
      debugPrint("Error deploying contract: $e");
    }
  }

  // Fetch list of users from the contract
  Future<void> getUsers() async {
    try {
      isLoading = true;
      notifyListeners();

      final contactList =
          await _client.call(contract: _contract, function: _count, params: []);
      final totalContacts = contactList[0] as BigInt;
      count = totalContacts.toInt();
      debugPrint("Total users count: $count");

      users.clear();
      for (int i = 0; i < count; i++) {
        final temp = await _client.call(
          contract: _contract,
          function: _users,
          params: [BigInt.from(i)],
        );

        if (temp[1] != "") {
          users.add(User(
            temp[0].toString(),
            name: temp[1],
            password: temp[2],
            phone: temp[3],
          ));
        }
      }
    } catch (e) {
      debugPrint("Error fetching users: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Add a new user to the contract
  Future<void> addUser(User user) async {
    try {
      if (_contract == null) {
        debugPrint("Contract has not been initialized!");
        return; // Don't proceed if contract is not initialized
      }

      if (_credentials == null) {
        debugPrint("Credentials have not been initialized!");
        return; // Don't proceed if credentials are not initialized
      }
      debugPrint("Adding new user: ${user.name}");
      isLoading = true;
      notifyListeners();

      await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
          contract: _contract,
          function: _addUser,
          parameters: [user.name, user.password, user.phone],
          maxGas: 1000000,
        ),
        chainId: 1337,
        fetchChainIdFromNetworkId: false,
      );
      await getUsers();
    } catch (e) {
      debugPrint("Error adding user: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Delete a user from the contract
  Future<void> deleteUser(int id) async {
    try {
      debugPrint("Deleting user with ID: $id");
      isLoading = true;
      notifyListeners();

      await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
          contract: _contract,
          function: _deleteUser,
          parameters: [BigInt.from(id)],
          maxGas: 1000000,
        ),
        chainId: 1337,
        fetchChainIdFromNetworkId: false,
      );
      await getUsers();
    } catch (e) {
      debugPrint("Error deleting user: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Edit user data in the contract
  Future<void> editUser(User user) async {
    try {
      debugPrint("Editing user: ${user.id}");
      isLoading = true;
      notifyListeners();

      await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
          contract: _contract,
          function: _editUser,
          parameters: [
            BigInt.from(int.parse(user.id)),
            user.name,
            user.password,
            user.phone,
          ],
          maxGas: 1000000,
        ),
        chainId: 1337,
        fetchChainIdFromNetworkId: false,
      );
      await getUsers();
    } catch (e) {
      debugPrint("Error editing user: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Sign in using name and password
  Future<bool> signIn(String name, String password) async {
    try {
      debugPrint("Signing in user: $name");
      isLoading = true;
      notifyListeners();

      final result = await _client.call(
        contract: _contract,
        function: _signIn,
        params: [name, password],
      );
      final isAuthenticated = result[0] as bool;
      return isAuthenticated;
    } catch (e) {
      debugPrint("Error signing in: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
