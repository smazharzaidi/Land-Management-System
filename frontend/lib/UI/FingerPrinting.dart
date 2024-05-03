import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Functionality/LandTransferData.dart';
import 'MarkedLand.dart';
import '../Functionality/SignInAuth.dart'; // Assuming AuthServiceLogin is defined here

class FingerPrinting extends StatelessWidget {
  final LandTransferData landTransferData;
  final AuthServiceLogin authService;

  const FingerPrinting({
    Key? key,
    required this.landTransferData,
    required this.authService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController receiptNumberController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Fingerprint Verification',
            style: GoogleFonts.lato(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.grey[200],
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Fingerprint Verification Instructions:',
              style:
                  GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '1. Both the transferer and transferee should visit a NADRA e-Sahulat center.',
              style: GoogleFonts.lato(fontSize: 16),
            ),
            Text(
              '2. Get your fingerprints verified.',
              style: GoogleFonts.lato(fontSize: 16),
            ),
            Text(
              '3. Obtain a receipt number after verification.',
              style: GoogleFonts.lato(fontSize: 16),
            ),
            SizedBox(height: 20),
            TextField(
              controller: receiptNumberController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.white,
                labelText: 'Receipt Number',
                hintText: 'Enter your receipt number here',
                labelStyle: GoogleFonts.lato(),
              ),
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MarkedLand(
                        landTransferData:
                            landTransferData, // Use the direct variable
                        authService: authService, // Use the direct variable
                      ),
                    ),
                  );
                },
                child: Text('Next',
                    style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
