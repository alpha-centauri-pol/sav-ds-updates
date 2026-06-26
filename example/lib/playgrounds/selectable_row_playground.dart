import 'package:flutter/material.dart';
import 'package:sav_ds/sav_ds.dart';
import '../playground.dart';

class SelectableRowPlayground extends StatefulWidget {
  const SelectableRowPlayground({super.key});
  @override
  State<SelectableRowPlayground> createState() =>
      _SelectableRowPlaygroundState();
}

class _SelectableRowPlaygroundState extends State<SelectableRowPlayground> {
  SelectableRowIndicator _indicator = SelectableRowIndicator.radioDot;
  bool _selected = false;
  bool _showDivider = true;
  SelectableRowState _state = SelectableRowState.normal;
  String _label = 'Option Label';
  String _secondary = 'Secondary details here';

  @override
  Widget build(BuildContext context) {
    final buffer = StringBuffer('SelectableRow(\n');
    if (_indicator != SelectableRowIndicator.radioDot) {
      buffer.writeln('  indicator: SelectableRowIndicator.${_indicator.name},');
    }
    if (_selected) buffer.writeln('  selected: true,');
    if (!_showDivider) buffer.writeln('  showDivider: false,');
    if (_state != SelectableRowState.normal) {
      buffer.writeln('  state: SelectableRowState.${_state.name},');
    }
    buffer.writeln("  label: '$_label',");
    if (_secondary.isNotEmpty) {
      buffer.writeln("  secondaryLabel: '$_secondary',");
    }
    buffer
      ..writeln('  onChanged: (val) {},')
      ..write(')');

    return PlaygroundStage(
      id: 'SelectableRow',
      preview: SelectableRow(
        indicator: _indicator,
        selected: _selected,
        divider: _showDivider,
        state: _state,
        label: _label,
        secondary: _secondary.isNotEmpty ? _secondary : null,
        onTap: () => setState(() => _selected = !_selected),
      ),
      code: buffer.toString(),
      props: const [
        PropSpec(
          name: 'indicator',
          type: 'SelectableRowIndicator',
          options: 'radio, checkbox',
          description: 'Visual style of the indicator',
        ),
        PropSpec(
          name: 'selected',
          type: 'bool',
          description: 'Selection state',
        ),
        PropSpec(
          name: 'showDivider',
          type: 'bool',
          description: 'Show bottom hairline divider',
        ),
        PropSpec(
          name: 'state',
          type: 'SelectableRowState',
          options: 'normal, disabled',
          description: 'Interactive state',
        ),
        PropSpec(name: 'label', type: 'String', description: 'Primary text'),
        PropSpec(
          name: 'secondaryLabel',
          type: 'String?',
          description: 'Optional secondary text',
        ),
      ],
      controls: [
        PropEnum<SelectableRowIndicator>(
          label: 'Indicator',
          value: _indicator,
          values: SelectableRowIndicator.values,
          labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _indicator = v),
        ),
        PropToggle(
          label: 'Selected',
          value: _selected,
          onChanged: (v) => setState(() => _selected = v),
        ),
        PropToggle(
          label: 'Show Divider',
          value: _showDivider,
          onChanged: (v) => setState(() => _showDivider = v),
        ),
        PropEnum<SelectableRowState>(
          label: 'State',
          value: _state,
          values: SelectableRowState.values,
          labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _state = v),
        ),
        PropText(
          label: 'Label',
          value: _label,
          onChanged: (v) => setState(() => _label = v),
        ),
        PropText(
          label: 'Secondary Label',
          value: _secondary,
          onChanged: (v) => setState(() => _secondary = v),
        ),
      ],
    );
  }
}
