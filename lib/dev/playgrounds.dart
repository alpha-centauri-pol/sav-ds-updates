import 'package:flutter/material.dart';
import '../components/app_button.dart';
import '../components/input_field.dart';
import '../components/otp_input.dart';
import '../components/amount_input.dart';
import '../components/segmented_control.dart';
import '../components/badge.dart';
import '../components/sav_chip.dart';
import '../components/selectable_row.dart';
import '../core/tokens.dart';
import 'playground.dart';

class ButtonPlayground extends StatefulWidget {
  const ButtonPlayground({super.key});
  @override
  State<ButtonPlayground> createState() => _ButtonPlaygroundState();
}

class _ButtonPlaygroundState extends State<ButtonPlayground> {
  AppButtonVariant _variant = AppButtonVariant.primary;
  AppButtonSize _size = AppButtonSize.large;
  AppButtonWidth _width = AppButtonWidth.full;
  AppButtonState _state = AppButtonState.normal;
  String _label = 'Continue';
  AppButtonIcon _icon = AppButtonIcon.none;
  Color? _fillColorOverride;
  Color? _labelColorOverride;
  Color? _strokeColorOverride;

  @override
  Widget build(BuildContext context) {
    final buffer = StringBuffer('AppButton(\n');
    if (_variant != AppButtonVariant.primary) buffer.writeln('  variant: AppButtonVariant.${_variant.name},');
    if (_size != AppButtonSize.large) buffer.writeln('  size: AppButtonSize.${_size.name},');
    if (_width != AppButtonWidth.full) buffer.writeln('  width: AppButtonWidth.${_width.name},');
    if (_state != AppButtonState.normal) buffer.writeln('  state: AppButtonState.${_state.name},');
    if (_label != 'Continue') buffer.writeln("  label: '$_label',");
    if (_icon != AppButtonIcon.none) buffer.writeln('  icon: AppButtonIcon.${_icon.name},');
    if (_icon == AppButtonIcon.leading || _icon == AppButtonIcon.iconOnly) buffer.writeln('  leading: Icon(Icons.arrow_forward),');
    if (_icon == AppButtonIcon.trailing) buffer.writeln('  trailing: Icon(Icons.arrow_forward),');
    if (_fillColorOverride != null) buffer.writeln('  fillColor: Color(0x${_fillColorOverride!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}),');
    if (_labelColorOverride != null) buffer.writeln('  labelColor: Color(0x${_labelColorOverride!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}),');
    if (_strokeColorOverride != null) buffer.writeln('  strokeColor: Color(0x${_strokeColorOverride!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}),');
    buffer.writeln('  onPressed: () {},');
    buffer.write(')');

    return PlaygroundStage(
      id: 'AppButton',
      preview: AppButton(
        variant: _variant,
        size: _size,
        width: _width,
        state: _state,
        label: _label,
        icon: _icon,
        leading: (_icon == AppButtonIcon.leading || _icon == AppButtonIcon.iconOnly) ? const Icon(Icons.arrow_forward) : null,
        trailing: _icon == AppButtonIcon.trailing ? const Icon(Icons.arrow_forward) : null,
        fillColor: _fillColorOverride,
        labelColor: _labelColorOverride,
        strokeColor: _strokeColorOverride,
        onPressed: () {},
      ),
      code: buffer.toString(),
      props: const [
        PropSpec(name: 'variant', type: 'AppButtonVariant', options: 'primary, secondary, subtle, text', description: 'Visual style of the button'),
        PropSpec(name: 'size', type: 'AppButtonSize', options: 'small, regular, large', description: 'Height and internal padding'),
        PropSpec(name: 'width', type: 'AppButtonWidth', options: 'hug, full', description: 'Width behavior'),
        PropSpec(name: 'state', type: 'AppButtonState', options: 'normal, disabled, loading', description: 'Interactive state'),
        PropSpec(name: 'label', type: 'String', description: 'Button text'),
        PropSpec(name: 'icon', type: 'AppButtonIcon', options: 'none, leading, trailing, iconOnly', description: 'Icon placement'),
        PropSpec(name: 'fillColorOverride', type: 'Color?', description: 'Overrides token fill color'),
        PropSpec(name: 'labelColorOverride', type: 'Color?', description: 'Overrides token label color'),
        PropSpec(name: 'strokeColorOverride', type: 'Color?', description: 'Overrides token stroke color'),
      ],
      controls: [
        PropEnum<AppButtonVariant>(
          label: 'Variant', value: _variant, values: AppButtonVariant.values, labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _variant = v),
        ),
        PropEnum<AppButtonSize>(
          label: 'Size', value: _size, values: AppButtonSize.values, labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _size = v),
        ),
        PropEnum<AppButtonWidth>(
          label: 'Width', value: _width, values: AppButtonWidth.values, labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _width = v),
        ),
        PropEnum<AppButtonState>(
          label: 'State', value: _state, values: AppButtonState.values, labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _state = v),
        ),
        PropText(
          label: 'Label', value: _label, onChanged: (v) => setState(() => _label = v),
        ),
        PropEnum<AppButtonIcon>(
          label: 'Icon', value: _icon, values: AppButtonIcon.values, labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _icon = v),
        ),
        PropColor(
          label: 'Fill Color Override', value: _fillColorOverride, onChanged: (v) => setState(() => _fillColorOverride = v),
        ),
        PropColor(
          label: 'Label Color Override', value: _labelColorOverride, onChanged: (v) => setState(() => _labelColorOverride = v),
        ),
        PropColor(
          label: 'Stroke Color Override', value: _strokeColorOverride, onChanged: (v) => setState(() => _strokeColorOverride = v),
        ),
      ],
    );
  }
}

class InputFieldPlayground extends StatefulWidget {
  const InputFieldPlayground({super.key});
  @override
  State<InputFieldPlayground> createState() => _InputFieldPlaygroundState();
}

class _InputFieldPlaygroundState extends State<InputFieldPlayground> {
  InputFieldVariant _variant = InputFieldVariant.boxed;
  InputFieldSize _size = InputFieldSize.md;
  InputFieldLeading _leading = InputFieldLeading.none;
  InputFieldTrailing _trailing = InputFieldTrailing.none;
  InputFieldState _state = InputFieldState.normal;
  String _label = 'Username';
  String _placeholder = 'Enter your username';
  String _helper = 'This will be public';

  @override
  Widget build(BuildContext context) {
    final buffer = StringBuffer('InputField(\n');
    if (_variant != InputFieldVariant.boxed) buffer.writeln('  variant: InputFieldVariant.${_variant.name},');
    if (_size != InputFieldSize.md) buffer.writeln('  size: InputFieldSize.${_size.name},');
    if (_leading != InputFieldLeading.none) buffer.writeln('  leading: InputFieldLeading.${_leading.name},');
    if (_trailing != InputFieldTrailing.none) buffer.writeln('  trailing: InputFieldTrailing.${_trailing.name},');
    if (_state != InputFieldState.normal) buffer.writeln('  state: InputFieldState.${_state.name},');
    if (_label.isNotEmpty) buffer.writeln("  label: '$_label',");
    if (_placeholder.isNotEmpty) buffer.writeln("  placeholder: '$_placeholder',");
    if (_helper.isNotEmpty) buffer.writeln("  helperText: '$_helper',");
    buffer.write(')');

    return PlaygroundStage(
      id: 'InputField',
      preview: InputField(
        variant: _variant,
        size: _size,
        leading: _leading,
        trailing: _trailing,
        state: _state,
        label: _label.isNotEmpty ? _label : null,
        placeholder: _placeholder.isNotEmpty ? _placeholder : null,
        helperText: _helper.isNotEmpty ? _helper : null,
      ),
      code: buffer.toString(),
      props: const [
        PropSpec(name: 'variant', type: 'InputFieldVariant', options: 'boxed, underline', description: 'Visual style of the field'),
        PropSpec(name: 'size', type: 'InputFieldSize', options: 'md, lg', description: 'Height and internal padding'),
        PropSpec(name: 'leading', type: 'InputFieldLeading', options: 'none, icon, flag, prefix', description: 'Leading slot content type'),
        PropSpec(name: 'trailing', type: 'InputFieldTrailing', options: 'none, clear, search, chevron', description: 'Trailing slot content type'),
        PropSpec(name: 'state', type: 'InputFieldState', options: 'normal, error, disabled', description: 'Interactive state'),
        PropSpec(name: 'label', type: 'String?', description: 'Top label text'),
        PropSpec(name: 'placeholder', type: 'String?', description: 'Hint text when empty'),
        PropSpec(name: 'helperText', type: 'String?', description: 'Bottom helper or error text'),
      ],
      controls: [
        PropEnum<InputFieldVariant>(
          label: 'Variant', value: _variant, values: InputFieldVariant.values, labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _variant = v),
        ),
        PropEnum<InputFieldSize>(
          label: 'Size', value: _size, values: InputFieldSize.values, labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _size = v),
        ),
        PropEnum<InputFieldLeading>(
          label: 'Leading', value: _leading, values: InputFieldLeading.values, labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _leading = v),
        ),
        PropEnum<InputFieldTrailing>(
          label: 'Trailing', value: _trailing, values: InputFieldTrailing.values, labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _trailing = v),
        ),
        PropEnum<InputFieldState>(
          label: 'State', value: _state, values: InputFieldState.values, labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _state = v),
        ),
        PropText(
          label: 'Label', value: _label, onChanged: (v) => setState(() => _label = v),
        ),
        PropText(
          label: 'Placeholder', value: _placeholder, onChanged: (v) => setState(() => _placeholder = v),
        ),
        PropText(
          label: 'Helper Text', value: _helper, onChanged: (v) => setState(() => _helper = v),
        ),
      ],
    );
  }
}

class OTPPlayground extends StatefulWidget {
  const OTPPlayground({super.key});
  @override
  State<OTPPlayground> createState() => _OTPPlaygroundState();
}

class _OTPPlaygroundState extends State<OTPPlayground> {
  int _length = 4;
  OTPInputState _state = OTPInputState.normal;

  @override
  Widget build(BuildContext context) {
    final buffer = StringBuffer('OTPInput(\n');
    if (_length != 4) buffer.writeln('  length: $_length,');
    if (_state != OTPInputState.normal) buffer.writeln('  state: OTPInputState.${_state.name},');
    buffer.writeln('  onCompleted: (val) {},');
    buffer.write(')');

    return PlaygroundStage(
      id: 'OTPInput',
      preview: OTPInput(
        length: _length,
        state: _state,
        onCompleted: (_) {},
      ),
      code: buffer.toString(),
      props: const [
        PropSpec(name: 'length', type: 'int', description: 'Number of digits (4-8)'),
        PropSpec(name: 'state', type: 'OTPInputState', options: 'normal, error, disabled', description: 'Interactive state'),
        PropSpec(name: 'onCompleted', type: 'ValueChanged<String>', description: 'Callback when all digits are filled'),
      ],
      controls: [
        PropSlider(
          label: 'Length',
          value: _length.toDouble(),
          min: 4, max: 8, divisions: 4,
          onChanged: (v) => setState(() => _length = v.toInt()),
        ),
        PropEnum<OTPInputState>(
          label: 'State', value: _state, values: OTPInputState.values, labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _state = v),
        ),
      ],
    );
  }
}

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
    if (_intent != AmountInputIntent.purple) buffer.writeln('  intent: AmountInputIntent.${_intent.name},');
    if (_state != AmountInputState.normal) buffer.writeln('  state: AmountInputState.${_state.name},');
    if (_nudge.isNotEmpty) buffer.writeln("  nudgeText: '$_nudge',");
    if (_helper.isNotEmpty) buffer.writeln("  helperText: '$_helper',");
    buffer.writeln('  onChanged: (val) {},');
    buffer.write(')');

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
            width: AppButtonWidth.hug,
            onPressed: () {},
          ),
        ],
      ),
      code: buffer.toString(),
      props: const [
        PropSpec(name: 'currency', type: 'String', options: 'AED, USD, EUR', description: 'Currency symbol'),
        PropSpec(name: 'intent', type: 'AmountInputIntent', options: 'purple, gold', description: 'Gradient theme'),
        PropSpec(name: 'state', type: 'AmountInputState', options: 'normal, error, disabled', description: 'Interactive state'),
        PropSpec(name: 'nudgeText', type: 'String?', description: 'Top right contextual text'),
        PropSpec(name: 'helperText', type: 'String?', description: 'Bottom helper or error text'),
      ],
      controls: [
        PropEnum<String>(
          label: 'Currency', value: _currency, values: const ['AED', 'USD', 'EUR'], labelOf: (v) => v,
          onChanged: (v) => setState(() => _currency = v),
        ),
        PropEnum<AmountInputIntent>(
          label: 'Intent', value: _intent, values: AmountInputIntent.values, labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _intent = v),
        ),
        PropEnum<AmountInputState>(
          label: 'State', value: _state, values: AmountInputState.values, labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _state = v),
        ),
        PropText(
          label: 'Nudge Text', value: _nudge, onChanged: (v) => setState(() => _nudge = v),
        ),
        PropText(
          label: 'Helper Text', value: _helper, onChanged: (v) => setState(() => _helper = v),
        ),
      ],
    );
  }
}

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
    if (_style != SegmentedControlStyle.pill) buffer.writeln('  style: SegmentedControlStyle.${_style.name},');
    if (_size != SegmentedControlSize.md) buffer.writeln('  size: SegmentedControlSize.${_size.name},');
    if (_isFullWidth) buffer.writeln('  isFullWidth: true,');
    if (_selected != 0) buffer.writeln('  selected: $_selected,');
    buffer.writeln('  items: [...],');
    buffer.writeln('  onChanged: (val) {},');
    buffer.write(')');

    return PlaygroundStage(
      id: 'SegmentedControl',
      preview: SegmentedControl(
        style: _style,
        size: _size,
        isFullWidth: _isFullWidth,
        selected: _selected,
        onChanged: (idx) => setState(() => _selected = idx),
        items: List.generate(_itemCount, (i) => SegmentedItem(label: 'Tab ${i + 1}')),
      ),
      code: buffer.toString(),
      props: const [
        PropSpec(name: 'style', type: 'SegmentedControlStyle', options: 'pill, underline', description: 'Visual style of the control'),
        PropSpec(name: 'size', type: 'SegmentedControlSize', options: 'md, sm', description: 'Height and internal padding'),
        PropSpec(name: 'isFullWidth', type: 'bool', description: 'Whether it expands to fill width'),
        PropSpec(name: 'items', type: 'List<SegmentedItem>', description: 'List of items to display'),
      ],
      controls: [
        PropEnum<SegmentedControlStyle>(
          label: 'Style', value: _style, values: SegmentedControlStyle.values, labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _style = v),
        ),
        PropEnum<SegmentedControlSize>(
          label: 'Size', value: _size, values: SegmentedControlSize.values, labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _size = v),
        ),
        PropToggle(
          label: 'Full Width', value: _isFullWidth, onChanged: (v) => setState(() => _isFullWidth = v),
        ),
        PropSlider(
          label: 'Item Count', value: _itemCount.toDouble(), min: 2, max: 5, divisions: 3,
          onChanged: (v) => setState(() => _itemCount = v.toInt()),
        ),
      ],
    );
  }
}

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
    if (_type != BadgeType.count) buffer.writeln('  type: BadgeType.${_type.name},');
    if (_size != BadgeSize.md) buffer.writeln('  size: BadgeSize.${_size.name},');
    if (_color != AppColors.obsidian) buffer.writeln('  color: Color(0x${_color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}),');
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
        PropSpec(name: 'type', type: 'BadgeType', options: 'count, dot', description: 'Visual style of the badge'),
        PropSpec(name: 'size', type: 'BadgeSize', options: 'sm, md, lg', description: 'Height and internal padding'),
        PropSpec(name: 'color', type: 'Color', description: 'Color theme'),
        PropSpec(name: 'value', type: 'String?', description: 'Number text (ignored if type=dot)'),
      ],
      controls: [
        PropEnum<BadgeType>(
          label: 'Type', value: _type, values: BadgeType.values, labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _type = v),
        ),
        PropEnum<BadgeSize>(
          label: 'Size', value: _size, values: BadgeSize.values, labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _size = v),
        ),
        PropColor(
          label: 'Color', value: _color, onChanged: (v) => setState(() => _color = v ?? AppColors.obsidian),
        ),
        PropText(
          label: 'Value', value: _value, onChanged: (v) => setState(() => _value = v),
        ),
      ],
    );
  }
}

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
    if (_size != SavChipSize.sm) buffer.writeln('  size: SavChipSize.${_size.name},');
    if (_tone != SavChipTone.neutral) buffer.writeln('  tone: SavChipTone.${_tone.name},');
    if (_label != 'Tag') buffer.writeln("  label: '$_label',");
    if (_hasIcon) buffer.writeln('  leadingIcon: Icons.star_rounded,');
    if (_fillColorOverride != null) buffer.writeln('  fillColor: Color(0x${_fillColorOverride!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}),');
    if (_labelColorOverride != null) buffer.writeln('  labelColor: Color(0x${_labelColorOverride!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}),');
    if (_strokeColorOverride != null) buffer.writeln('  strokeColor: Color(0x${_strokeColorOverride!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}),');
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
        PropSpec(name: 'size', type: 'SavChipSize', options: 'sm, lg', description: 'Height and internal padding'),
        PropSpec(name: 'tone', type: 'SavChipTone', options: 'neutral, success, error, warning, info', description: 'Semantic color theme'),
        PropSpec(name: 'label', type: 'String', description: 'Chip text'),
        PropSpec(name: 'leadingIcon', type: 'IconData?', description: 'Optional leading icon'),
        PropSpec(name: 'fillColorOverride', type: 'Color?', description: 'Overrides token fill color'),
        PropSpec(name: 'labelColorOverride', type: 'Color?', description: 'Overrides token label color'),
        PropSpec(name: 'strokeColorOverride', type: 'Color?', description: 'Overrides token stroke color'),
      ],
      controls: [
        PropEnum<SavChipSize>(
          label: 'Size', value: _size, values: SavChipSize.values, labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _size = v),
        ),
        PropEnum<SavChipTone>(
          label: 'Tone', value: _tone, values: SavChipTone.values, labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _tone = v),
        ),
        PropText(
          label: 'Label', value: _label, onChanged: (v) => setState(() => _label = v),
        ),
        PropToggle(
          label: 'Has Leading Icon', value: _hasIcon, onChanged: (v) => setState(() => _hasIcon = v),
        ),
        PropColor(
          label: 'Fill Color Override', value: _fillColorOverride, onChanged: (v) => setState(() => _fillColorOverride = v),
        ),
        PropColor(
          label: 'Label Color Override', value: _labelColorOverride, onChanged: (v) => setState(() => _labelColorOverride = v),
        ),
        PropColor(
          label: 'Stroke Color Override', value: _strokeColorOverride, onChanged: (v) => setState(() => _strokeColorOverride = v),
        ),
      ],
    );
  }
}

class SelectableRowPlayground extends StatefulWidget {
  const SelectableRowPlayground({super.key});
  @override
  State<SelectableRowPlayground> createState() => _SelectableRowPlaygroundState();
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
    if (_indicator != SelectableRowIndicator.radioDot) buffer.writeln('  indicator: SelectableRowIndicator.${_indicator.name},');
    if (_selected) buffer.writeln('  selected: true,');
    if (!_showDivider) buffer.writeln('  showDivider: false,');
    if (_state != SelectableRowState.normal) buffer.writeln('  state: SelectableRowState.${_state.name},');
    buffer.writeln("  label: '$_label',");
    if (_secondary.isNotEmpty) buffer.writeln("  secondaryLabel: '$_secondary',");
    buffer.writeln('  onChanged: (val) {},');
    buffer.write(')');

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
        PropSpec(name: 'indicator', type: 'SelectableRowIndicator', options: 'radio, checkbox', description: 'Visual style of the indicator'),
        PropSpec(name: 'selected', type: 'bool', description: 'Selection state'),
        PropSpec(name: 'showDivider', type: 'bool', description: 'Show bottom hairline divider'),
        PropSpec(name: 'state', type: 'SelectableRowState', options: 'normal, disabled', description: 'Interactive state'),
        PropSpec(name: 'label', type: 'String', description: 'Primary text'),
        PropSpec(name: 'secondaryLabel', type: 'String?', description: 'Optional secondary text'),
      ],
      controls: [
        PropEnum<SelectableRowIndicator>(
          label: 'Indicator', value: _indicator, values: SelectableRowIndicator.values, labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _indicator = v),
        ),
        PropToggle(
          label: 'Selected', value: _selected, onChanged: (v) => setState(() => _selected = v),
        ),
        PropToggle(
          label: 'Show Divider', value: _showDivider, onChanged: (v) => setState(() => _showDivider = v),
        ),
        PropEnum<SelectableRowState>(
          label: 'State', value: _state, values: SelectableRowState.values, labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _state = v),
        ),
        PropText(
          label: 'Label', value: _label, onChanged: (v) => setState(() => _label = v),
        ),
        PropText(
          label: 'Secondary Label', value: _secondary, onChanged: (v) => setState(() => _secondary = v),
        ),
      ],
    );
  }
}
