import 'package:flutter/material.dart';
import '../../models/notice_model.dart';
import '../../services/firestore_service.dart';
import 'dart:async';

class NoticeProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<NoticeModel> _notices = [];
  bool _isLoading = false;
  StreamSubscription? _subscription;

  List<NoticeModel> get notices => _notices;
  bool get isLoading => _isLoading;

  NoticeProvider() {
    initNotices();
    _firestoreService.syncAllCommentCounts(); // Sync data in background
  }

  void initNotices() {
    _subscription?.cancel();
    _setLoading(true);
    _subscription = _firestoreService.getNotices().listen((notices) {
      _notices = notices;
      _notices.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _setLoading(false);
    }, onError: (e) {
      debugPrint("Error listening to notices: $e");
      _setLoading(false);
    });
  }

  Future<void> fetchNotices() async {
    initNotices();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> toggleLike(String noticeId, String userId) async {
    try {
      await _firestoreService.toggleLikeNotice(noticeId, userId);
    } catch (e) {
      debugPrint("Error toggling like: $e");
    }
  }

  Future<void> toggleBookmark(String noticeId, String userId) async {
    try {
      await _firestoreService.toggleBookmarkNotice(noticeId, userId);
    } catch (e) {
      debugPrint("Error toggling bookmark: $e");
    }
  }

  Future<void> addNotice(NoticeModel notice) async {
    try {
      await _firestoreService.addNotice(notice);
    } catch (e) {
      debugPrint("Error adding notice: $e");
      rethrow;
    }
  }

  Future<void> deleteNotice(String id) async {
    try {
      await _firestoreService.deleteNotice(id);
    } catch (e) {
      debugPrint("Error deleting notice: $e");
      rethrow;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
