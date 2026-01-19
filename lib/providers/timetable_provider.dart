import 'package:flutter/material.dart';
import '../models/timetable_model.dart';
import '../services/firestore_service.dart';
class TimetableProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<TimetableModel> _entries = [];
  bool _isLoading = true;
  List<TimetableModel> get entries => _entries;
  bool get isLoading => _isLoading;
  TimetableProvider() {
    _fetchTimetable();
  }
  void _fetchTimetable() {
    _firestoreService.getTimetable().listen((data) {
      _entries = data;
      _isLoading = false;
      notifyListeners();
    });
  }
  List<TimetableModel> getFilteredEntries({
    required String day,
    String? department,
    String? semester,
    String? section,
  }) {
    return _entries.where((e) {
      final matchesDay = e.day == day;
      final matchesDept = department == null || department == 'All' || e.department == department;
      final matchesSem = semester == null || semester == 'All' || e.semester == semester;
      final matchesSec = section == null || section == 'All' || e.section == section;
      return matchesDay && matchesDept && matchesSem && matchesSec;
    }).toList();
  }
  Future<void> addEntry(TimetableModel entry) async {
    await _firestoreService.addTimetableEntry(entry);
  }
  Future<void> deleteEntry(String id) async {
    await _firestoreService.deleteTimetableEntry(id);
  }
}
