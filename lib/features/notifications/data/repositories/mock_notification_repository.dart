import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/notification_model.dart';

class MockNotificationRepository implements NotificationRepository {
  final SharedPreferences sharedPreferences;
  static const String _notifCacheKey = 'CACHED_NOTIFICATIONS';

  MockNotificationRepository({required this.sharedPreferences}) {
    _initDefaultNotifications();
  }

  Future<void> _initDefaultNotifications() async {
    if (!sharedPreferences.containsKey(_notifCacheKey)) {
      final now = DateTime.now();
      final defaultNotifs = [
        NotificationModel(
          id: 'n-1',
          ticketId: 'TICK-101',
          message: 'Your VPN connection issues on Macbook ticket has been assigned to Bob Smith.',
          createdAt: now.subtract(const Duration(days: 1)),
          isRead: false,
        ),
        NotificationModel(
          id: 'n-2',
          ticketId: 'TICK-103',
          message: 'Your March Travel Reimbursement Delay ticket has been marked as Resolved.',
          createdAt: now.subtract(const Duration(days: 2)),
          isRead: true,
        ),
        NotificationModel(
          id: 'n-3',
          ticketId: 'TICK-105',
          message: 'New Urgent ticket submitted by Charlie Brown: MacBook Pro Battery Swollen.',
          createdAt: now.subtract(const Duration(hours: 4)),
          isRead: false,
        )
      ];
      await _saveNotifications(defaultNotifs);
    }
  }

  Future<List<NotificationModel>> _getCachedNotifications() async {
    final cachedString = sharedPreferences.getString(_notifCacheKey);
    if (cachedString == null) return [];
    try {
      final decoded = json.decode(cachedString) as List<dynamic>;
      return decoded.map((item) => NotificationModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveNotifications(List<NotificationModel> list) async {
    final encoded = json.encode(list.map((n) => n.toJson()).toList());
    await sharedPreferences.setString(_notifCacheKey, encoded);
  }

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final notifs = await _getCachedNotifications();
    notifs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notifs;
  }

  @override
  Future<void> markAsRead(String id) async {
    final list = await _getCachedNotifications();
    final idx = list.indexWhere((n) => n.id == id);
    if (idx != -1) {
      list[idx] = NotificationModel.fromEntity(list[idx].copyWith(isRead: true));
      await _saveNotifications(list);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    final list = await _getCachedNotifications();
    final updated = list.map((n) => NotificationModel.fromEntity(n.copyWith(isRead: true))).toList();
    await _saveNotifications(updated);
  }

  @override
  Future<void> createNotification({required String ticketId, required String message}) async {
    final list = await _getCachedNotifications();
    final nextId = 'n-${DateTime.now().millisecondsSinceEpoch}';
    final newNotif = NotificationModel(
      id: nextId,
      ticketId: ticketId,
      message: message,
      createdAt: DateTime.now(),
      isRead: false,
    );
    list.insert(0, newNotif);
    await _saveNotifications(list);
  }
}
