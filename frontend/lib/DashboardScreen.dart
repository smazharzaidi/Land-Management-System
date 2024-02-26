// ignore_for_file: file_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/SignInAuth.dart';
import 'package:frontend/SignInScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'NFTSelection.dart';

class DashboardScreen extends StatefulWidget {
  final AuthServiceLogin authService;

  const DashboardScreen({Key? key, required this.authService})
      : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // @override
  // void initState() {
  //   super.initState();
  // Initialize the WalletConnect connector here or ensure it's accessible
  WalletConnect connector = WalletConnect(
    bridge: 'https://bridge.walletconnect.org',
    clientMeta: const PeerMeta(
        name: 'CryptoLand',
        description: 'App Description',
        url: 'https://walletconnect.org',
        icons: [
          'https://gblobscdn.gitbook.com/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
        ]),
  );
  // }
  var _uri, _session;
  loginUsingMetamask(BuildContext context) async {
    if (!connector.connected) {
      try {
        var session = await connector.createSession(onDisplayUri: (uri) async {
          _uri = uri;
          if (await canLaunchUrlString(uri)) {
            await launchUrlString(uri, mode: LaunchMode.externalApplication);
          } else {
            throw 'Could not launch $uri';
          }
        });
        // print(session.accounts[0]);
        // print(session.chainId);
        setState(() {
          _session = session;
        });
        print("Connected: ${session.accounts[0]}");

        // if (session != null) {
        //   setState(() {
        //     _walletAddress = session.accounts[0];
        //     print("Session created: $session");
        //     print("Wallet address: $_walletAddress");
        //   });

        //   // Optionally, link the wallet address to the user account
        //   // await linkWalletToUser(_walletAddress!);

        //   // // Show a dialog upon successful connection
        //   // showDialog(
        //   //   context: context,
        //   //   builder: (context) => AlertDialog(
        //   //     title: const Text('Connection Successful'),
        //   //     content: const Icon(Icons.check_circle_outline,
        //   //         color: Colors.green, size: 60),
        //   //     actions: [
        //   //       TextButton(
        //   //         onPressed: () => Navigator.of(context).pop(),
        //   //         child: const Text('OK'),
        //   //       ),
        //   //     ],
        //   //   ),
        //   // );
        // }
      } on Exception catch (e) {
        print("Error connecting to MetaMask: $e");
        _showErrorDialog(context, "Error connecting to MetaMask: $e");
      } catch (e) {
        // Handle any other types of errors
        print("An unexpected error occurred: $e");
        _showErrorDialog(context, "An unexpected error occurred: $e");
      }
    }
  }

  // Future<void> linkWalletToUser(String walletAddress) async {
  //   String? username = await getUsername();
  //   if (username == null) {
  //     print("Username is null. Cannot proceed with linking wallet.");
  //     return;
  //   }

  //   var response = await http.post(
  //     Uri.parse('http://192.168.1.11:8000/link_wallet/'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode(<String, String>{
  //       'username': username,
  //       'wallet_address': walletAddress,
  //     }),
  //   );

  //   if (response.statusCode == 200) {
  //     print("Wallet linked successfully.");
  //   } else {
  //     print("Failed to link wallet. Status code: ${response.statusCode}");
  //   }
  // }

  // Future<String?> getUsername() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   return prefs.getString('username');
  // }
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
                  leading: const Icon(Icons.account_balance_wallet,
                      color: Colors.green),
                  title: const Text('Connect to MetaMask'),
                  onTap: () => loginUsingMetamask(context),
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app, color: Colors.green),
                  title: const Text('Logout'),
                  onTap: () {
                    _handleLogout(); // Simply call the logout method
                  },
                ),

                // Add more options as needed
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

    try {
      setState(() {
        _isLoggingOut = true; // Start showing the loading indicator
      });

      // Simulating a logout operation with a delay
      await Future.delayed(
          Duration(seconds: 2)); // Placeholder for your actual logout logic
      // If the authService.logout() method throws an error, it will be caught by the catch block

      if (!mounted) return;

      // Navigate to the SignInScreen upon successful logout
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => SignInScreen()));
    } catch (error) {
      print("Logout failed: $error");
      // Handle logout failure (e.g., show a toast notification)
      if (!mounted) return;

      setState(() {
        _isLoggingOut =
            false; // Hide the loading indicator and possibly show an error message
      });
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
