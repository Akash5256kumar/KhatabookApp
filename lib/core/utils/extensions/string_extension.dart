/// Shared string and number formatting helpers.
extension StringX on String {
  /// Returns the first two initials from a full name.
  String get initials {
    final List<String> parts = trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return '';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'
        .toUpperCase();
  }

  /// Capitalizes the current value.
  String get capitalize {
    if (isEmpty) {
      return this;
    }
    return '${substring(0, 1).toUpperCase()}${substring(1).toLowerCase()}';
  }
}

extension NullableStringX on String? {
  /// Returns true when the string is null or blank.
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;
}

extension CurrencyX on num {
  /// Formats a number in Indian grouping with the rupee symbol.
  String get toInr => '₹${toIndianGrouping()}';

  /// Formats a number using Indian grouping rules.
  String toIndianGrouping() {
    final String raw = toStringAsFixed(0);
    if (raw.length <= 3) {
      return raw;
    }

    final String lastThree = raw.substring(raw.length - 3);
    final String leading = raw.substring(0, raw.length - 3);
    final StringBuffer buffer = StringBuffer();
    for (int index = 0; index < leading.length; index++) {
      if (index > 0 && (leading.length - index).isEven) {
        buffer.write(',');
      }
      buffer.write(leading[index]);
    }
    return '${buffer.toString()},$lastThree';
  }
}
