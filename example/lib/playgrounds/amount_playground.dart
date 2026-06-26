import 'package:flutter/material.dart';
import 'package:sav_ds/sav_ds.dart';
import '../playground.dart';

class AmountPlayground extends StatefulWidget {
  const AmountPlayground({super.key});
  @override
  State<AmountPlayground> createState() => _AmountPlaygroundState();
}

class _AmountPlaygroundState extends State<AmountPlayground> {
  String _currency = 'AED';
  AmountInputIntent _intent = AmountInputIntent.purple;
  AmountInputState _state = AmountInputState.normal;
  String _nudge = '';
  String _helper = '';

  @override
  Widget build(BuildContext context) {
    final buffer = StringBuffer('AmountInput(\n');
    if (_currency != 'AED') buffer.writeln("  currency: '$_currency',");
    if (_intent != AmountInputIntent.purple) {
      buffer.writeln('  intent: AmountInputIntent.${_intent.name},');
    }
    if (_state != AmountInputState.normal) {
      buffer.writeln('  state: AmountInputState.${_state.name},');
    }
    if (_nudge.isNotEmpty) buffer.writeln("  nudgeText: '$_nudge',");
    if (_helper.isNotEmpty) buffer.writeln("  helperText: '$_helper',");
    buffer
      ..writeln('  onChanged: (val) {},')
      ..write(')');

    return PlaygroundStage(
      id: 'AmountInput',
      preview: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AmountInput(
            currency: _currency,
            intent: _intent,
            state: _state,
            nudgeText: _nudge.isNotEmpty ? _nudge : null,
            helperText: _helper.isNotEmpty ? _helper : null,
            onChanged: (_) {},
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Confirm Transfer',
            variant: AppButtonVariant.primary,
            onPressed: () {},
          ),
        ],
      ),
      code: buffer.toString(),
      props: const [
        PropSpec(
          name: 'currency',
          type: 'String',
          options: 'AED, USD, EUR',
          description: 'Currency symbol',
        ),
        PropSpec(
          name: 'intent',
          type: 'AmountInputIntent',
          options: 'purple, gold',
          description: 'Gradient theme',
        ),
        PropSpec(
          name: 'state',
          type: 'AmountInputState',
          options: 'normal, error, disabled',
          description: 'Interactive state',
        ),
        PropSpec(
          name: 'nudgeText',
          type: 'String?',
          description: 'Top right contextual text',
        ),
        PropSpec(
          name: 'helperText',
          type: 'String?',
          description: 'Bottom helper or error text',
        ),
      ],
      controls: [
        PropEnum<String>(
          label: 'Currency',
          value: _currency,
          values: const ['AED', 'USD', 'EUR'],
          labelOf: (v) => v,
          onChanged: (v) => setState(() => _currency = v),
        ),
        PropEnum<AmountInputIntent>(
          label: 'Intent',
          value: _intent,
          values: AmountInputIntent.values,
          labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _intent = v),
        ),
        PropEnum<AmountInputState>(
          label: 'State',
          value: _state,
          values: AmountInputState.values,
          labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _state = v),
        ),
        PropText(
          label: 'Nudge Text',
          value: _nudge,
          onChanged: (v) => setState(() => _nudge = v),
        ),
        PropText(
          label: 'Helper Text',
          value: _helper,
          onChanged: (v) => setState(() => _helper = v),
        ),
      ],
    );
  }
}
