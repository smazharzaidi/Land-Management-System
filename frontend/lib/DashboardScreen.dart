// ignore_for_file: file_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/SignInAuth.dart';
import 'package:frontend/SignInScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'NFTSelection.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class DashboardScreen extends StatefulWidget {
  final AuthServiceLogin authService;

  const DashboardScreen({Key? key, required this.authService})
      : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late W3MService _w3mService;
  @override
  void initState() {
    super.initState();
    initializeState();
  }

  static const _chainId = "80001";
  // final _polygonChain = W3MChainInfo(
  //   chainName: 'Mumbai',
  //   chainId: _chainId,
  //   namespace: 'eip155:$_chainId',
  //   tokenName: 'MATIC',
  //   rpcUrl: '<https://rpc.ankr.com/polygon_mumbai>',
  //   blockExplorer: W3MBlockExplorer(
  //     name: 'Polygonscan',
  //     url:
  //         '<https://mumbai.polygonscan.com/>', // Block explorer URL for the Mumbai testnet
  //   ),
  // );
  final Set<String> _includedWalletIds = {
    'c57ca95b47569778a828d19178114f4db188b89b763c899ba0be274e97267d96', // MetaMask
  };
  void initializeState() async {
    // W3MChainPresets.chains.putIfAbsent(_chainId, () => _polygonChain);
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

  void requestWalletAddress() async {
    // Check if session or topic is null or empty
    if (_w3mService.session == null || _w3mService.session!.topic!.isEmpty ??
        true) {
      print("Session is not initialized or topic is empty.");
      // Handle this case appropriately (e.g., initialization, error message)
      return;
    }

    // Since we're here, session and topic are not null. However, we need to handle the possibility
    // that session!.topic might still be null. Let's ensure it's non-null before proceeding.
    final String? topic = _w3mService.session!.topic;
    if (topic == null) {
      print("Topic is null.");
      // Handle this case appropriately
      return;
    }

    // Proceed with non-null topic
    await _w3mService.launchConnectedWallet();
    var accounts = await _w3mService.web3App?.request(
      topic: topic, // Safe to use topic here as it's confirmed to be non-null
      chainId: 'eip155:$_chainId',
      request: SessionRequestParams(
        method: 'eth_requestAccounts',
        params: [],
      ),
    );

    if (accounts != null && accounts.isNotEmpty) {
      final String walletAddress = accounts.first;
      _linkWalletToUser(walletAddress);
    } else {
      print("Failed to retrieve wallet address.");
    }
  }

  void _linkWalletToUser(String walletAddress) async {
    final String? username = await AuthServiceLogin()
        .getUsername(); // Assuming this method returns the currently logged-in username.
    if (username == null) {
      print('Error: No username found. User is not logged in.');
      return;
    }

    final response = await http.post(
      Uri.parse(
          'http://192.168.1.12:8000/link_wallet/'), // Adjust the URL to your backend endpoint for linking the wallet.
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

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool _isLoggingOut = false;

  void _showProfileOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Profile Options'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.green),
                  title: const Text('Profile Setting'),
                  onTap: () {
                    // Implement Profile Settings functionality
                    Navigator.of(context)
                        .pop(); // Close the dialog after the action
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app, color: Colors.green),
                  title: const Text('Logout'),
                  onTap: () {
                    _handleLogout(); // Simply call the logout method
                  },
                ),
                W3MNetworkSelectButton(service: _w3mService),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: requestWalletAddress,
                  child: const Text(
                    'Link Permenantly',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    if (!mounted) return;

    // Close the dialog immediately to proceed with the logout
    Navigator.of(context).pop(); // Close the logout dialog

    setState(() {
      _isLoggingOut = true; // Indicate loading
    });

    try {
      // Replace Future.delayed with actual logout operation
      await AuthServiceLogin().logout();

      if (!mounted) return;

      // Navigate to the SignInScreen upon successful logout
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => SignInScreen()));
    } catch (error) {
      print("Logout failed: $error");
      if (!mounted) return;

      setState(() {
        _isLoggingOut = false; // Stop indicating loading
      });
      // Optionally, show an error dialog or toast here
    }
  }

  void _showTransferTypes(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Transfer Type'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  leading:
                      const Icon(Icons.monetization_on, color: Colors.green),
                  title: const Text('Sell (Beh)'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NFTSelection()),
                    );
                    // Implement Sell transfer functionality
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.family_restroom, color: Colors.green),
                  title: const Text('Death Transfer (Wirasat)'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NFTSelection()),
                    );
                    // Implement Death Transfer functionality
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sync_alt, color: Colors.green),
                  title: const Text('In-Life Transfer (Tamleeq)'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NFTSelection()),
                    );
                    // Implement In-Life Transfer functionality
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.card_giftcard, color: Colors.green),
                  title: const Text('Gift (Hiba)'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NFTSelection()),
                    );
                    // Implement Gift functionality
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading:
                  const Icon(Icons.account_balance_wallet, color: Colors.green),
              title: const Text('Land Wallet'),
              onTap: () {
                // Implement navigation
              },
            ),
            // Add more ListTiles for other menu items
          ],
        ),
      ),
      body: _isLoggingOut
          ? Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.green, // Set background color
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text('Land Management Dashboard'),
                    background: Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/4/40/Field_in_K%C3%A4rk%C3%B6l%C3%A4.jpg/275px-Field_in_K%C3%A4rk%C3%B6l%C3%A4.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  actions: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.account_circle),
                      onPressed: () => _showProfileOptions(context),
                    ),
                  ],
                ),
                SliverFillRemaining(
                  child: Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () => _showTransferTypes(context),
                      child: const Text(
                        'Initiate Transfers',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
