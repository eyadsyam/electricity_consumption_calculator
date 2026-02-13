import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  @override
  List<Object?> get props => [id, title, message, timestamp, isRead];
}
