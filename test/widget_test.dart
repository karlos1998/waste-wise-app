// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:waste_wise_app/main.dart';

void main() {
  testWidgets('App builds without errors', (WidgetTester tester) async {
    // Load environment variables for testing
    await dotenv.load(fileName: '.env');

    // Build our app and trigger a frame.
    await tester.pumpWidget(const WasteWiseApp());

    // Verify that the login screen is shown initially
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Hasło'), findsOneWidget);
    expect(find.text('Zaloguj się'), findsOneWidget);
  });
}
