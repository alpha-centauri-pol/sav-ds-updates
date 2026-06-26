import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sav_ds/sav_ds.dart';

/// Pumps [child] inside a minimal MaterialApp so individual components can be
/// rendered in isolation.
Future<void> pumpComponent(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(home: Scaffold(body: Center(child: child))),
  );
}

void main() {
  group('sav_ds components render', () {
    testWidgets('AppButton', (tester) async {
      var pressed = false;
      await pumpComponent(
        tester,
        AppButton(label: 'Continue', onPressed: () => pressed = true),
      );

      expect(find.byType(AppButton), findsOneWidget);
      // The label renders one Text per glyph via MorphingText.
      expect(find.text('C'), findsOneWidget);

      await tester.tap(find.byType(AppButton));
      expect(pressed, isTrue);
    });

    testWidgets('SavBadge', (tester) async {
      await pumpComponent(tester, const SavBadge(value: '3'));
      expect(find.byType(SavBadge), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('SavChip', (tester) async {
      await pumpComponent(tester, const SavChip(label: 'Instant'));
      expect(find.byType(SavChip), findsOneWidget);
      expect(find.text('Instant'), findsOneWidget);
    });

    testWidgets('SegmentedControl', (tester) async {
      var selected = 0;
      await pumpComponent(
        tester,
        SegmentedControl(
          items: const [
            SegmentedItem(label: 'One'),
            SegmentedItem(label: 'Two'),
          ],
          selected: selected,
          onChanged: (i) => selected = i,
        ),
      );
      expect(find.byType(SegmentedControl), findsOneWidget);
      expect(find.text('One'), findsOneWidget);
      expect(find.text('Two'), findsOneWidget);
    });

    testWidgets('SelectableRow', (tester) async {
      await pumpComponent(
        tester,
        const SelectableRow(label: 'English Language Option'),
      );
      expect(find.byType(SelectableRow), findsOneWidget);
      expect(find.text('English Language Option'), findsOneWidget);
    });

    testWidgets('InputField', (tester) async {
      await pumpComponent(
        tester,
        const InputField(label: 'Email Address'),
      );
      expect(find.byType(InputField), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
    });

    testWidgets('OTPInput', (tester) async {
      await pumpComponent(tester, const OTPInput());
      expect(find.byType(OTPInput), findsOneWidget);
    });

    testWidgets(
      'AmountInput - initial value formatting',
      (tester) async {
        final controller = TextEditingController(text: '2500.00');
        await pumpComponent(
          tester,
          AmountInput(
            controller: controller,
          ),
        );
        expect(find.byType(AmountInput), findsOneWidget);
        expect(controller.text, '2,500.00');
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'AmountInput - automatic comma formatting',
      (tester) async {
        String? changedValue;
        final controller = TextEditingController();
        await pumpComponent(
          tester,
          AmountInput(
            controller: controller,
            onChanged: (val) => changedValue = val,
          ),
        );

        // Focus
        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();

        // Type 1234
        await tester.enterText(find.byType(TextField), '1234');
        await tester.pumpAndSettle();
        expect(controller.text, '1,234');
        expect(changedValue, '1,234');

        // Type 1234567.89
        await tester.enterText(find.byType(TextField), '1234567.89');
        await tester.pumpAndSettle();
        expect(controller.text, '1,234,567.89');
        expect(changedValue, '1,234,567.89');

        // Type "." -> prepends 0.
        await tester.enterText(find.byType(TextField), '.');
        await tester.pumpAndSettle();
        expect(controller.text, '0.');
        expect(changedValue, '0.');

        // Type invalid chars "abc" -> ignored
        await tester.enterText(find.byType(TextField), '12abc3');
        await tester.pumpAndSettle();
        expect(controller.text, '123');
      },
    );

    testWidgets(
      'AmountInput - auto-shrinking text on overflow',
      (tester) async {
        final controller = TextEditingController(text: '123');
        await pumpComponent(
          tester,
          AmountInput(
            controller: controller,
          ),
        );
        await tester.pumpAndSettle();

        // Get the TextField styled font size for short text
        final textFieldWidget1 = tester.widget<TextField>(
          find.byType(TextField),
        );
        final initialFontSize = textFieldWidget1.style!.fontSize;
        expect(initialFontSize, 48.0);

        // Enter a long text that overflows 160px
        await tester.enterText(find.byType(TextField), '1234567890123');
        await tester.pumpAndSettle();

        // Get the TextField styled font size for long text
        final textFieldWidget2 = tester.widget<TextField>(
          find.byType(TextField),
        );
        final scaledFontSize = textFieldWidget2.style!.fontSize;
        expect(scaledFontSize! < 48.0, isTrue);
        expect(scaledFontSize >= 18.0, isTrue);
      },
    );
  });
}
