import 'package:flutter/material.dart';
import 'package:sav_ds/sav_ds.dart';
import '../playground.dart';

class InputFieldPlayground extends StatefulWidget {
  const InputFieldPlayground({super.key});
  @override
  State<InputFieldPlayground> createState() => _InputFieldPlaygroundState();
}

class _InputFieldPlaygroundState extends State<InputFieldPlayground> {
  InputFieldVariant _variant = InputFieldVariant.boxed;
  InputFieldSize _size = InputFieldSize.lg;
  InputFieldLeading _leading = InputFieldLeading.none;
  InputFieldTrailing _trailing = InputFieldTrailing.none;
  InputFieldState _state = InputFieldState.normal;
  String _label = 'What is your country code?';
  String _placeholder = 'Search a country';
  String _helper = '';
  bool _showLeftSquircle = true;
  bool _isOneRow = false;

  @override
  Widget build(BuildContext context) {
    final buffer = StringBuffer('InputField(\n');
    if (_variant != InputFieldVariant.boxed) {
      buffer.writeln('  variant: InputFieldVariant.${_variant.name},');
    }
    if (_size != InputFieldSize.md) {
      buffer.writeln('  size: InputFieldSize.${_size.name},');
    }
    if (_leading != InputFieldLeading.none) {
      buffer.writeln('  leading: InputFieldLeading.${_leading.name},');
    }
    if (_trailing != InputFieldTrailing.none) {
      buffer.writeln('  trailing: InputFieldTrailing.${_trailing.name},');
    }
    if (_state != InputFieldState.normal) {
      buffer.writeln('  state: InputFieldState.${_state.name},');
    }
    if (_label.isNotEmpty) buffer.writeln("  label: '$_label',");
    if (_placeholder.isNotEmpty) {
      buffer.writeln("  placeholder: '$_placeholder',");
    }
    if (_helper.isNotEmpty) buffer.writeln("  helperText: '$_helper',");
    if (_showLeftSquircle) {
      buffer.writeln('  showLeftSquircle: true,');
      buffer.writeln('  leftSquircleIcon: Icon(Icons.phone_outlined),');
    }
    if (!_isOneRow) {
      buffer.writeln('  isOneRow: false,');
    }
    if (_showLeftSquircle) {
      buffer.writeln('  rightIcon: Icon(Icons.search),');
    }
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
        showLeftSquircle: _showLeftSquircle,
        leftSquircleIcon: _showLeftSquircle ? const Icon(Icons.phone_outlined) : null,
        rightIcon: _showLeftSquircle ? const Icon(Icons.search) : null,
        isOneRow: _isOneRow,
      ),
      code: buffer.toString(),
      props: const [
        PropSpec(
          name: 'variant',
          type: 'InputFieldVariant',
          options: 'boxed, underline',
          description: 'Visual style of the field',
        ),
        PropSpec(
          name: 'size',
          type: 'InputFieldSize',
          options: 'md, lg',
          description: 'Height and internal padding',
        ),
        PropSpec(
          name: 'leading',
          type: 'InputFieldLeading',
          options: 'none, icon, flag, prefix',
          description: 'Leading slot content type',
        ),
        PropSpec(
          name: 'trailing',
          type: 'InputFieldTrailing',
          options: 'none, clear, search, chevron',
          description: 'Trailing slot content type',
        ),
        PropSpec(
          name: 'state',
          type: 'InputFieldState',
          options: 'normal, error, disabled',
          description: 'Interactive state',
        ),
        PropSpec(name: 'label', type: 'String?', description: 'Top label text'),
        PropSpec(
          name: 'placeholder',
          type: 'String?',
          description: 'Hint text when empty',
        ),
        PropSpec(
          name: 'helperText',
          type: 'String?',
          description: 'Bottom helper or error text',
        ),
        PropSpec(
          name: 'showLeftSquircle',
          type: 'bool',
          description: 'Whether to show the left black squircle container with noise',
        ),
        PropSpec(
          name: 'isOneRow',
          type: 'bool',
          description: 'Whether to render label and input field in one row or stacked (two rows)',
        ),
      ],
      controls: [
        PropEnum<InputFieldVariant>(
          label: 'Variant',
          value: _variant,
          values: InputFieldVariant.values,
          labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _variant = v),
        ),
        PropEnum<InputFieldSize>(
          label: 'Size',
          value: _size,
          values: InputFieldSize.values,
          labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _size = v),
        ),
        PropEnum<InputFieldLeading>(
          label: 'Leading',
          value: _leading,
          values: InputFieldLeading.values,
          labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _leading = v),
        ),
        PropEnum<InputFieldTrailing>(
          label: 'Trailing',
          value: _trailing,
          values: InputFieldTrailing.values,
          labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _trailing = v),
        ),
        PropEnum<InputFieldState>(
          label: 'State',
          value: _state,
          values: InputFieldState.values,
          labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _state = v),
        ),
        PropText(
          label: 'Label',
          value: _label,
          onChanged: (v) => setState(() => _label = v),
        ),
        PropText(
          label: 'Placeholder',
          value: _placeholder,
          onChanged: (v) => setState(() => _placeholder = v),
        ),
        PropText(
          label: 'Helper Text',
          value: _helper,
          onChanged: (v) => setState(() => _helper = v),
        ),
        PropToggle(
          label: 'Show Left Squircle',
          value: _showLeftSquircle,
          onChanged: (v) => setState(() => _showLeftSquircle = v),
        ),
        PropToggle(
          label: 'Is One Row',
          value: _isOneRow,
          onChanged: (v) => setState(() => _isOneRow = v),
        ),
      ],
    );
  }
}
