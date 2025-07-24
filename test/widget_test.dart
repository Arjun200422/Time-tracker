import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/main.dart';
import 'package:time_tracker/providers/time_entry_provider.dart';

void main() {
  testWidgets('Home screen shows empty state and Add Entry button', (WidgetTester tester) async {
    // Build the app with the provider
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => TimeEntryProvider(),
        child: const MyApp(),
      ),
    );

    // Wait for provider to initialize
    await tester.pumpAndSettle();

    // Check for empty state message
    expect(find.text('No time entries yet!'), findsOneWidget);

    // Check for Add Entry button
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('Add Entry'), findsOneWidget);

    // Tap the Add Entry button
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Should navigate to Add Time Entry screen
    expect(find.text('Add Time Entry'), findsOneWidget);
  });
}
