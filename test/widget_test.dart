import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sav_ds/main.dart';
import 'package:sav_ds/components/app_button.dart';
import 'package:sav_ds/components/input_field.dart';
import 'package:sav_ds/components/otp_input.dart';
import 'package:sav_ds/components/amount_input.dart';
import 'package:sav_ds/components/segmented_control.dart';
import 'package:sav_ds/components/selectable_row.dart';
import 'package:sav_ds/components/badge.dart';
import 'package:sav_ds/components/sav_chip.dart';
void main() {
  testWidgets('Design system gallery navigation and rendering test', (tester) async {
    // 1. Render Gallery
    await tester.pumpWidget(const SavApp());
    await tester.pump();

    // Verify Tab 1 (Buttons) renders
    expect(find.byType(AppButton), findsWidgets);
    expect(find.text('Preview Button'), findsOneWidget);
    expect(find.text('Normal'), findsOneWidget);
    expect(find.text('Loading'), findsOneWidget);

    // 2. Navigate to Tab 2 (Inputs)
    await tester.tap(find.byIcon(Icons.input_rounded));
    await tester.pump();

    // Verify Tab 2 components
    expect(find.byType(InputField), findsWidgets);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.byType(OTPInput), findsWidgets);
    expect(find.byType(AmountInput), findsWidgets);
    expect(find.text('Gold Standard Intent:'), findsOneWidget);

    // 3. Navigate to Tab 3 (Controls)
    await tester.tap(find.byIcon(Icons.toggle_on_rounded));
    await tester.pump();

    // Verify Tab 3 components
    expect(find.byType(SegmentedControl), findsWidgets);
    expect(find.byType(SelectableRow), findsWidgets);
    expect(find.text('United Arab Emirates'), findsOneWidget);
    expect(find.text('English Language Option'), findsOneWidget);

    // 4. Navigate to Tab 4 (Indicators)
    await tester.tap(find.byIcon(Icons.label_important_rounded));
    await tester.pump();

    // Verify Tab 4 components
    expect(find.byType(SavBadge), findsWidgets);
    expect(find.byType(SavChip), findsWidgets);
    expect(find.text('Instant'), findsOneWidget);
    expect(find.text('Coming Soon'), findsOneWidget);
    expect(find.text('Overdue'), findsOneWidget);
  });
}
