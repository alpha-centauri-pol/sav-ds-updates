import 'package:flutter/material.dart';
import 'package:sav_ds/sav_ds.dart';
import '../playground.dart';
import 'utils.dart';

class BadgePlayground extends StatefulWidget {
  const BadgePlayground({super.key});
  @override
  State<BadgePlayground> createState() => _BadgePlaygroundState();
}

class _BadgePlaygroundState extends State<BadgePlayground> {
  BadgeType _type = BadgeType.count;
  BadgeSize _size = BadgeSize.md;
  Color _color = AppColors.obsidian;
  String _value = '1';

  @override
  Widget build(BuildContext context) {
    final buffer = StringBuffer('SavBadge(\n');
    if (_type != BadgeType.count) {
      buffer.writeln('  type: BadgeType.${_type.name},');
    }
    if (_size != BadgeSize.md) {
      buffer.writeln('  size: BadgeSize.${_size.name},');
    }
    if (_color != AppColors.obsidian) {
      buffer.writeln(
        '  color: ${colorLiteral(_color)},',
      );
    }
    if (_value != '1') buffer.writeln("  value: '$_value',");
    buffer.write(')');

    return PlaygroundStage(
      id: 'SavBadge',
      preview: SavBadge(
        type: _type,
        size: _size,
        color: _color,
        value: _value.isNotEmpty ? _value : null,
      ),
      code: buffer.toString(),
      props: const [
        PropSpec(
          name: 'type',
          type: 'BadgeType',
          options: 'count, dot',
          description: 'Visual style of the badge',
        ),
        PropSpec(
          name: 'size',
          type: 'BadgeSize',
          options: 'sm, md, lg',
          description: 'Height and internal padding',
        ),
        PropSpec(name: 'color', type: 'Color', description: 'Color theme'),
        PropSpec(
          name: 'value',
          type: 'String?',
          description: 'Number text (ignored if type=dot)',
        ),
      ],
      controls: [
        PropEnum<BadgeType>(
          label: 'Type',
          value: _type,
          values: BadgeType.values,
          labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _type = v),
        ),
        PropEnum<BadgeSize>(
          label: 'Size',
          value: _size,
          values: BadgeSize.values,
          labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _size = v),
        ),
        PropColor(
          label: 'Color',
          value: _color,
          onChanged: (v) => setState(() => _color = v ?? AppColors.obsidian),
        ),
        PropText(
          label: 'Value',
          value: _value,
          onChanged: (v) => setState(() => _value = v),
        ),
      ],
    );
  }
}
