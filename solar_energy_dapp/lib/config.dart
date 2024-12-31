import 'package:web3dart/web3dart.dart';

const String rpcUrl = "http://127.0.0.1:7545"; // Local Ethereum node URL
const String wsUrl =
    "ws://127.0.0.1:7545"; // WebSocket URL for real-time updates
const String privateKey =
    "0x0e5c7e5f657b87f0632928ccd47c76f668d79e241f47ce890a75bf3f3f809ea7"; // Replace with your private key

EthereumAddress userAddress =
    EthereumAddress.fromHex('0x2d18C2C0e11a82C7a980e8fCdF05EF41a6b31f1E');
List<EthereumAddress> userAddresses = [
  EthereumAddress.fromHex('0x79E96ec3ab6066DFB9704b9Ea895a657a7B83FC6'),
  EthereumAddress.fromHex('0x3C07aC1b14AD00d4C9760961483F160e27888849'),
  EthereumAddress.fromHex('0x739dC0e3fA474b76577e69344263014ACd6B9120'),
  EthereumAddress.fromHex('0x6D02191EB91943a267Fc7F1ffaD3849758978b27'),
];
