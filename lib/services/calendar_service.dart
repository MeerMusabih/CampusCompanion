import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import '../models/event_model.dart';

class CalendarService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '150618385515-edia08q1fh0h86ij38c5iqkrqo0f518s.apps.googleusercontent.com',
    scopes: [
      cal.CalendarApi.calendarEventsScope,
    ],
  );

  /// Signs in the user and adds the event to their primary Google Calendar.
  Future<bool> addToGoogleCalendar(EventModel event) async {
    try {
      debugPrint('📅 CalendarService: Requesting Google Sign-In...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        debugPrint('📅 CalendarService: User cancelled sign-in');
        return false;
      }

      final httpClient = (await _googleSignIn.authenticatedClient())!;
      final calendarApi = cal.CalendarApi(httpClient);

      final calEvent = cal.Event()
        ..summary = event.title
        ..description = event.description
        ..location = event.location
        ..start = (cal.EventDateTime()
          ..dateTime = event.dateTime
          ..timeZone = DateTime.now().timeZoneName)
        ..end = (cal.EventDateTime()
          ..dateTime = event.dateTime.add(const Duration(hours: 2)) // Default 2 hours
          ..timeZone = DateTime.now().timeZoneName);

      debugPrint('📅 CalendarService: Creating event in primary calendar...');
      await calendarApi.events.insert(calEvent, 'primary');
      
      debugPrint('✅ CalendarService: Event added successfully!');
      return true;
    } catch (e) {
      debugPrint('❌ CalendarService Error: $e');
      rethrow;
    }
  }

  /// Optional: Sign out from Google (if needed specifically for calendar)
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
