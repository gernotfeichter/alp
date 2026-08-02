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

    // Enter Key "123"
    await tester.enterText(keyField, '123');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // Find PBKDF2 Iterations field
    // It's the second TextFormField based on the UI structure
    final iterationsField = find.byType(TextFormField).at(1);
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

    // Final wait to ensure changes are persisted (secure storage is async)
    await Future.delayed(const Duration(seconds: 2));
  });
}
