import 'package:flutter/material.dart';
import '../Functionality/CNICInputFormatter.dart';
import '../Functionality/CNICVerification.dart';
import '../Functionality/LandTransferData.dart';
import 'NFTSelection.dart';
import '../Functionality/DashboardLogic.dart';

class EnterCNIC extends StatefulWidget {
  final String
      transferType; // To handle different logic based on the transfer type
  final LandTransferData landTransferData;

  const EnterCNIC({
    Key? key,
    required this.transferType,
    required this.landTransferData,
  }) : super(key: key);

  @override
  State<EnterCNIC> createState() => _EnterCNICState();
}

class _EnterCNICState extends State<EnterCNIC> {
  late DashboardLogic _logic;
  @override
  void initState() {
    super.initState();
    _logic = DashboardLogic(); // Initialize DashboardLogic here
  }

  String _getTransferType(String type) {
    switch (type) {
      case "Sell (Beh)":
        return "selling";
      case "Gift (Hiba)":
        return "gift";
      case "Death Transfer (Wirasat)":
        return "death_mutation";
      case "In-Life Transfer (Tamleeq)":
        return "in_life_mutation";
      default:
        return "Unknown";
    }
  }

  final _cnicController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _submitCNIC() async {
    if (_formKey.currentState!.validate()) {
      final String transferType = _getTransferType(widget.transferType);
      CNICVerification cnicVerification =
          CNICVerification(context, _logic, widget.landTransferData);

      bool isValid = await cnicVerification.verifyCNICAndNavigate(
          _cnicController.text, transferType);
      if (isValid) {
        String? walletAddress = await _logic.fetchWalletAddress();
        if (walletAddress != null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NFTSelection(
                        address: walletAddress,
                        chain: 'sepolia',
                        landTransferData: widget.landTransferData,
                      )));
        } else {
          // Optionally, handle the case where wallet address fetch fails
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
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              );
            },
          );
        }
      } else {
        // Optionally, handle the case where CNIC verification fails
        // For example, show an error message
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter CNIC for ${widget.transferType}'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Please enter your CNIC number to proceed with the ${widget.transferType}.',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _cnicController,
                  decoration: InputDecoration(
                    labelText: 'CNIC Number',
                    hintText: 'e.g., 42101-2345678-9',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.credit_card, color: Colors.green),
                    errorStyle: TextStyle(
                      // Adjust the style here
                      color: Colors.red, // Use any color for the error text
                      fontSize: 10.0, // You can adjust the font size as needed
                      height:
                          1.2, // Increase line height for better readability
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    CNICInputFormatter()
                  ], // Apply the CNIC formatter here
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your CNIC number';
                    } else if (value.length != 15) {
                      // Include the dashes in the count
                      return 'A CNIC number must be in the format: xxxxx-xxxxxxx-x';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: _submitCNIC,
                  child: Text(
                    'Submit',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
