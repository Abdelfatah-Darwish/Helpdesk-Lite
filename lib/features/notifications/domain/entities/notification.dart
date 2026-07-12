import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String ticketId;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  const NotificationEntity({
    required this.id,
    required this.ticketId,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });

  NotificationEntity copyWith({
    bool? isRead,
  }) {
    return NotificationEntity(
      id: id,
      ticketId: ticketId,
      message: message,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [id, ticketId, message, createdAt, isRead];
}
