import 'package:flutter/material.dart';
import '../Functionality/LandTransferData.dart';
import 'BayaanDateSelection.dart';
import '../Functionality/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../Functionality/SignInAuth.dart'; // Assuming this is where you've implemented token storage
import '../Functionality/LandService.dart';

class MarkedLand extends StatefulWidget {
  final LandTransferData landTransferData;

  const MarkedLand({Key? key, required this.landTransferData})
      : super(key: key);

  @override
  _MarkedLandState createState() => _MarkedLandState();
}

class _MarkedLandState extends State<MarkedLand> {
  late Future<List<String>> scheduledDatetimes;
  late Future<LatLngBounds> markedLandDetails;

  @override
  void initState() {
    super.initState();
    scheduledDatetimes = fetchScheduledDatetimes();
    markedLandDetails = fetchMarkedLandDetails();
  }

  Future<List<String>> fetchScheduledDatetimes() async {
    final storage = SecureStorageService();
    final String? token = await storage.getToken();
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
      List<String> datetimes = List<String>.from(data['scheduled_datetimes']);
      return datetimes;
    } else {
      throw Exception('Failed to load scheduled datetimes');
    }
  }

  Future<LatLngBounds> fetchMarkedLandDetails() async {
    final landDetails = await LandService().fetchMarkedLand(
      widget.landTransferData.landTehsil,
      widget.landTransferData.landKhasra,
      widget.landTransferData.landDivision,
    );

    // Assuming landDetails returns a map with latitude and longitude pairs
    // for bottom-left and top-right corners of the marked land area.
    if (landDetails != null && landDetails.isNotEmpty) {
      // Parse the details to get the LatLng for bounds
      var bottomLeft = LatLng(
        landDetails['bottom_left']['latitude'],
        landDetails['bottom_left']['longitude'],
      );
      var topRight = LatLng(
        landDetails['top_right']['latitude'],
        landDetails['top_right']['longitude'],
      );

      // Create and return the bounds
      return LatLngBounds(bottomLeft, topRight);
    } else {
      throw Exception('Marked land details are not available');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Marked Land'),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<LatLngBounds>(
        future: markedLandDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No data found for marked land.'));
          }

          // Once data is fetched, use FlutterMap to display it
          LatLngBounds bounds = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: FlutterMap(
                  options: MapOptions(
                    bounds: bounds,
                    boundsOptions:
                        FitBoundsOptions(padding: EdgeInsets.all(8.0)),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.app',
                    ),
                    // Add your additional layers here
                  ],
                ),
              ),
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
                        landTransferData: widget.landTransferData,
                        scheduledDates:
                            scheduledDatetimes, // Now passing datetimes
                      ),
                    ),
                  );
                },
                child: Text('Next', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }
}
