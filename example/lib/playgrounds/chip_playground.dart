import 'package:flutter/material.dart';
import 'package:sav_ds/sav_ds.dart';
import '../playground.dart';
import 'utils.dart';

class ChipPlayground extends StatefulWidget {
  const ChipPlayground({super.key});
  @override
  State<ChipPlayground> createState() => _ChipPlaygroundState();
}

class _ChipPlaygroundState extends State<ChipPlayground> {
  SavChipSize _size = SavChipSize.sm;
  SavChipTone _tone = SavChipTone.neutral;
  String _label = 'Tag';
  bool _hasIcon = false;
  Color? _fillColorOverride;
  Color? _labelColorOverride;
  Color? _strokeColorOverride;

  @override
  Widget build(BuildContext context) {
    final buffer = StringBuffer('SavChip(\n');
    if (_size != SavChipSize.sm) {
      buffer.writeln('  size: SavChipSize.${_size.name},');
    }
    if (_tone != SavChipTone.neutral) {
      buffer.writeln('  tone: SavChipTone.${_tone.name},');
    }
    if (_label != 'Tag') buffer.writeln("  label: '$_label',");
    if (_hasIcon) buffer.writeln('  leadingIcon: Icons.star_rounded,');
    if (_fillColorOverride != null) {
      buffer.writeln(
        '  fillColor: ${colorLiteral(_fillColorOverride!)},',
      );
    }
    if (_labelColorOverride != null) {
      buffer.writeln(
        '  labelColor: ${colorLiteral(_labelColorOverride!)},',
      );
    }
    if (_strokeColorOverride != null) {
      buffer.writeln(
        '  strokeColor: ${colorLiteral(_strokeColorOverride!)},',
      );
    }
    buffer.write(')');

    return PlaygroundStage(
      id: 'SavChip',
      preview: SavChip(
        size: _size,
        tone: _tone,
        label: _label,
        leadingIcon: _hasIcon ? Icons.star_rounded : null,
        fillColor: _fillColorOverride,
        labelColor: _labelColorOverride,
        strokeColor: _strokeColorOverride,
      ),
      code: buffer.toString(),
      props: const [
        PropSpec(
          name: 'size',
          type: 'SavChipSize',
          options: 'sm, lg',
          description: 'Height and internal padding',
        ),
        PropSpec(
          name: 'tone',
          type: 'SavChipTone',
          options: 'neutral, success, error, warning, info',
          description: 'Semantic color theme',
        ),
        PropSpec(name: 'label', type: 'String', description: 'Chip text'),
        PropSpec(
          name: 'leadingIcon',
          type: 'IconData?',
          description: 'Optional leading icon',
        ),
        PropSpec(
          name: 'fillColorOverride',
          type: 'Color?',
          description: 'Overrides token fill color',
        ),
        PropSpec(
          name: 'labelColorOverride',
          type: 'Color?',
          description: 'Overrides token label color',
        ),
        PropSpec(
          name: 'strokeColorOverride',
          type: 'Color?',
          description: 'Overrides token stroke color',
        ),
      ],
      controls: [
        PropEnum<SavChipSize>(
          label: 'Size',
          value: _size,
          values: SavChipSize.values,
          labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _size = v),
        ),
        PropEnum<SavChipTone>(
          label: 'Tone',
          value: _tone,
          values: SavChipTone.values,
          labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _tone = v),
        ),
        PropText(
          label: 'Label',
          value: _label,
          onChanged: (v) => setState(() => _label = v),
        ),
        PropToggle(
          label: 'Has Leading Icon',
          value: _hasIcon,
          onChanged: (v) => setState(() => _hasIcon = v),
        ),
        PropColor(
          label: 'Fill Color Override',
          value: _fillColorOverride,
          onChanged: (v) => setState(() => _fillColorOverride = v),
        ),
        PropColor(
          label: 'Label Color Override',
          value: _labelColorOverride,
          onChanged: (v) => setState(() => _labelColorOverride = v),
        ),
        PropColor(
          label: 'Stroke Color Override',
          value: _strokeColorOverride,
          onChanged: (v) => setState(() => _strokeColorOverride = v),
        ),
      ],
    );
  }
}
