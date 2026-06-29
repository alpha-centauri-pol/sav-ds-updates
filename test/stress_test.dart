// Stress-test harness for the sav_ds component library.
//
// This is a SEPARATE diagnostic suite (not part of the normal smoke tests). It
// hammers every component along three axes and prints a machine-readable result
// line per scenario (prefix `STRESS|`) that feeds STRESS_TEST_REPORT.md:
//   1. VOLUME  — hundreds of instances built at once (build-time + controller churn)
//   2. EXTREME — pathological single inputs (huge numbers, 1k-char labels, etc.)
//   3. CHURN   — rapid mount/unmount cycles (surfaces dispose / leak problems)
//
// Run:  flutter test test/stress_test.dart
//
// ignore_for_file: avoid_print, lines_longer_than_80_chars
// ignore_for_file: avoid_positional_boolean_parameters, prefer_const_declarations

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sav_ds/sav_ds.dart';

/// One row of the report.
class _Result {
  _Result(this.scenario, this.detail, this.ms, this.overflow, this.error);
  final String scenario;
  final String detail;
  final int ms;
  final bool overflow;
  final String? error;
}

final List<_Result> _results = [];

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: child),
      ),
    ),
  );
}

/// Pumps [child], records elapsed ms + whether it overflowed / threw.
Future<void> _measure(
  WidgetTester tester,
  String scenario,
  String detail,
  Widget child,
) async {
  final sw = Stopwatch()..start();
  String? error;
  await _pump(tester, child);
  sw.stop();

  // Drain any layout/paint exception (e.g. RenderFlex overflow).
  final ex = tester.takeException();
  var overflow = false;
  if (ex != null) {
    final s = ex.toString();
    overflow = s.contains('overflowed');
    error = s.split('\n').first;
  }
  _results.add(_Result(scenario, detail, sw.elapsedMilliseconds, overflow, error));
}

/// Builds [count] copies of [builder] in a Column (forces every one to build).
Widget _volume(int count, Widget Function(int i) builder) => Column(
  mainAxisSize: MainAxisSize.min,
  children: List.generate(count, builder),
);

void main() {
  const volumeN = 200;
  final longLabel = 'A' * 1000;
  final hugeAmount = '999999999999999.99';

  group('VOLUME — $volumeN instances each', () {
    testWidgets('AppButton x$volumeN', (t) async {
      await _measure(t, 'VOLUME', 'AppButton x$volumeN',
          _volume(volumeN, (i) => AppButton(label: 'Btn $i', onPressed: () {})));
    });
    testWidgets('SavChip x$volumeN', (t) async {
      const tones = SavChipTone.values;
      await _measure(t, 'VOLUME', 'SavChip x$volumeN',
          _volume(volumeN, (i) => SavChip(label: 'Chip $i', tone: tones[i % tones.length])));
    });
    testWidgets('SavBadge x$volumeN', (t) async {
      await _measure(t, 'VOLUME', 'SavBadge x$volumeN',
          _volume(volumeN, (i) => SavBadge(value: '$i')));
    });
    testWidgets('SelectableRow x$volumeN', (t) async {
      await _measure(t, 'VOLUME', 'SelectableRow x$volumeN',
          _volume(volumeN, (i) => SelectableRow(label: 'Row $i', secondary: 'sub $i', selected: i.isEven)));
    });
    testWidgets('InputField x$volumeN', (t) async {
      await _measure(t, 'VOLUME', 'InputField x$volumeN',
          _volume(volumeN, (i) => InputField(label: 'Field $i', placeholder: 'enter $i')));
    });
    testWidgets('OTPInput x$volumeN', (t) async {
      await _measure(t, 'VOLUME', 'OTPInput x$volumeN',
          _volume(volumeN, (i) => const OTPInput()));
    });
    testWidgets('AmountInput x$volumeN', (t) async {
      await _measure(t, 'VOLUME', 'AmountInput x$volumeN',
          _volume(volumeN, (i) => const AmountInput()));
    });
    testWidgets('SegmentedControl x$volumeN', (t) async {
      await _measure(t, 'VOLUME', 'SegmentedControl x$volumeN',
          _volume(volumeN, (i) => SegmentedControl(
                items: const [SegmentedItem(label: 'A'), SegmentedItem(label: 'B')],
                selected: i % 2,
                onChanged: (_) {},
              )));
    });
  });

  group('EXTREME — pathological single inputs', () {
    testWidgets('AppButton 1k-char label', (t) async {
      await _measure(t, 'EXTREME', 'AppButton 1000-char label',
          SizedBox(width: 320, child: AppButton(label: longLabel, onPressed: () {})));
    });
    testWidgets('AmountInput huge value', (t) async {
      final c = TextEditingController(text: hugeAmount);
      await _measure(t, 'EXTREME', 'AmountInput value=$hugeAmount',
          AmountInput(controller: c));
    });
    testWidgets('InputField long label+helper', (t) async {
      await _measure(t, 'EXTREME', 'InputField 1000-char label/helper',
          InputField(label: longLabel, helperText: longLabel, placeholder: longLabel));
    });
    testWidgets('OTPInput length 20', (t) async {
      await _measure(t, 'EXTREME', 'OTPInput length=20',
          const OTPInput(length: 20));
    });
    testWidgets('SegmentedControl 30 items', (t) async {
      await _measure(t, 'EXTREME', 'SegmentedControl 30 items',
          SegmentedControl(
            items: List.generate(30, (i) => SegmentedItem(label: 'Item $i')),
            selected: 0,
            onChanged: (_) {},
          ));
    });
    testWidgets('SavChip 1k-char label', (t) async {
      await _measure(t, 'EXTREME', 'SavChip 1000-char label',
          SizedBox(width: 320, child: SavChip(label: longLabel)));
    });
    testWidgets('SavBadge long value', (t) async {
      await _measure(t, 'EXTREME', 'SavBadge value=9999999',
          const SavBadge(value: '9999999'));
    });
    testWidgets('SelectableRow long label', (t) async {
      await _measure(t, 'EXTREME', 'SelectableRow 1000-char label',
          SelectableRow(label: longLabel, secondary: longLabel));
    });
  });

  group('CHURN — 50x mount/unmount (dispose/leak check)', () {
    Future<void> churn(WidgetTester t, String name, Widget w) async {
      final sw = Stopwatch()..start();
      String? error;
      for (var i = 0; i < 50; i++) {
        await _pump(t, w);
        await _pump(t, const SizedBox.shrink());
      }
      sw.stop();
      final ex = t.takeException();
      if (ex != null) error = ex.toString().split('\n').first;
      _results.add(_Result('CHURN', '$name x50', sw.elapsedMilliseconds, false, error));
    }

    testWidgets('AppButton', (t) async => churn(t, 'AppButton', AppButton(label: 'x', onPressed: () {})));
    testWidgets('OTPInput', (t) async => churn(t, 'OTPInput', const OTPInput()));
    testWidgets('AmountInput', (t) async => churn(t, 'AmountInput', const AmountInput()));
    testWidgets('InputField', (t) async => churn(t, 'InputField', const InputField(label: 'x')));
    testWidgets('SelectableRow', (t) async => churn(t, 'SelectableRow', const SelectableRow(label: 'x')));
    testWidgets('SavChip', (t) async => churn(t, 'SavChip', const SavChip(label: 'x')));
  });

  tearDownAll(() {
    print('\n===== STRESS RESULTS (scenario | detail | ms | overflow | error) =====');
    for (final r in _results) {
      print('STRESS|${r.scenario}|${r.detail}|${r.ms}ms|overflow=${r.overflow}|err=${r.error ?? '-'}');
    }
    print('===== END STRESS RESULTS =====\n');
  });
}
