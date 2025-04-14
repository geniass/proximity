import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  return DateFormat('E, d MMMM yyyy').format(date);
}
