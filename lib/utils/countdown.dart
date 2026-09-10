import 'package:intl/intl.dart';

String countdownLabel(DateTime dateTime, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final today = DateTime(current.year, current.month, current.day);
  final day = DateTime(dateTime.year, dateTime.month, dateTime.day);
  final days = day.difference(today).inDays;
  final timeStr = DateFormat('HH:mm').format(dateTime);

  if (days < 0) return 'Sudah lewat';
  if (days == 0) return 'Hari ini, $timeStr';
  if (days == 1) return 'Besok, $timeStr';
  if (days == 2) return 'Lusa, $timeStr';
  return 'H-$days lagi, $timeStr';
}

String countdownShortLabel(DateTime dateTime, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final today = DateTime(current.year, current.month, current.day);
  final day = DateTime(dateTime.year, dateTime.month, dateTime.day);
  final days = day.difference(today).inDays;

  if (days < 0) return 'Lewat';
  if (days == 0) return 'Hari ini';
  if (days == 1) return 'H-1';
  if (days == 2) return 'H-2';
  return 'H-$days';
}