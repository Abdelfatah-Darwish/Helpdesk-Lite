import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class FetchNotifications extends NotificationEvent {}

class MarkNotificationAsRead extends NotificationEvent {
  final String id;

  const MarkNotificationAsRead(this.id);

  @override
  List<Object?> get props => [id];
}

class MarkAllNotificationsAsRead extends NotificationEvent {}

class AddLocalNotification extends NotificationEvent {
  final String ticketId;
  final String message;

  const AddLocalNotification({required this.ticketId, required this.message});

  @override
  List<Object?> get props => [ticketId, message];
}
