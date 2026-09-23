import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homework_tracker/views/login_screen.dart';
import 'package:homework_tracker/views/signup_screen.dart';

void main() {
  testWidgets('Login shows validation and opens signup', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter your email.'), findsOneWidget);
    await tester.tap(find.text("Don't have an account? Sign up"));
    await tester.pumpAndSettle();
    expect(find.byType(SignupScreen), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
    final fields = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList();
    expect(fields[1].obscureText, isTrue);
    expect(fields[2].obscureText, isTrue);
  });

  testWidgets('Signup rejects mismatched and short passwords', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignupScreen()));
    await tester.enterText(find.byType(TextField).at(0), 'student@example.com');
    await tester.enterText(find.byType(TextField).at(1), '123456');
    await tester.enterText(find.byType(TextField).at(2), '654321');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
    await tester.pumpAndSettle();
    expect(find.text('Passwords do not match.'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(1), '12345');
    await tester.enterText(find.byType(TextField).at(2), '12345');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
    await tester.pumpAndSettle();
    expect(
      find.text('Password must be at least 6 characters.'),
      findsOneWidget,
    );
  });
}
