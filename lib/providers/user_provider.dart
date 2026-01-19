import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
class UserProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  UserModel? _currentUser;
  bool _isLoading = false;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  Future<void> fetchUserDetails(String uid) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _firestoreService.getUser(uid);
    } catch (e) {
      debugPrint("Error fetching user profile: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<bool> updateUserProfile(UserModel updatedUser) async {
    try {
      await _firestoreService.saveUser(updatedUser);
      _currentUser = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error updating profile: $e");
      return false;
    }
  }
  int _usersCount = 0;
  int get usersCount => _usersCount;
  Future<void> fetchUsersCount() async {
    try {
      _usersCount = await _firestoreService.getUsersCount();
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching users count: $e");
    }
  }
  void clearUser() {
    _currentUser = null;
    _usersCount = 0;
    _forumPostsCount = 0;
    _lostFoundCount = 0;
    notifyListeners();
  }

  int _forumPostsCount = 0;
  int _lostFoundCount = 0;
  int get forumPostsCount => _forumPostsCount;
  int get lostFoundCount => _lostFoundCount;

  Future<void> fetchUserStats(String userId) async {
    try {
      _forumPostsCount = await _firestoreService.getUserForumPostsCount(userId);
      _lostFoundCount = await _firestoreService.getUserLostFoundCount(userId);
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching user stats: $e");
    }
  }
}
