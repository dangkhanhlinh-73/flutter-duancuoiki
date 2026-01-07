import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_moviex_app/main.dart';

void main() {
  testWidgets('LoginPage displays MovieX title and input fields', (
    WidgetTester tester,
  ) async {
    // Build our app
    await tester.pumpWidget(const MyApp());

    // Verify that the app title "MovieX" is displayed
    expect(find.text('MovieX'), findsOneWidget);

    // Verify that the email TextField exists
    expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);

    // Verify that the password TextField exists
    expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);

    // Verify that the phone number TextField exists
    expect(find.widgetWithText(TextField, 'Phone Number'), findsOneWidget);

    // Verify that the verification code TextField exists
    expect(find.widgetWithText(TextField, 'Code'), findsOneWidget);

    // Verify login buttons exist
    expect(find.text('Login Email'), findsOneWidget);
    expect(find.text('Google Sign-In'), findsOneWidget);
    expect(find.text('Send Code'), findsOneWidget);
    expect(find.text('Verify & Login'), findsOneWidget);
  });
}
