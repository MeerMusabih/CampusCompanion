import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/firestore_service.dart';
import 'dart:async';
class NotificationProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<NotificationModel> _notifications = [];
  StreamSubscription? _subscription;
  String? _currentUserId;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void loadNotifications(String userId) {
    if (_currentUserId == userId) return;
    _currentUserId = userId;
    _subscription?.cancel();
    _subscription = _firestoreService.getNotifications(userId).listen((data) {
      _notifications = data;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> markAsRead(String id) async {
    if (_currentUserId == null) return;
    await _firestoreService.markNotificationAsRead(_currentUserId!, id);
  }

  Future<void> markAllAsRead() async {
    if (_currentUserId == null) return;
    await _firestoreService.markAllNotificationsAsRead(_currentUserId!);
  }

  Future<void> clearNotifications() async {
    if (_currentUserId == null) return;
    await _firestoreService.clearNotifications(_currentUserId!);
  }
  
}
