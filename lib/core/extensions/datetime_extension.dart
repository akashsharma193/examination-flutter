import 'package:intl/intl.dart';

extension AppDateTimeExtension on DateTime {
  String get formatTime {
    return DateFormat('hh:mm a, dd MMMM').format(this);
  }
}
