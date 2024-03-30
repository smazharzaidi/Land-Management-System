// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:frontend/UI/EnterCNIC.dart';
import 'package:frontend/UI/SignInScreen.dart';
import '../Functionality/DashboardLogic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'NFTWalletScreen.dart';
import '../Functionality/SignInAuth.dart';

class DashboardScreen extends StatefulWidget {
  final AuthServiceLogin authService;

  const DashboardScreen({Key? key, required this.authService})
      : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DashboardLogic _logic;

  @override
  void initState() {
    super.initState();
    _logic = DashboardLogic();
    _logic.initializeState();
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
              onTap: () async {
                // Mark this callback as asynchronous
                Navigator.of(context).pop(); // Close the drawer

                String? walletAddress =
                    await _logic.fetchWalletAddress(); // Await the result
                if (walletAddress != null) {
                  // Proceed with using the walletAddress
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          NFTListPage(address: walletAddress, chain: 'sepolia'),
                    ),
                  );
                } else {
                  // Handle the case where the wallet address is null
                  // For example, show an error message
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Error"),
                        content: Text("Failed to fetch wallet address."),
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
              },
            ),
            // Add more ListTiles for other menu items
          ],
        ),
      ),
      body: _logic.isLoggingOut
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
                    Navigator.of(context).pop(); // Close the dialog first
                    navigateToEnterCNIC(
                        "Sell (Beh)"); // Use the navigation method
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.family_restroom, color: Colors.green),
                  title: const Text('Death Transfer (Wirasat)'),
                  onTap: () {
                    Navigator.of(context).pop(); // Close the dialog first
                    navigateToEnterCNIC(
                        "Death Transfer (Wirasat)"); // Use the navigation method
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sync_alt, color: Colors.green),
                  title: const Text('In-Life Transfer (Tamleeq)'),
                  onTap: () {
                    Navigator.of(context).pop(); // Close the dialog first
                    navigateToEnterCNIC(
                        "In-Life Transfer (Tamleeq)"); // Use the navigation method
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.card_giftcard, color: Colors.green),
                  title: const Text('Gift (Hiba)'),
                  onTap: () {
                    Navigator.of(context).pop(); // Close the dialog first
                    navigateToEnterCNIC(
                        "Gift (Hiba)"); // Use the navigation method
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
                W3MNetworkSelectButton(service: _logic.w3mService),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: _logic.requestWalletAddresses,
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
  // Inside _DashboardScreenState class

  void navigateToEnterCNIC(String transferType) {
    // Assuming AuthServiceLogin.currentLandTransferData holds the LandTransferData instance
    if (AuthServiceLogin.currentLandTransferData == null) {
      // Handle case where LandTransferData is not available
      print("Error: LandTransferData is not initialized.");
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EnterCNIC(
          transferType: transferType,
          landTransferData:
              AuthServiceLogin.currentLandTransferData!, // Pass the instance
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    if (!mounted) return;

    // Close the dialog immediately to proceed with the logout
    Navigator.of(context).pop(); // Close the logout dialog

    setState(() {
      _logic.isLoggingOut = true; // Indicate loading
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('walletAddress');
      if (_logic.isConnected()) {
        await _logic.disconnect();
      }

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
        _logic.isLoggingOut = false; // Stop indicating loading
      });
      // Optionally, show an error dialog or toast here
    }
  }
}
