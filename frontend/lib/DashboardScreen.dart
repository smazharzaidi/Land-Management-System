// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:frontend/InactivityMixin.dart';
import 'package:frontend/SignInAuth.dart';
import 'package:frontend/SignInScreen.dart';
import 'NFTSelection.dart';

class DashboardScreen extends StatefulWidget {
  final AuthServiceLogin authService;

  const DashboardScreen({Key? key, required this.authService})
      : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with InactivityMixin {
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
                  onTap: () async {
                    setState(() {
                      _isLoggingOut = true;
                    });
                    Navigator.of(context).pop(); // Close the dialog
                    await widget.authService.logout();

                    if (!mounted) return;
                    setState(() {
                      _isLoggingOut = false;
                    });

                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => SignInScreen()));
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
    return GestureDetector(
      onTap: resetInactivityTimer,
      onPanUpdate: (_) => resetInactivityTimer(),
      child: Scaffold(
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
                leading: const Icon(Icons.account_balance_wallet,
                    color: Colors.green),
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
      ),
    );
  }
}
