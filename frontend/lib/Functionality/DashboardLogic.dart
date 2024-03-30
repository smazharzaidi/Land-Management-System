import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/Functionality/SignInAuth.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

import 'config.dart';

class DashboardLogic {
  final Uri baseURI = Uri.parse("${AppConfig.baseURL}");
  late W3MService _w3mService;
  late SecureStorageService storage = SecureStorageService();
  bool isLoggingOut = false;

  DashboardLogic();

  static const _chainId = "11155111";
  final Set<String> _includedWalletIds = {
    'c57ca95b47569778a828d19178114f4db188b89b763c899ba0be274e97267d96', // MetaMask
  };

  void initializeState() async {
    _w3mService = W3MService(
        projectId: '3be38bea99b2f7d2ab77bda7940eb55c',
        metadata: const PairingMetadata(
          name: 'Web3Modal Flutter Example',
          description: 'Web3Modal Flutter Example',
          url: 'https://www.walletconnect.com/',
          icons: ['https://walletconnect.com/walletconnect-logo.png'],
          redirect: Redirect(
            native: 'flutterdapp://', // your own custom scheme
            universal: 'https://www.walletconnect.com',
          ),
        ),
        includedWalletIds: _includedWalletIds);
    await _w3mService.init();
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    print('Token saved: $token'); // Add this line to confirm token saving
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    print(
        'Retrieved token: $token'); // Add this line to confirm token retrieval
    return token;
  }

  Future<String?> fetchWalletAddress() async {
    print("fetchWalletAddress called");

    final String? token =
        await storage.getToken(); // Use SecureStorageService to get the token
    print("Token retrieved: $token"); // Check token value
    if (token == null) {
      print('No token found');
      return null;
    }
    final response = await http.get(
      Uri.parse('${baseURI}get_wallet_address/'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    print("HTTP status code: ${response.statusCode}"); // Check HTTP status
    print("HTTP response body: ${response.body}"); // Check HTTP response
    print(response.body);

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        return data["wallet_address"];
      } catch (e) {
        print('Error decoding response: $e');
        return null;
      }
    } else {
      print('Failed to load wallet address');
      return null;
    }
  }

  Future<String?> requestWalletAddresses() async {
    // Check if session or topic is null or empty
    if (_w3mService.session == null || _w3mService.session!.topic!.isEmpty) {
      print("Session is not initialized or topic is empty.");
      // Handle this case appropriately (e.g., initialization, error message)
      return null;
    }

    // Since we're here, session and topic are not null. However, we need to handle the possibility
    // that session!.topic might still be null. Let's ensure it's non-null before proceeding.
    final String? topic = _w3mService.session!.topic;
    if (topic == null) {
      print("Topic is null.");
      // Handle this case appropriately
      return null;
    }

    await _w3mService.launchConnectedWallet();
    print("launchConnectedWallet completed");
    var accounts = await _w3mService.web3App?.request(
      topic: topic, 
      chainId: 'eip155:$_chainId',
      request: SessionRequestParams(
        method: 'eth_requestAccounts',
        params: [],
      ),
    );
    print("Accounts received: $accounts");

    if (accounts != null && accounts.isNotEmpty) {
      final String walletAddress = accounts.first;
      _linkWalletToUser(walletAddress);
      return walletAddress;  
    } else {
      print("Failed to retrieve wallet address.");
      return null; // Return null if address retrieval fails
    }
  }

  void _linkWalletToUser(String walletAddress) async {
    final String? username = await AuthServiceLogin()
        .getUsername(); // Assuming this method returns the currently logged-in username.
    if (username == null) {
      print('Error: No username found. User is not logged in.');
      return;
    }
    print("Username to link with wallet: $username");

    final response = await http.post(
      Uri.parse(
          '${baseURI}link_wallet/'), // Adjust the URL to your backend endpoint for linking the wallet.
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'wallet_address': walletAddress,
      }),
    );

    if (response.statusCode == 200) {
      print('Wallet linked successfully');
    } else {
      print('Failed to link wallet. Error: ${response.body}');
    }
  }

  W3MService get w3mService => _w3mService;

  // Checks if the W3MService is connected
  bool isConnected() {
    return _w3mService.isConnected;
  }

  // Disconnects the W3MService
  Future<void> disconnect() async {
    if (_w3mService.isConnected) {
      await _w3mService.disconnect();
    }
  }
}
