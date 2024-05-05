// ignore_for_file: file_names
import 'package:flutter/widgets.dart';
import 'package:frontend/UI/BottomNavBarScreen.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:frontend/UI/EnterCNIC.dart';
import '../Functionality/DashboardLogic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'NFTWalletScreen.dart';
import '../Functionality/SignInAuth.dart';
import '../Functionality/TransferService.dart';
import 'ProfileScreen.dart';
import 'TaxChallanScreen.dart';

class DashboardScreen extends StatefulWidget {
  final AuthServiceLogin authService;

  const DashboardScreen({Key? key, required this.authService})
      : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DashboardLogic _logic;
  List<dynamic>? pendingTransfers = null;
  List<dynamic>? approvedTransfers = null;
  Map<String, bool> _actionInProgress = {};

  @override
  void initState() {
    super.initState();
    _logic = DashboardLogic();
    _logic.initializeState();
    fetchPendingTransfers();
    fetchApprovedTransfers();
  }

  Future<void> fetchPendingTransfers() async {
    final TransferService service = TransferService();
    try {
      var fetchedTransfers = await service.fetchPendingTransfers();
      setState(() {
        pendingTransfers =
            fetchedTransfers; // Even if empty, it's now initialized
      });
    } catch (e) {
      print('Failed to fetch pending transfers: $e');
      setState(() {
        pendingTransfers =
            []; // Initialize to empty to indicate finished attempt
      });
      // Optionally, show an error message or handle the error appropriately
    }
  }

  Future<void> fetchApprovedTransfers() async {
    final TransferService service = TransferService();
    try {
      var fetchedTransfers = await service.fetchApprovedTransfers();
      setState(() {
        approvedTransfers =
            fetchedTransfers; // Even if empty, it's now initialized
      });
    } catch (e) {
      print('Failed to fetch approved transfers: $e');
      setState(() {
        approvedTransfers =
            []; // Initialize to empty to indicate finished attempt
      });
      // Optionally, show an error message or handle the error appropriately
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_logic.isLoggingOut) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.grey[200],
            title: Text(
              'Dashboard',
              style: GoogleFonts.lato(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.account_circle, color: Colors.black),
                onPressed: () => _showProfileOptions(context),
              ),
            ],
          ),
        ),
        body: _logic.isLoggingOut
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(12),
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Welcome to your dashboard!',
                            style: GoogleFonts.lato(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate([
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 90.0),
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0)),
                                padding: EdgeInsets.symmetric(vertical: 15.0)),
                            onPressed: () => _showTransferTypes(context),
                            child: const Text(
                              'Initiate Transfer',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(height: 20), // Add some spacing
                        _buildPendingTransfersTable(), // Use the new table method
                        _buildApprovedTransfersTable(),
                      ]),
                    ),
                  ],
                ),
              ),
      );
    }
  }

  Widget _buildPendingTransfersTable() {
    if (pendingTransfers == null) {
      return Center(child: CircularProgressIndicator());
    }

    if (pendingTransfers!.isEmpty) {
      return Center(child: Text("No outgoing pending transfers"));
    }

    return ListView.builder(
      physics:
          NeverScrollableScrollPhysics(), // to disable ListView's scrolling
      shrinkWrap: true, // to make ListView occupy space only its children need
      itemCount: pendingTransfers!.length,
      itemBuilder: (context, index) {
        var transfer = pendingTransfers![index];
        IconData statusIcon;
        Color iconColor;

        switch (transfer['status']) {
          case 'approved':
            statusIcon = Icons.check_circle_outline;
            iconColor = Colors.green;
            break;
          case 'pending':
            statusIcon = Icons.hourglass_empty;
            iconColor = Colors.orange;
            break;
          case 'disapproved':
            statusIcon = Icons.cancel_outlined;
            iconColor = Colors.red;
            break;
          default:
            statusIcon = Icons.help_outline;
            iconColor = Colors.grey;
        }

        return Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: Icon(statusIcon, color: iconColor),
            title: Text(transfer['land__khasra_number']),
            subtitle: Text(
                'Tehsil: ${transfer['land__tehsil']}\nDivision: ${transfer['land__division']}'),
            trailing: _actionInProgress[transfer['land__khasra_number']] == true
                ? CircularProgressIndicator()
                : IconButton(
                    icon: Icon(Icons.info_outline, color: Colors.blue),
                    onPressed: () {
                      // Check if status is "approved" and transfer_date is null (or you can adapt this condition as necessary)
                      if (transfer['status'] == 'approved' &&
                          transfer['transfer_date'] == null) {
                        // Navigate to TaxChallanScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaxChallanScreen(
                              userType: 'transferor',
                              khasraNumber: transfer['land__khasra_number'],
                              tehsil: transfer['land__tehsil'],
                              division: transfer['land__division'],
                            ),
                          ),
                        );
                      } else if (transfer['status'] == 'pending') {
                        // Show the scheduled meeting dialog for pending status
                        _showScheduledMeetingDialog(context, transfer);
                      }
                      // You can add more conditions here for other statuses or actions
                    },
                  ),
          ),
        );
      },
    );
  }

  Widget _buildApprovedTransfersTable() {
    if (approvedTransfers == null) {
      return Center(child: CircularProgressIndicator());
    }

    if (approvedTransfers!.isEmpty) {
      return Center(child: Text("No approved transfers as transferee"));
    }

    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: approvedTransfers!.length,
      itemBuilder: (context, index) {
        var transfer = approvedTransfers![index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: Icon(Icons.check_circle_outline, color: Colors.green),
            title: Text(transfer['land__khasra_number']),
            subtitle: Text(
                'Tehsil: ${transfer['land__tehsil']}\nDivision: ${transfer['land__division']}'),
            trailing: _actionInProgress[transfer['land__khasra_number']] == true
                ? CircularProgressIndicator()
                : IconButton(
                    icon: Icon(Icons.info_outline, color: Colors.blue),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaxChallanScreen(
                            userType: 'transferee',
                            khasraNumber: transfer['land__khasra_number'],
                            tehsil: transfer['land__tehsil'],
                            division: transfer['land__division'],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  void _showScheduledMeetingDialog(BuildContext context, dynamic transfer) {
    // Extracting and formatting the scheduled date and time
    DateTime scheduledDateTime = DateTime.parse(transfer['scheduled_datetime']);
    String formattedDateTime =
        DateFormat('yyyy-MM-dd – kk:mm').format(scheduledDateTime);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Meeting Scheduled'),
          content: Text(
              'You are scheduled to meet the tehsildar on $formattedDateTime. Please be on time.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
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
                      const Icon(Icons.monetization_on, color: Colors.black),
                  title: const Text('Sell (Beh)'),
                  onTap: () {
                    Navigator.of(context).pop(); // Close the dialog first
                    navigateToEnterCNIC(
                        "Sell (Beh)"); // Use the navigation method
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.family_restroom, color: Colors.black),
                  title: const Text('Death Transfer (Wirasat)'),
                  onTap: () {
                    Navigator.of(context).pop(); // Close the dialog first
                    navigateToEnterCNIC(
                        "Death Transfer (Wirasat)"); // Use the navigation method
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sync_alt, color: Colors.black),
                  title: const Text('In-Life Transfer (Tamleeq)'),
                  onTap: () {
                    Navigator.of(context).pop(); // Close the dialog first
                    navigateToEnterCNIC(
                        "In-Life Transfer (Tamleeq)"); // Use the navigation method
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.card_giftcard, color: Colors.black),
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
                  leading: const Icon(Icons.settings, color: Colors.black),
                  title: const Text('Profile Setting'),
                  onTap: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app, color: Colors.black),
                  title: const Text('Logout'),
                  onTap: () {
                    _handleLogout();
                  },
                ),
                W3MNetworkSelectButton(service: _logic.w3mService),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 20.0), // Reduce or remove to expand button
                  child: ButtonBar(
                    alignment: MainAxisAlignment.center,
                    buttonPadding: EdgeInsets
                        .zero, // Removes additional padding around the button
                    children: <Widget>[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                          padding: EdgeInsets.symmetric(vertical: 15.0),
                        ),
                        onPressed: _logic.requestWalletAddresses,
                        child: const Text(
                          'Link Permanently',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
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
          authService: widget.authService,
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    if (!mounted) return;

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

      // Navigate to the BottomNavBarScreen upon successful logout
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => BottomNavBarScreen()),
        (route) => false,
      );
    } catch (error) {
      print("Logout failed: $error");
      if (!mounted) return;

      setState(() {
        _logic.isLoggingOut = false; // Stop indicating loading
      });
      // Optionally, show an error dialog or toast here
      _showErrorDialog(context, "Logout failed. Please try again.");
    }
  }
}
