import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;

  NotificationBloc({required this.repository}) : super(const NotificationState()) {
    on<FetchNotifications>(_onFetchNotifications);
    on<MarkNotificationAsRead>(_onMarkAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllAsRead);
    on<AddLocalNotification>(_onAddLocalNotification);
  }

  Future<void> _onFetchNotifications(
    FetchNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final list = await repository.getNotifications();
      final unread = list.where((n) => !n.isRead).length;
      emit(state.copyWith(
        isLoading: false,
        notifications: list,
        unreadCount: unread,
      ));
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onMarkAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await repository.markAsRead(event.id);
      add(FetchNotifications());
    } catch (_) {}
  }

  Future<void> _onMarkAllAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await repository.markAllAsRead();
      add(FetchNotifications());
    } catch (_) {}
  }

  Future<void> _onAddLocalNotification(
    AddLocalNotification event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await repository.createNotification(
        ticketId: event.ticketId,
        message: event.message,
      );
      add(FetchNotifications());
    } catch (_) {}
  }
}
