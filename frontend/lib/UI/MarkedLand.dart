import 'package:flutter/material.dart';
import '../Functionality/LandTransferData.dart';
import 'BayaanDateSelection.dart';
import '../Functionality/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Functionality/SignInAuth.dart'; // Assuming this is where you've implemented token storage

class MarkedLand extends StatelessWidget {
  final LandTransferData landTransferData;

  const MarkedLand({Key? key, required this.landTransferData})
      : super(key: key);

  Future<List<String>> fetchScheduledDatetimes() async {
    final storage = SecureStorageService();
    final String? token = await storage.getToken();
    // Update the API endpoint if necessary
    final Uri apiUri =
        Uri.parse("${AppConfig.baseURL}get_scheduled_datetimes/");

    final response = await http.get(
      apiUri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      // Assuming the backend now returns 'scheduled_datetimes'
      List<String> datetimes = List<String>.from(data['scheduled_datetimes']);
      return datetimes;
    } else {
      throw Exception('Failed to load scheduled datetimes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Marked Land'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Details of the marked land will be displayed here.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () async {
                List<String> scheduledDatetimes =
                    await fetchScheduledDatetimes();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BayaanDateSelection(
                      landTransferData: landTransferData,
                      scheduledDates:
                          scheduledDatetimes, // Now passing datetimes
                    ),
                  ),
                );
              },
              child: Text('Next', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
