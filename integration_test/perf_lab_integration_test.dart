import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// Since the Perf Lab is in the example app, we import its main.
import '../example/lib/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Perf Lab Baseline and Delta Integration Test', (WidgetTester tester) async {
    // 1. Launch the example app
    app.main();
    await tester.pumpAndSettle();

    // 2. Open the Global Controls Sheet (FAB)
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pumpAndSettle();

    // 3. Open Perf Lab
    final openPerfLabButton = find.widgetWithText(ElevatedButton, 'Open Perf Lab');
    // Note: AppButton uses MorphingText so find.text might fail. We'll find by the icon instead.
    final openPerfLabIcon = find.byIcon(Icons.speed_rounded);
    expect(openPerfLabIcon, findsOneWidget);
    await tester.tap(openPerfLabIcon);
    await tester.pumpAndSettle();

    // Verify we are on the Perf Lab screen
    expect(find.text('Performance Lab'), findsOneWidget);

    // 4. Set Baseline for AppButton
    final setBaselineKey = find.byKey(const Key('set_baseline_AppButton'));
    expect(setBaselineKey, findsOneWidget);
    
    // Tap to set baseline
    await tester.tap(setBaselineKey);
    // Wait for the test to complete by pumping frames continuously
    for (int i = 0; i < 300; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pumpAndSettle();

    // Verify a baseline is established (should say 'Baseline: X.XX ms')
    expect(find.textContaining('Baseline: '), findsWidgets);

    // 5. Toggle a feature flag (e.g. Drop & Inner Shadows)
    final switchShadows = find.widgetWithText(SwitchListTile, 'Drop & Inner Shadows');
    expect(switchShadows, findsOneWidget);
    await tester.tap(switchShadows);
    await tester.pumpAndSettle();

    // 6. Run Test again to get a Delta
    final runTestKey = find.byKey(const Key('run_test_AppButton'));
    expect(runTestKey, findsOneWidget);
    await tester.tap(runTestKey);
    for (int i = 0; i < 300; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pumpAndSettle();

    // After the second run, we should see a percentage and delta (e.g., '(+0.12 ms, +1.5%)')
    // Look for the '%' character in the result text.
    expect(find.textContaining('%'), findsWidgets);
  });
}
