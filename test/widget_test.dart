import 'package:flutter_test/flutter_test.dart';
import 'package:mad_project/main.dart';
import 'package:mad_project/screens/auth/login_screen.dart';

void main() {
  testWidgets('App should show Login Screen on startup', (
    WidgetTester tester,
  ) async {
    // Note: In a real environment, you would 'mock' Firebase here.
    // This is a simplified smoke test.
    await tester.pumpWidget(const CampusCompanionApp());

    // Verify that the Login Screen is the first thing the user sees
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Login'), findsWidgets);
  });
}
