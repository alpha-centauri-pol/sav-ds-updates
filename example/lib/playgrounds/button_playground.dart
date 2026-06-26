import 'package:flutter/material.dart';
import 'package:sav_ds/sav_ds.dart';
import '../playground.dart';
import 'utils.dart';

enum AppButtonTextStyleOption {
  def,
  obviouslyLargeText,
  obviouslyMediumText,
  bodyRegular,
  bodyBold,
  calloutRegular,
  calloutBold,
  calloutCta,
  captionRegular,
}

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
  AppButtonTextStyleOption _textStyleOption = AppButtonTextStyleOption.def;

  TextStyle? get _resolvedTextStyle => switch (_textStyleOption) {
        AppButtonTextStyleOption.def => null,
        AppButtonTextStyleOption.obviouslyLargeText => AppTextStyles.obviouslyLargeText,
        AppButtonTextStyleOption.obviouslyMediumText => AppTextStyles.obviouslyMediumText,
        AppButtonTextStyleOption.bodyRegular => AppTextStyles.bodyRegular,
        AppButtonTextStyleOption.bodyBold => AppTextStyles.bodyBold,
        AppButtonTextStyleOption.calloutRegular => AppTextStyles.calloutRegular,
        AppButtonTextStyleOption.calloutBold => AppTextStyles.calloutBold,
        AppButtonTextStyleOption.calloutCta => AppTextStyles.calloutCta,
        AppButtonTextStyleOption.captionRegular => AppTextStyles.captionRegular,
      };

  @override
  Widget build(BuildContext context) {
    final buffer = StringBuffer('AppButton(\n');
    if (_variant != AppButtonVariant.primary) {
      buffer.writeln('  variant: AppButtonVariant.${_variant.name},');
    }
    if (_size != AppButtonSize.large) {
      buffer.writeln('  size: AppButtonSize.${_size.name},');
    }
    if (_width != AppButtonWidth.full) {
      buffer.writeln('  width: AppButtonWidth.${_width.name},');
    }
    if (_state != AppButtonState.normal) {
      buffer.writeln('  state: AppButtonState.${_state.name},');
    }
    if (_label != 'Continue') buffer.writeln("  label: '$_label',");
    if (_icon != AppButtonIcon.none) {
      buffer.writeln('  icon: AppButtonIcon.${_icon.name},');
    }
    if (_icon == AppButtonIcon.leading || _icon == AppButtonIcon.iconOnly) {
      buffer.writeln('  leading: Icon(Icons.arrow_forward),');
    }
    if (_icon == AppButtonIcon.trailing) {
      buffer.writeln('  trailing: Icon(Icons.arrow_forward),');
    }
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
        '  strokeColor: ${colorLiteral(_strokeColorOverride!)}',
      );
    }
    if (_textStyleOption != AppButtonTextStyleOption.def) {
      buffer.writeln(
        '  textStyle: AppTextStyles.${_textStyleOption.name},',
      );
    }
    buffer
      ..writeln('  onPressed: () {},')
      ..write(')');

    return PlaygroundStage(
      id: 'AppButton',
      preview: AppButton(
        variant: _variant,
        size: _size,
        width: _width,
        state: _state,
        label: _label,
        icon: _icon,
        leading:
            (_icon == AppButtonIcon.leading || _icon == AppButtonIcon.iconOnly)
            ? const Icon(Icons.arrow_forward)
            : null,
        trailing: _icon == AppButtonIcon.trailing
            ? const Icon(Icons.arrow_forward)
            : null,
        fillColor: _fillColorOverride,
        labelColor: _labelColorOverride,
        strokeColor: _strokeColorOverride,
        textStyle: _resolvedTextStyle,
        onPressed: () {},
      ),
      code: buffer.toString(),
      props: const [
        PropSpec(
          name: 'variant',
          type: 'AppButtonVariant',
          options: 'primary, secondary, subtle, text',
          description: 'Visual style of the button',
        ),
        PropSpec(
          name: 'size',
          type: 'AppButtonSize',
          options: 'small, regular, large',
          description: 'Height and internal padding',
        ),
        PropSpec(
          name: 'width',
          type: 'AppButtonWidth',
          options: 'hug, full',
          description: 'Width behavior',
        ),
        PropSpec(
          name: 'state',
          type: 'AppButtonState',
          options: 'normal, disabled, loading',
          description: 'Interactive state',
        ),
        PropSpec(name: 'label', type: 'String', description: 'Button text'),
        PropSpec(
          name: 'icon',
          type: 'AppButtonIcon',
          options: 'none, leading, trailing, iconOnly',
          description: 'Icon placement',
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
        PropSpec(
          name: 'textStyle',
          type: 'TextStyle?',
          description: 'Overrides button typography design token',
        ),
      ],
      controls: [
        PropEnum<AppButtonVariant>(
          label: 'Variant',
          value: _variant,
          values: AppButtonVariant.values,
          labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _variant = v),
        ),
        PropEnum<AppButtonSize>(
          label: 'Size',
          value: _size,
          values: AppButtonSize.values,
          labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _size = v),
        ),
        PropEnum<AppButtonWidth>(
          label: 'Width',
          value: _width,
          values: AppButtonWidth.values,
          labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _width = v),
        ),
        PropEnum<AppButtonState>(
          label: 'State',
          value: _state,
          values: AppButtonState.values,
          labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _state = v),
        ),
        PropText(
          label: 'Label',
          value: _label,
          onChanged: (v) => setState(() => _label = v),
        ),
        PropEnum<AppButtonIcon>(
          label: 'Icon',
          value: _icon,
          values: AppButtonIcon.values,
          labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _icon = v),
        ),
        PropEnum<AppButtonTextStyleOption>(
          label: 'TextStyle Token Override',
          value: _textStyleOption,
          values: AppButtonTextStyleOption.values,
          labelOf: (v) => v == AppButtonTextStyleOption.def ? 'default (token)' : v.name,
          onChanged: (v) => setState(() => _textStyleOption = v),
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
