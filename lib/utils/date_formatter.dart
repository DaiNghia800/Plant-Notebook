class DateFormatter {
  static String formatNextActionDate(DateTime nextDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final nextDay = DateTime(nextDate.year, nextDate.month, nextDate.day);

    if (nextDay == today) {
      return 'Hôm nay, ${nextDate.day}/${nextDate.month}';
    } else if (nextDay == tomorrow) {
      return 'Ngày mai, ${nextDate.day}/${nextDate.month}';
    } else if (nextDay.isBefore(today)) {
      return 'Quá hạn từ ${nextDate.day}/${nextDate.month}';
    } else {
      final daysLeft = nextDate.difference(now).inDays;
      return 'Còn $daysLeft ngày (${nextDate.day}/${nextDate.month})';
    }
  }
}
