// This is a basic Flutter widget test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic app test', (WidgetTester tester) async {
    // Just a placeholder test
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Momentum')),
        ),
      ),
    );

    expect(find.text('Momentum'), findsOneWidget);
  });
}
