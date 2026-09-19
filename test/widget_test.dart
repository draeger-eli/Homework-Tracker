// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homework_tracker/views/main_navigation.dart';

void main() {
  testWidgets('Navigation opens assignments and courses', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: MainNavigationScreen()),
    );

    expect(find.text('Welcome to Homework Tracker!'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.list));
    await tester.pumpAndSettle();

    expect(find.text('Assignments'), findsNWidgets(2));
    expect(find.byType(FloatingActionButton), findsOneWidget);

    await tester.tap(find.byIcon(Icons.book));
    await tester.pumpAndSettle();

    expect(find.text('Courses'), findsNWidgets(2));
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}