import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
class StorageService {
  final _supabase = Supabase.instance.client;
  Future<String?> uploadItemImage(File file) async {
    final fileName = 'lost-found/${DateTime.now().millisecondsSinceEpoch}.jpg';
    try {
      await _supabase.storage.from('images').upload(fileName, file);
      return _supabase.storage.from('images').getPublicUrl(fileName);
    } catch (e) {
      print("Upload Error: $e");
      return null;
    }
  }
}
