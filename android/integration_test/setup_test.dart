import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:alp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Configure alp app settings', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Find the Key field
    final keyField = find.byType(TextFormField).first;
    expect(keyField, findsOneWidget);

    // Enter Key "123" - ensure we trigger onChanged by changing it first if needed
    await tester.enterText(keyField, 'temp_key');
    await tester.pump();
    await tester.enterText(keyField, '123');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // Find PBKDF2 Iterations field
    // It's the second TextFormField based on the UI structure
    final iterationsField = find.byType(TextFormField).at(1);
    await tester.enterText(iterationsField, '999');
    await tester.pump();
    await tester.enterText(iterationsField, '150');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // Ensure Lazy Auth Mode is OFF
    final lazyAuthSwitch = find.byType(Switch);
    expect(lazyAuthSwitch, findsOneWidget);

    final Switch switchWidget = tester.widget(lazyAuthSwitch);
    if (switchWidget.value) {
      await tester.tap(lazyAuthSwitch);
      await tester.pumpAndSettle();
    }

    // Verify values
    expect(find.text('123'), findsOneWidget);
    expect(find.text('150'), findsOneWidget);

    // Verify Restart Required message is visible
    // We might need a few pumps for Riverpod to propagate the state
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.textContaining('Restart required'), findsOneWidget);

    // Tap Restart Background Service
    final restartTile = find.textContaining('Restart Background Service');
    await tester.tap(restartTile);
    await tester.pumpAndSettle();

    // Verify Restart Required message is gone
    await Future.delayed(const Duration(seconds: 1)); // Wait for restart
    await tester.pumpAndSettle();
    expect(find.textContaining('up to date'), findsOneWidget);

    // Final wait to ensure changes are persisted (secure storage is async)
    await Future.delayed(const Duration(seconds: 2));
    // ignore: avoid_print
    print('SETUP_DONE');

    // Periodically log heartbeat to keep listener alive and show it's still running
    Timer.periodic(const Duration(seconds: 10), (timer) {
      // ignore: avoid_print
      print('HEARTBEAT');
    });

    // Keep the app running and installed for the rest of the E2E test
    // The E2E script will kill this process when done.
    await Future.delayed(const Duration(minutes: 10));
  });
}
