import 'package:flutter/material.dart';
import '../Functionality/LandTransferData.dart';
import '../Functionality/BayaanSchedule.dart'; // Ensure this import is correct
import '../Functionality/config.dart';
import '../Functionality/SignInAuth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BayaanDateSelection extends StatefulWidget {
  final LandTransferData landTransferData;
  final List<String> scheduledDates;

  const BayaanDateSelection({
    Key? key,
    required this.landTransferData,
    required this.scheduledDates,
  }) : super(key: key);

  @override
  _BayaanDateSelectionState createState() => _BayaanDateSelectionState();
}

class _BayaanDateSelectionState extends State<BayaanDateSelection> {
  late BayaanSchedule schedule; // Declare schedule here
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    // Convert scheduledDates from String to DateTime
    List<DateTime> convertedScheduledDates = widget.scheduledDates
        .map((dateStr) => DateTime.parse(dateStr))
        .toList();
    // Initialize schedule with the converted dates
    schedule = BayaanSchedule(scheduledDates: convertedScheduledDates);
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
    widget.landTransferData.printDetails();
    final storage = SecureStorageService();
    final String? token = await storage.getToken();
    final Uri apiUri = Uri.parse(
        "${AppConfig.baseURL}create_land_transfer/"); // Adjust the URL based on your actual API endpoint
    print("Making request to: $apiUri");
    print("With headers: Authorization: Bearer $token");
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
        'scheduledDatetime': scheduledDatetime
            .toIso8601String(), // Convert DateTime to ISO 8601 string
      }),
    );

    if (response.statusCode == 200) {
      // Handle success
      print("Land transfer successfully scheduled.");
    } else {
      // Handle error
      print("Failed to schedule land transfer.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Bayaan Date and Time'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () => _showAvailableDates(context),
              child: Text(selectedDate == null
                  ? 'Select Date'
                  : 'Date: ${selectedDate!.toIso8601String().substring(0, 10)}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showAvailableTimeSlots(context),
              child: Text(selectedTime == null
                  ? 'Select Time Slot'
                  : 'Time: ${selectedTime!.format(context)}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
            ElevatedButton(
              onPressed: confirmBayaan,
              child: Text('Confirm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
