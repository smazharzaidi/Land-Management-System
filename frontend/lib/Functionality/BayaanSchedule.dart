import 'package:flutter/material.dart';

class BayaanSchedule {
  final List<DateTime> scheduledDates;

  BayaanSchedule({required this.scheduledDates});
  bool isDateAvailable(DateTime date) {
    // Check against the scheduledDates passed to the constructor
    for (DateTime scheduledDate in scheduledDates) {
      if (date.year == scheduledDate.year &&
          date.month == scheduledDate.month &&
          date.day == scheduledDate.day) {
        return false;
      }
    }
    return true;
  }

  List<DateTime> getAvailableDates() {
    List<DateTime> availableDates = [];
    DateTime today = DateTime.now();
    DateTime date = today.add(Duration(days: 1)); // Start from tomorrow

    while (availableDates.length < 3) {
      // Find the next 3 available dates
      if (date.weekday != DateTime.saturday &&
          date.weekday != DateTime.sunday) {
        availableDates.add(date);
      }
      date = date.add(Duration(days: 1));
    }

    return availableDates;
  }

  List<TimeOfDay> getAvailableTimeSlots(DateTime date) {
    List<TimeOfDay> slots = [];

    // Define start and end times for slot generation based on the day of the week
    TimeOfDay startTime =
        TimeOfDay(hour: 10, minute: 0); // Start time is always 10:00 a.m.
    List<TimeOfDay> endTimes = [
      TimeOfDay(hour: 12, minute: 30)
    ]; // End time for Friday or default first session

    // For Monday to Thursday, add an afternoon session
    if (date.weekday != DateTime.friday) {
      endTimes.add(TimeOfDay(
          hour: 16, minute: 0)); // 4:00 p.m. end time for the second session
    }

    for (TimeOfDay endTime in endTimes) {
      TimeOfDay currentTime = startTime;
      while (currentTime.hour < endTime.hour ||
          (currentTime.hour == endTime.hour &&
              currentTime.minute < endTime.minute)) {
        slots.add(currentTime);
        // Move to the next slot
        DateTime temp = DateTime(date.year, date.month, date.day,
                currentTime.hour, currentTime.minute)
            .add(Duration(minutes: 30));
        currentTime = TimeOfDay(hour: temp.hour, minute: temp.minute);

        // If end of the first session on a weekday, jump to the start of the second session
        if (date.weekday != DateTime.friday &&
            currentTime.hour == 12 &&
            currentTime.minute > 30) {
          currentTime = TimeOfDay(hour: 14, minute: 0); // Restart at 2:00 p.m.
        }
      }
      // Reset start time for the second session if applicable
      if (endTimes.length > 1 && endTime == endTimes.first) {
        startTime = TimeOfDay(
            hour: 14, minute: 0); // 2:00 p.m. start time for the second session
      }
    }

    return slots;
  }
}
