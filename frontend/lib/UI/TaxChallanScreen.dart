import 'package:flutter/material.dart';
import '../Functionality/TaxChallanLogic.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

class TaxChallanScreen extends StatelessWidget {
  final String userType; // 'transferor' or 'transferee'

  const TaxChallanScreen({Key? key, required this.userType}) : super(key: key);
  Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.request();
    return status.isGranted;
  }

  @override
  Widget build(BuildContext context) {
    final logic = TaxChallanLogic(); // Instantiate the logic class

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax Challan'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                if (await requestStoragePermission()) {
                  String? filePath =
                      await logic.generateChallanPdf(context, userType);
                  if (filePath != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('File saved at $filePath')));
                    // Optionally add a button or action to open or share the file
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Storage permission not granted')));
                }
              },
              child: const Text('Download PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Return'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
