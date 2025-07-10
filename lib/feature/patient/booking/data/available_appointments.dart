List<int> getAvailableAppointments(
  DateTime selectedDate,
  String startHour,
  String endHour,
) {
  // To change the time format from arabic (9:00 م) to 24-hour (21) format in firestore
  int parseArabicTimeToHour(String timeStr) {
    final parts = timeStr.trim().split(' ');
    final time = parts[0];
    final period = parts[1];

    final hourMinute = time.split(':');
    int hour = int.parse(hourMinute[0]);
    if (period == 'م' && hour != 12) {
      hour += 12;
    } else if (period == 'ص' && hour == 12) {
      hour = 0;
    }
    return hour;
  }

  int endHourFormated = parseArabicTimeToHour(endHour);
  int startHourFormated = parseArabicTimeToHour(startHour);
  List<int> availableHours=[];
  DateTime now = DateTime.now();
  for (int i = startHourFormated; i < endHourFormated; i++) {
    bool isSameDay =
        selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
        // If it's not the same day or it is but the hour hasn't passed already:
        if (!isSameDay || i > now.hour) {
          availableHours.add(i);
        }
  }
  return availableHours;
}
