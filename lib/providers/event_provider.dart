import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/firestore_service.dart';
class EventProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<EventModel> _events = [];
  bool _isLoading = false;
  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;
  Future<void> fetchEvents() async {
    _isLoading = true;
    notifyListeners();
    _firestoreService.getEvents().listen((eventList) {
      _events = eventList;
      _isLoading = false;
      notifyListeners();
    });
  }
  Future<void> toggleRegistration(String eventId, String userId) async {
    try {
      final index = _events.indexWhere((e) => e.id == eventId);
      if (index == -1) return;
      List<String> registrations = List.from(_events[index].registeredUsers);
      if (registrations.contains(userId)) {
        registrations.remove(userId); 
      } else {
        registrations.add(userId); 
      }
      await _firestoreService.updateEventRegistrations(eventId, registrations);
    } catch (e) {
      debugPrint("Error toggling registration: $e");
    }
  }

  Future<void> addEvent(EventModel event) async {
    await _firestoreService.addEvent(event);
  }

  Future<void> deleteEvent(String id) async {
    await _firestoreService.deleteEvent(id);
  }
}
