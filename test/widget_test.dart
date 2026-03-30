import 'package:cs310_app/src/features/auth/presentation/pages/landing_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Landing page shows auth entry points', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LandingPage()));

    expect(find.text('CS310 Security Trainer'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
  });
}
