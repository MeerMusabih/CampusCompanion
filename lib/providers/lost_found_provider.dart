import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/lost_found_model.dart';
import '../services/firestore_service.dart';
class LostFoundProvider with ChangeNotifier {
  final FirestoreService _dbService = FirestoreService();
  List<LostFoundModel> _items = [];
  bool _isLoading = false;
  List<LostFoundModel> get items => _items;
  bool get isLoading => _isLoading;
  void fetchItems() {
    _isLoading = true;
    _dbService.getLostFoundItems().listen(
      (itemList) {
        _items = itemList;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        notifyListeners();
        debugPrint("Supabase Stream Error: $error");
      },
    );
  }
  Future<void> addItem(LostFoundModel item, Uint8List imageBytes, String fileName) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _dbService.uploadLostFoundItem(item, imageBytes, fileName);
    } catch (e) {
      debugPrint("Add Item Error: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  int get itemCount => _items.length;
  Future<void> markAsResolved(String itemId) async {
    try {
      await _dbService.updateItemStatus(itemId, true);
    } catch (e) {
      debugPrint("Update Status Error: $e");
    }
  }
}
