bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

List<DateTime> getWeekDates(DateTime startOfWeek) =>
    List.generate(7, (i) => startOfWeek.add(Duration(days: i)));