import 'package:intl/intl.dart';

class Message {
  final String text;
  final bool isMe;
  final DateTime time;
  final bool isSystem;

  Message({
    required this.text,
    required this.isMe,
    required this.time,
    this.isSystem = false,
  });

  String get formattedTime => DateFormat('HH:mm').format(time);
}