// ignore_for_file: file_names

import 'package:flutter/material.dart';

class FingerPrinting extends StatelessWidget {
  const FingerPrinting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController receiptNumberController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fingerprint Verification',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Fingerprint Verification Instructions:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              '1. Both the transferer and transferee should visit a NADRA e-Sahulat center.',
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              '2. Get your fingerprints verified.',
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              '3. Obtain a receipt number after verification.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: receiptNumberController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Receipt Number',
                hintText: 'Enter your receipt number here',
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  // Implement what happens when 'Next' is pressed
                },
                child: const Text('Next', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
