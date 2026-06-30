import 'package:flutter/material.dart';
import '../core/noise.dart';
import '../core/squircle.dart';
import '../core/tokens.dart';
import '../core/tokens/components/input.dart';
import 'internal/disabled_fade.dart';
import 'internal/managed_field_state.dart';

enum InputFieldVariant { boxed, underline }

enum InputFieldSize { md, lg }

enum InputFieldLeading { none, icon, flag, prefix }

enum InputFieldTrailing { none, clear, search, chevron }

enum InputFieldState { normal, error, disabled }

class InputField extends StatefulWidget {
  const InputField({
    super.key,
    this.variant = InputFieldVariant.boxed,
    this.size = InputFieldSize.md,
    this.leading = InputFieldLeading.none,
    this.trailing = InputFieldTrailing.none,
    this.state = InputFieldState.normal,
    this.label,
    this.placeholder,
    this.helperText,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.leadingWidget,
    this.trailingWidget,
    this.prefixText,
    this.showLeftSquircle = false,
    this.leftSquircleIcon,
    this.rightIcon,
    this.isOneRow = true,
    this.enableSurface = true,
    this.enableShadows = true,
    this.enableLeftSquircleNoise = true,
  });

  // Pre-configured SearchField constructor
  factory InputField.search({
    Key? key,
    InputFieldSize size = InputFieldSize.md,
    TextEditingController? controller,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
    String? placeholder = 'Search...',
  }) {
    return InputField(
      key: key,
      size: size,
      leading: InputFieldLeading.icon,
      trailing: InputFieldTrailing.clear,
      leadingWidget: const Icon(Icons.search, size: 18),
      placeholder: placeholder,
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
    );
  }

  final InputFieldVariant variant;
  final InputFieldSize size;
  final InputFieldLeading leading;
  final InputFieldTrailing trailing;
  final InputFieldState state;
  final String? label;
  final String? placeholder;
  final String? helperText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final Widget? leadingWidget;
  final Widget? trailingWidget;
  final String? prefixText;
  final bool showLeftSquircle;
  final Widget? leftSquircleIcon;
  final Widget? rightIcon;
  final bool isOneRow;
  final bool enableSurface;
  final bool enableShadows;
  final bool enableLeftSquircleNoise;

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField>
    with ManagedFieldStateMixin<InputField> {
  @override
  FocusNode? get widgetFocusNode => widget.focusNode;

  @override
  TextEditingController? get widgetController => widget.controller;

  ({Color label, Color stroke, Color helper}) _resolveStateColors() {
    final isDisabled = widget.state == InputFieldState.disabled;
    final isError = widget.state == InputFieldState.error;

    if (isDisabled) {
      return (
        label: AppColors.slate.withValues(alpha: 0.5),
        stroke: AppColors.hairline,
        helper: AppColors.slate,
      );
    } else if (isError) {
      return (
        label: AppColors.bronzeError,
        stroke: AppColors.bronzeError,
        helper: AppColors.bronzeError,
      );
    } else if (isFocused) {
      return (
        label: AppColors.obsidian,
        stroke: AppColors.transparent12,
        helper: AppColors.slate,
      );
    }
    return (
      label: AppColors.slate,
      stroke: AppColors.hairline,
      helper: AppColors.slate,
    );
  }

  Widget _buildLeading(InputFieldSizeTokens tokens, Color labelColor) {
    if (widget.leading == InputFieldLeading.none) {
      return const SizedBox.shrink();
    }
    Widget child = const SizedBox.shrink();
    switch (widget.leading) {
      case InputFieldLeading.icon:
        child = widget.leadingWidget ??
            Icon(
              Icons.star_border_rounded,
              size: tokens.iconSize,
              color: labelColor,
            );
      case InputFieldLeading.flag:
        child = widget.leadingWidget ??
            Text('🇦🇪', style: AppTextStyles.bodyRegular.copyWith(fontSize: tokens.fontSize));
      case InputFieldLeading.prefix:
        child = widget.leadingWidget ??
            Text(
              widget.prefixText ?? '+971',
              style: AppTextStyles.bodyBold.copyWith(
                fontSize: tokens.fontSize,
                color: AppColors.slate,
              ),
            );
      case InputFieldLeading.none:
        break;
    }
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.lg, right: AppSpacing.md),
      child: child,
    );
  }

  Widget _buildTrailing(InputFieldSizeTokens tokens, Color labelColor) {
    if (widget.trailing == InputFieldTrailing.none) {
      return const SizedBox.shrink();
    }
    Widget child = const SizedBox.shrink();
    final isDisabled = widget.state == InputFieldState.disabled;

    switch (widget.trailing) {
      case InputFieldTrailing.clear:
        final showClear = controller.text.isNotEmpty && !isDisabled;
        child = AnimatedSwitcher(
          duration: AppMotion.duration(
            context,
            const Duration(milliseconds: 200),
          ),
          switchInCurve: AppMotion.curveOut,
          switchOutCurve: AppMotion.curveGentleOut,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: AppMotion.blurIn(
                animation,
                ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1).animate(animation),
                  child: child,
                ),
              ),
            );
          },
          child: showClear
              ? GestureDetector(
                  key: const ValueKey('clear'),
                  onTap: () {
                    controller.clear();
                    widget.onChanged?.call('');
                  },
                  child: widget.trailingWidget ??
                      Icon(
                        Icons.close_rounded,
                        size: tokens.iconSize,
                        color: labelColor,
                      ),
                )
              : const SizedBox.shrink(key: ValueKey('empty')),
        );
      case InputFieldTrailing.search:
        child = widget.trailingWidget ??
            Icon(Icons.search, size: tokens.iconSize, color: labelColor);
      case InputFieldTrailing.chevron:
        child = widget.trailingWidget ??
            AnimatedRotation(
              turns: isFocused ? 0.5 : 0.0,
              duration: AppMotion.duration(
                context,
                const Duration(milliseconds: 200),
              ),
              curve: AppMotion.curveOut,
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: tokens.iconSize,
                color: labelColor,
              ),
            );
      case InputFieldTrailing.none:
        break;
    }
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.lg),
      child: child,
    );
  }

  Widget _buildLeftSquircle() {
    Widget squircle = DecoratedBox(
      decoration: const SavSurface(
        curvature: 10,
        fillColor: AppColors.obsidian,
      ),
      child: DecoratedBox(
        decoration: SavSurface(
          curvature: 10,
          fillGradient: AppGradients.leftSquircleOverlay,
        ),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child: IconTheme(
              data: const IconThemeData(
                size: 24,
                color: AppColors.white,
              ),
              child: widget.leftSquircleIcon ?? const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );

    if (widget.enableLeftSquircleNoise) {
      squircle = NoiseLayer(
        enabled: true,
        opacity: 0.8,
        scale: 1,
        curvature: 10,
        child: squircle,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 6, right: 12),
      child: squircle,
    );
  }

  Widget _buildRightIcon() {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 10),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Center(
          child: IconTheme(
            data: IconThemeData(
              size: 24,
              color: widget.state == InputFieldState.disabled
                  ? AppColors.slate.withValues(alpha: 0.5)
                  : AppColors.slate,
            ),
            child: widget.rightIcon!,
          ),
        ),
      ),
    );
  }

  Widget _buildInputContent(
    InputFieldSizeTokens tokens,
    ({Color label, Color stroke, Color helper}) colors,
  ) {
    final isDisabled = widget.state == InputFieldState.disabled;

    final TextStyle inputTextStyle;
    final TextStyle hintTextStyle;

    if (widget.showLeftSquircle) {
      inputTextStyle = (widget.size == InputFieldSize.lg
              ? AppTextStyles.calloutBold
              : AppTextStyles.bodyBold)
          .copyWith(
        color: AppColors.obsidian,
      );
      hintTextStyle = (widget.size == InputFieldSize.lg
              ? AppTextStyles.calloutBold
              : AppTextStyles.bodyBold)
          .copyWith(
        color: AppColors.sterling,
      );
    } else {
      inputTextStyle = (widget.size == InputFieldSize.lg
              ? AppTextStyles.calloutRegular
              : AppTextStyles.bodyRegular)
          .copyWith(
        color: AppColors.obsidian,
        fontSize: tokens.fontSize,
      );
      hintTextStyle = (widget.size == InputFieldSize.lg
              ? AppTextStyles.calloutRegular
              : AppTextStyles.bodyRegular)
          .copyWith(
        color: AppColors.sterling,
        fontSize: tokens.fontSize,
      );
    }

    final textField = TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: !isDisabled,
      onChanged: widget.onChanged,
      style: inputTextStyle,
      decoration: InputDecoration(
        hintText: widget.placeholder,
        hintStyle: hintTextStyle,
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
    );

    if (!widget.isOneRow && widget.label != null) {
      final labelStyle = (widget.size == InputFieldSize.lg
              ? AppTextStyles.bodyBold
              : AppTextStyles.captionRegular)
          .copyWith(color: colors.label);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.label!,
            style: labelStyle,
          ),
          const SizedBox(height: 2),
          textField,
        ],
      );
    }

    return textField;
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.state == InputFieldState.disabled;
    final isError = widget.state == InputFieldState.error;
    final tokens = InputFieldSizeTokens.resolve(widget.size);
    final colors = _resolveStateColors();
    final strokeWidth = isError ? 1.5 : 1.0;

    final Gradient? strokeGradient = (isError || isFocused)
        ? null
        : AppGradients.inputStrokeGradient;

    final Color? strokeColor = (isError || isFocused)
        ? colors.stroke
        : null;

    final fieldDecoration = widget.variant == InputFieldVariant.boxed
        ? (widget.enableSurface ? SavSurface(
            fillGradient: AppGradients.inputBgGradient,
            strokeColor: strokeColor,
            strokeGradient: strokeGradient,
            strokeWidth: strokeWidth,
            dropShadowColor: widget.enableShadows ? AppColors.transparent4 : null,
            dropShadowOffset: widget.enableShadows ? const Offset(1, 1) : Offset.zero,
            dropShadowBlur: widget.enableShadows ? 2 : 0,
            innerShadowColor: widget.enableShadows ? AppColors.transparent6 : null,
            innerShadowOffset: widget.enableShadows ? const Offset(-1, -1) : Offset.zero,
            innerShadowBlur: widget.enableShadows ? 2 : 0,
          ) : BoxDecoration(
            color: AppColors.lumen, // approx fillGradient base
            borderRadius: BorderRadius.circular(10), // approx curvature
            border: Border.all(
              color: strokeColor ?? AppColors.hairline,
              width: strokeWidth,
            ),
          ))
        : BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colors.stroke,
                width: strokeWidth,
              ),
            ),
          );

    final double fieldHeight = (!widget.isOneRow && widget.label != null)
        ? 60.0
        : tokens.height;

    final Widget textInput = AnimatedContainer(
      duration: AppMotion.duration(context, AppMotion.durationHigh),
      curve: AppMotion.curveOut,
      decoration: fieldDecoration,
      height: fieldHeight,
      child: Row(
        children: [
          if (widget.showLeftSquircle)
            _buildLeftSquircle()
          else if (widget.leading != InputFieldLeading.none)
            _buildLeading(tokens, colors.label),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: (widget.showLeftSquircle || widget.leading != InputFieldLeading.none)
                    ? 0.0
                    : (widget.variant == InputFieldVariant.underline
                        ? AppSpacing.none
                        : AppSpacing.lg),
                right: (widget.rightIcon != null || widget.trailing != InputFieldTrailing.none)
                    ? 0.0
                    : (widget.variant == InputFieldVariant.underline
                        ? AppSpacing.none
                        : AppSpacing.lg),
              ),
              child: _buildInputContent(tokens, colors),
            ),
          ),
          if (widget.rightIcon != null)
            _buildRightIcon()
          else if (widget.trailing != InputFieldTrailing.none)
            _buildTrailing(tokens, colors.label),
        ],
      ),
    );

    final Widget fieldWithHelper = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        if (widget.label != null && widget.isOneRow)
          Text(
            widget.label!,
            style: AppTextStyles.captionRegular.copyWith(color: colors.label),
          ),
        textInput,
        if (widget.helperText != null)
          Text(
            widget.helperText!,
            style: AppTextStyles.captionRegular.copyWith(
              fontSize: 11,
              color: colors.helper,
            ),
          ),
      ],
    );

    return DisabledFade(
      disabled: isDisabled,
      child: fieldWithHelper,
    );
  }
}
