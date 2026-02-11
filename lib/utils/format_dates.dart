import 'package:intl/intl.dart';

class FormatDates {
  static String show(String date) {
    final formatter = DateFormat('EEE, d MMM yyyy HH:mm');
    final dateTime = formatter.parse(date);
    return DateFormat('d/MM/yyyy - HH:mm').format(dateTime);
  }

  static DateTime toDate(String date) {
    final formatter = DateFormat('EEE, d MMM yyyy HH:mm');
    return formatter.parse(date);
  }
}