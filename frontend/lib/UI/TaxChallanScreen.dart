import 'package:flutter/material.dart';

class TaxChallanScreen extends StatelessWidget {
  const TaxChallanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tax Challan'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Implement what happens when the Next button is pressed
            // For now, let's just pop back
            Navigator.pop(context);
          },
          child: Text('Next'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // Background color
          ),
        ),
      ),
    );
  }
}
