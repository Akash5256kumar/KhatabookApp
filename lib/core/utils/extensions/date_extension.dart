const List<String> _monthShortNames = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Date formatting helpers without extra package dependencies.
extension DateTimeX on DateTime {
  /// Formats to `dd MMM yyyy`.
  String get displayDate {
    return '${day.toString().padLeft(2, '0')} '
        '${_monthShortNames[month - 1]} $year';
  }

  /// Formats to `dd MMM yyyy, hh:mm a`.
  String get displayDateTime => '$displayDate, $displayTime';

  /// Formats to `hh:mm a`.
  String get displayTime {
    final int normalizedHour = hour == 0 ? 12 : hour > 12 ? hour - 12 : hour;
    final String suffix = hour >= 12 ? 'PM' : 'AM';
    return '${normalizedHour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')} $suffix';
  }

  /// Formats to `Today`, `Yesterday`, or `dd MMM yyyy`.
  String get relativeLabel {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime current = DateTime(year, month, day);
    final int difference = today.difference(current).inDays;
    if (difference == 0) {
      return 'Today';
    }
    if (difference == 1) {
      return 'Yesterday';
    }
    return displayDate;
  }
}
