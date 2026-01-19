import 'package:flutter/material.dart';
import '../models/forum_post_model.dart';
import '../services/firestore_service.dart';
class ForumProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<ForumPostModel> _posts = [];
  bool _isLoading = false;
  List<ForumPostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  ForumProvider() {
    _init();
  }
  void _init() {
    _isLoading = true;
    notifyListeners();
    _firestoreService.syncForumCounts(); // Calibrate counts
    try {
        _firestoreService.getForumPosts().listen((posts) {
        _posts = posts;
        _isLoading = false;
        notifyListeners();
        });
    } catch (e) {
        _isLoading = false; 
        notifyListeners();
    }
  }
  Future<void> addPost(String title, String content, String authorName, String authorId, String category) async {
    final post = ForumPostModel(
      id: '', 
      authorName: authorName,
      authorId: authorId,
      title: title,
      content: content,
      timestamp: DateTime.now(),
      category: category,
      likes: 0,
      comments: 0,
    );
    await _firestoreService.addForumPost(post);
  }

  Future<void> toggleLike(String postId, String userId) async {
    try {
      await _firestoreService.toggleForumPostLike(postId, userId);
    } catch (e) {
      debugPrint("Error toggling like: $e");
    }
  }

  Future<void> toggleBookmark(String postId, String userId) async {
    try {
      await _firestoreService.toggleBookmarkForumPost(postId, userId);
    } catch (e) {
      debugPrint("Error toggling bookmark: $e");
    }
  }
}
