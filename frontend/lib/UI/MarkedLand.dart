import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Functionality/LandTransferData.dart';
import '../Functionality/LandService.dart';
import '../Functionality/SignInAuth.dart'; // Assuming this is where you've implemented token storage
import '../Functionality/config.dart';
import 'BayaanDateSelection.dart';

class MarkedLand extends StatefulWidget {
  final AuthServiceLogin authService;
  final LandTransferData landTransferData;

  const MarkedLand(
      {Key? key, required this.authService, required this.landTransferData})
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
      return List<String>.from(data['scheduled_datetimes']);
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

    if (landDetails != null && landDetails.isNotEmpty) {
      var bottomLeft = LatLng(
        landDetails['bottom_left']['latitude'],
        landDetails['bottom_left']['longitude'],
      );
      var topRight = LatLng(
        landDetails['top_right']['latitude'],
        landDetails['top_right']['longitude'],
      );
      return LatLngBounds(bottomLeft, topRight);
    } else {
      throw Exception('Marked land details are not available');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          'Marked Land',
          style: GoogleFonts.lato(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.grey[200],
        elevation: 0,
        centerTitle: true,
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

          return Column(
            children: [
              Expanded(
                child: FlutterMap(
                  options: MapOptions(
                    bounds: snapshot.data!,
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
                    // Add your additional map layers or markers here
                  ],
                ),
              ),
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
                  onPressed: () async {
                    List<String> scheduledDatetimes =
                        await fetchScheduledDatetimes();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BayaanDateSelection(
                          authService:
                            widget.authService,
                          landTransferData: widget.landTransferData,
                          scheduledDates: scheduledDatetimes,
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
          );
        },
      ),
    );
  }
}
