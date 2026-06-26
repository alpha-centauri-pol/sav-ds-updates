import 'package:flutter/material.dart';
import 'package:sav_ds/sav_ds.dart';
import '../playground.dart';

class SegmentedPlayground extends StatefulWidget {
  const SegmentedPlayground({super.key});
  @override
  State<SegmentedPlayground> createState() => _SegmentedPlaygroundState();
}

class _SegmentedPlaygroundState extends State<SegmentedPlayground> {
  SegmentedControlStyle _style = SegmentedControlStyle.pill;
  SegmentedControlSize _size = SegmentedControlSize.md;
  bool _isFullWidth = false;
  int _itemCount = 3;
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final buffer = StringBuffer('SegmentedControl(\n');
    if (_style != SegmentedControlStyle.pill) {
      buffer.writeln('  style: SegmentedControlStyle.${_style.name},');
    }
    if (_size != SegmentedControlSize.md) {
      buffer.writeln('  size: SegmentedControlSize.${_size.name},');
    }
    if (_isFullWidth) buffer.writeln('  isFullWidth: true,');
    if (_selected != 0) buffer.writeln('  selected: $_selected,');
    buffer
      ..writeln('  items: [...],')
      ..writeln('  onChanged: (val) {},')
      ..write(')');

    return PlaygroundStage(
      id: 'SegmentedControl',
      preview: SegmentedControl(
        style: _style,
        size: _size,
        isFullWidth: _isFullWidth,
        selected: _selected,
        onChanged: (idx) => setState(() => _selected = idx),
        items: List.generate(
          _itemCount,
          (i) => SegmentedItem(label: 'Tab ${i + 1}'),
        ),
      ),
      code: buffer.toString(),
      props: const [
        PropSpec(
          name: 'style',
          type: 'SegmentedControlStyle',
          options: 'pill, underline',
          description: 'Visual style of the control',
        ),
        PropSpec(
          name: 'size',
          type: 'SegmentedControlSize',
          options: 'md, sm',
          description: 'Height and internal padding',
        ),
        PropSpec(
          name: 'isFullWidth',
          type: 'bool',
          description: 'Whether it expands to fill width',
        ),
        PropSpec(
          name: 'items',
          type: 'List<SegmentedItem>',
          description: 'List of items to display',
        ),
      ],
      controls: [
        PropEnum<SegmentedControlStyle>(
          label: 'Style',
          value: _style,
          values: SegmentedControlStyle.values,
          labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _style = v),
        ),
        PropEnum<SegmentedControlSize>(
          label: 'Size',
          value: _size,
          values: SegmentedControlSize.values,
          labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _size = v),
        ),
        PropToggle(
          label: 'Full Width',
          value: _isFullWidth,
          onChanged: (v) => setState(() => _isFullWidth = v),
        ),
        PropSlider(
          label: 'Item Count',
          value: _itemCount.toDouble(),
          min: 2,
          max: 5,
          divisions: 3,
          onChanged: (v) => setState(() => _itemCount = v.toInt()),
        ),
      ],
    );
  }
}
