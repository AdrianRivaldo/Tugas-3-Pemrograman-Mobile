class CurrencyHelper {
  /// Format angka menjadi Rupiah: Rp 150.000
  static String format(double amount) {
    final int value = amount.round();
    final bool isNegative = value < 0;
    final String absoluteValue = value.abs().toString();
    final String formatted = _addThousandSeparator(absoluteValue);
    return '${isNegative ? '-' : ''}Rp $formatted';
  }

  /// Tambahkan separator titik setiap 3 digit
  static String _addThousandSeparator(String number) {
    if (number.length <= 3) return number;
    final StringBuffer buffer = StringBuffer();
    final int length = number.length;
    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(number[i]);
    }
    return buffer.toString();
  }

  /// Format dengan tanda minus untuk diskon
  static String formatDiscount(double amount) {
    return '-${format(amount).replaceFirst('Rp ', '')}';
  }
}
