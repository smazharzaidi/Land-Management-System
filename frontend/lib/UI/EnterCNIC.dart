import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Functionality/CNICInputFormatter.dart';
import '../Functionality/CNICVerification.dart';
import '../Functionality/LandTransferData.dart';
import '../Functionality/SignInAuth.dart';
import 'NFTSelection.dart';
import '../Functionality/DashboardLogic.dart';

class EnterCNIC extends StatefulWidget {
  final String transferType;
  final LandTransferData landTransferData;
  final AuthServiceLogin authService;

  const EnterCNIC({
    Key? key,
    required this.transferType,
    required this.landTransferData,
    required this.authService,
  }) : super(key: key);

  @override
  State<EnterCNIC> createState() => _EnterCNICState();
}

class _EnterCNICState extends State<EnterCNIC> {
  late DashboardLogic _logic;
  final _cnicController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // State variable for managing loading state

  @override
  void initState() {
    super.initState();
    _logic = DashboardLogic();
  }

  Future<void> _submitCNIC() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Set loading to true
      });
      final String transferType = _getTransferType(widget.transferType);
      CNICVerification cnicVerification = CNICVerification(
          context, _logic, widget.landTransferData, widget.authService);

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
                        authService: widget.authService,
                      )));
        } else {
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
      }
      setState(() {
        _isLoading = false; // Reset loading state after operation
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Enter CNIC for ${widget.transferType}',
            style: GoogleFonts.lato(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        backgroundColor: Colors.grey[200],
        elevation: 0,
        centerTitle: true,
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
                    labelStyle: GoogleFonts.lato(),
                    hintText: 'e.g., 42101-2345678-9',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.credit_card),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [CNICInputFormatter()],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your CNIC number';
                    } else if (value.length != 15) {
                      return 'A CNIC number must be in the format: xxxxx-xxxxxxx-x';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
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
                    onPressed: _submitCNIC,
                    child: _isLoading
                        ? CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : Text(
                            'Submit',
                            style: GoogleFonts.lato(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
