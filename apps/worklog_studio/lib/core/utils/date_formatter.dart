import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }
}
