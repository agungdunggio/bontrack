import 'package:intl/intl.dart';

class DateFormatter {
  static DateFormat get shortDate {
    return DateFormat('dd MMM yyyy', 'id_ID');
  }

  static String formatShortDate(DateTime date) {
    return shortDate.format(date);
  }
}
