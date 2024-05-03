import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Functionality/LandTransferData.dart';
import '../Functionality/BayaanSchedule.dart'; // Ensure this import is correct
import '../Functionality/config.dart';
import '../Functionality/SignInAuth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'DashboardScreen.dart';

class BayaanDateSelection extends StatefulWidget {
  final AuthServiceLogin authService;
  final LandTransferData landTransferData;
  final List<String> scheduledDates;

  const BayaanDateSelection({
    Key? key,
    required this.landTransferData,
    required this.scheduledDates,
    required this.authService,
  }) : super(key: key);

  @override
  _BayaanDateSelectionState createState() => _BayaanDateSelectionState();
}

class _BayaanDateSelectionState extends State<BayaanDateSelection> {
  late BayaanSchedule schedule;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isLoading = false; // State to manage loading indicator

  @override
  void initState() {
    super.initState();
    schedule = BayaanSchedule(
        scheduledDates: widget.scheduledDates
            .map((dateStr) => DateTime.parse(dateStr))
            .toList());
  }

  void _showAvailableDates(BuildContext context) async {
    DateTime now = DateTime.now();
    // Finding the next valid initial date that isn't disabled, today, or a weekend
    DateTime initialDate = now.add(Duration(days: 1));
    List<DateTime> disabledDates = widget.scheduledDates
        .map((strDate) => DateTime.parse(strDate))
        .toList();
    int addedDays =
        0; // Keep track of how many days we've added in search of a valid date

    while (true) {
      // If we reach a non-selectable date (weekend or disabled), or we've exceeded 3 days of search, break
      if ((initialDate.weekday != DateTime.saturday &&
              initialDate.weekday != DateTime.sunday &&
              !disabledDates
                  .any((date) => date.isAtSameMomentAs(initialDate))) ||
          addedDays > 3) {
        break;
      }
      initialDate = initialDate.add(Duration(days: 1));
      addedDays++;
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: initialDate,
      lastDate: now.add(Duration(
          days: 3)), // This ensures the max range is up to 3 days from now
      selectableDayPredicate: (DateTime val) {
        // Disable weekends and specific dates from disabledDates
        return val.weekday != DateTime.saturday &&
            val.weekday != DateTime.sunday &&
            !disabledDates.any((date) => date.isAtSameMomentAs(val));
      },
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  void _showAvailableTimeSlots(BuildContext context) async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a date first.")),
      );
      return;
    }
    final List<TimeOfDay> availableSlots =
        schedule.getAvailableTimeSlots(selectedDate!);

    // Show dialog to select a time slot
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select a Time Slot"),
          content: Container(
            // This container holds all available time slots, allowing the user to pick one
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availableSlots.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text('${availableSlots[index].format(context)}'),
                  onTap: () {
                    setState(() {
                      selectedTime = availableSlots[index];
                    });
                    Navigator.of(context).pop(); // Close the dialog
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> confirmBayaan() async {
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select both date and time.")));
      return;
    }
    setState(() => isLoading = true);

    final storage = SecureStorageService();
    final String? token = await storage.getToken();
    final Uri apiUri = Uri.parse("${AppConfig.baseURL}create_land_transfer/");

    DateTime scheduledDatetime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    final response = await http.post(
      apiUri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'transferorCNIC': widget.landTransferData.transferorCNIC,
        'transfereeCNIC': widget.landTransferData.transfereeCNIC,
        'transferType': widget.landTransferData.transferType,
        'landTehsil': widget.landTransferData.landTehsil,
        'landKhasra': widget.landTransferData.landKhasra,
        'landDivision': widget.landTransferData.landDivision,
        'scheduledDatetime': scheduledDatetime.toIso8601String(),
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("Success"),
          content: Text("Land transfer is initiated and Bayaan is scheduled."),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(ctx).pop(); // Close the dialog
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => DashboardScreen(
                        authService:
                            widget.authService))); // Pass the authService here
              },
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("Error"),
          content: Text("Failed to schedule land transfer."),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Select Bayaan Date and Time',
            style: GoogleFonts.lato(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        backgroundColor: Colors.grey[200],
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Date',
                suffixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              controller: TextEditingController(
                  text: selectedDate == null
                      ? 'Tap to select date'
                      : selectedDate.toString().substring(0, 10)),
              onTap: () => _showAvailableDates(context),
            ),
            SizedBox(height: 20),
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Time',
                suffixIcon: Icon(Icons.access_time),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              controller: TextEditingController(
                  text: selectedTime == null
                      ? 'Tap to select time'
                      : selectedTime!.format(context)),
              onTap: () => _showAvailableTimeSlots(context),
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
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                ),
                onPressed: isLoading
                    ? null
                    : confirmBayaan, // Disable the button when loading
                child: isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text(
                        'Confirm',
                        style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
