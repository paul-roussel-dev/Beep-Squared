// This is a basic Flutter widget test for Beep Squared alarm app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:beep_squared/main.dart';

void main() {
  testWidgets('Beep Squared app launches smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BeepSquaredApp());

    // Verify that our app title is displayed.
    expect(find.text('Beep Squared'), findsOneWidget);
    
    // Pump a few frames to allow initial loading
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    
    // Verify that either loading indicator or content is displayed
    expect(
      find.byType(CircularProgressIndicator).evaluate().isNotEmpty || 
      find.text('No alarms set').evaluate().isNotEmpty ||
      find.text('Tap the + button to add your first alarm').evaluate().isNotEmpty,
      isTrue,
    );

    // Verify that the add alarm button is present.
    expect(find.byIcon(Icons.add), findsOneWidget);

    // Simple smoke test - just verify the app launches without crashing
    // and basic UI elements are present
  });
  
  testWidgets('Add alarm button is tappable', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BeepSquaredApp());
    
    // Pump to render
    await tester.pump();
    
    // Verify that the add alarm button is present and tappable.
    final addButton = find.byIcon(Icons.add);
    expect(addButton, findsOneWidget);
    
    // Test that tapping doesn't crash (basic interaction test)
    await tester.tap(addButton);
    await tester.pump();
    
    // The test passes if no exception is thrown
  });
}
