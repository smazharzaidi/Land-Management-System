// ignore_for_file: file_names
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:frontend/UI/EnterCNIC.dart';
import 'package:frontend/UI/SignInScreen.dart';
import '../Functionality/DashboardLogic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'NFTWalletScreen.dart';
import '../Functionality/SignInAuth.dart';
import '../Functionality/TransferService.dart';
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
                SliverList(
                  delegate: SliverChildListDelegate([
                    Center(
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
                    SizedBox(height: 20), // Add some spacing
                    _buildPendingTransfersTable(), // Use the new table method
                    _buildApprovedTransfersTable(),
                  ]),
                ),
              ],
            ),
    );
  }

  Widget _buildPendingTransfersTable() {
    if (pendingTransfers == null) {
      // Show loading indicator
      return Center(child: CircularProgressIndicator());
    }

    if (pendingTransfers!.isEmpty) {
      // If there are no pending transfers, display a message
      return Center(child: Text("No outgoing pending transfers"));
    }

    // Adding a column for action buttons
    List<DataColumn> columns = [
      DataColumn(
          label: Text('CNIC', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Khasra', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Tehsil', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(
          label:
              Text('Division', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Action',
              style: TextStyle(
                  fontWeight: FontWeight.bold))), // Action button column
    ];

    List<DataRow> rows = pendingTransfers!.map<DataRow>((transfer) {
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

      return DataRow(
        cells: [
          DataCell(Text(transfer['transferee_user__cnic'])),
          DataCell(Text(transfer['land__khasra_number'])),
          DataCell(Text(transfer['land__tehsil'])),
          DataCell(Text(transfer['land__division'])),
          DataCell(Icon(statusIcon, color: iconColor)),
          DataCell(IconButton(
            icon: Icon(Icons.info_outline, color: Colors.blue),
            onPressed: () {
              // Check if status is "approved" and transfer_date is null (or you can adapt this condition as necessary)
              if (transfer['status'] == 'approved' &&
                  transfer['transfer_date'] == null) {
                // Navigate to TaxChallanScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TaxChallanScreen()),
                );
              } else if (transfer['status'] == 'pending') {
                // Show the scheduled meeting dialog for pending status
                _showScheduledMeetingDialog(context, transfer);
              }
              // You can add more conditions here for other statuses or actions
            },
          )),
        ],
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Pending Transfers',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(columns: columns, rows: rows),
        ),
      ],
    );
  }

  Widget _buildApprovedTransfersTable() {
    if (approvedTransfers == null) {
      // Show loading indicator
      return Center(child: CircularProgressIndicator());
    }

    // If there are no approved transfers, display a message
    if (approvedTransfers!.isEmpty) {
      return Center(child: Text("No approved transfers as transferee"));
    }

    // Define table column headers
    List<DataColumn> columns = [
      DataColumn(
          label: Text('CNIC', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Khasra', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Tehsil', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(
          label:
              Text('Division', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Action',
              style: TextStyle(
                  fontWeight: FontWeight.bold))), // Action button column
    ];

    // Define table rows based on approved transfers
    List<DataRow> rows = approvedTransfers!.map<DataRow>((transfer) {
      IconData statusIcon = Icons.check_circle_outline;
      Color iconColor = Colors.green;

      return DataRow(cells: [
        DataCell(Text(transfer['transferor_user__cnic'])),
        DataCell(Text(transfer['land__khasra_number'])),
        DataCell(Text(transfer['land__tehsil'])),
        DataCell(Text(transfer['land__division'])),
        DataCell(Icon(statusIcon, color: iconColor)),
        DataCell(IconButton(
          icon: Icon(Icons.event_available, color: Colors.blue),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TaxChallanScreen()),
            );
          },
        )),
      ]);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Approved Transfers',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(columns: columns, rows: rows),
        ),
      ],
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
