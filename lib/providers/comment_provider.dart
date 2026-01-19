import 'package:flutter/material.dart';
import '../models/comment_model.dart';
import '../services/firestore_service.dart';
import 'dart:async';

class CommentProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final Map<String, List<CommentModel>> _noticeComments = {};
  final Map<String, StreamSubscription?> _subscriptions = {};

  List<CommentModel> getCommentsForNotice(String noticeId) {
    return _noticeComments[noticeId] ?? [];
  }

  List<CommentModel> getCommentsForForumPost(String postId) {
    return _noticeComments[postId] ?? [];
  }

  void listenToComments(String noticeId) {
    if (_subscriptions.containsKey(noticeId)) return;

    _subscriptions[noticeId] = _firestoreService.getComments(noticeId).listen((comments) {
      _noticeComments[noticeId] = comments;
      notifyListeners();
    });
  }

  void listenToForumComments(String postId) {
    if (_subscriptions.containsKey(postId)) return;

    _subscriptions[postId] = _firestoreService.getForumComments(postId).listen((comments) {
      _noticeComments[postId] = comments;
      notifyListeners();
    });
  }

  Future<void> addComment(String noticeId, CommentModel comment) async {
    try {
      await _firestoreService.addComment(noticeId, comment);
    } catch (e) {
      debugPrint("Error adding comment: $e");
      rethrow;
    }
  }

  Future<void> addForumComment(String postId, CommentModel comment) async {
    try {
      await _firestoreService.addForumComment(postId, comment);
    } catch (e) {
      debugPrint("Error adding forum comment: $e");
      rethrow;
    }
  }

  @override
  void dispose() {
    for (var sub in _subscriptions.values) {
      sub?.cancel();
    }
    super.dispose();
  }
}
