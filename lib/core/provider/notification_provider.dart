import 'package:flutter/material.dart';

import '../../data/models/notification_model.dart';
import '../../data/service/notification_service.dart';


class NotificationProvider with ChangeNotifier {
  final NotificationService _service;
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  NotificationProvider(this._service);

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await _service.getUserNotifications();
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _service.markAsRead(notificationId);
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final unreadIds = _notifications
          .where((n) => !n.isRead)
          .map((n) => n.id)
          .toList();

      for (final id in unreadIds) {
        await _service.markAsRead(id);
      }

      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }
}