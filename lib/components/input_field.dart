import 'package:flutter/material.dart';
import '../core/squircle.dart';
import '../core/tokens.dart';

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
      variant: InputFieldVariant.boxed,
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

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  late final FocusNode _focusNode = widget.focusNode ?? FocusNode();
  late final TextEditingController _controller = widget.controller ?? TextEditingController();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.removeListener(_onTextChange);
    if (widget.focusNode == null) _focusNode.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!mounted) return;
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _onTextChange() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.state == InputFieldState.disabled;
    final bool isError = widget.state == InputFieldState.error;

    // Sizing
    final double height = widget.size == InputFieldSize.lg ? 48.0 : 40.0;
    final double fontSize = widget.size == InputFieldSize.lg ? 15.0 : 14.0;
    final double iconSize = widget.size == InputFieldSize.lg ? 20.0 : 18.0;

    // Colors based on state
    Color labelColor = AppColors.slate;
    Color borderStrokeColor = AppColors.hairline; // Default hairline
    Color helperColor = AppColors.slate;

    if (isDisabled) {
      labelColor = AppColors.slate.withValues(alpha: 0.5);
    } else if (isError) {
      labelColor = AppColors.bronzeError;
      borderStrokeColor = AppColors.bronzeError;
      helperColor = AppColors.bronzeError;
    } else if (_isFocused) {
      labelColor = AppColors.obsidian;
      borderStrokeColor = AppColors.obsidian;
    }

    // Build leading slot
    Widget? leadingWidget;
    if (widget.leading != InputFieldLeading.none) {
      Widget child = const SizedBox.shrink();
      switch (widget.leading) {
        case InputFieldLeading.icon:
          child = widget.leadingWidget ?? Icon(Icons.star_border_rounded, size: iconSize, color: labelColor);
          break;
        case InputFieldLeading.flag:
          child = widget.leadingWidget ?? Text('🇦🇪', style: TextStyle(fontSize: fontSize));
          break;
        case InputFieldLeading.prefix:
          child = widget.leadingWidget ?? Text(widget.prefixText ?? '+971', style: TextStyle(fontSize: fontSize, color: AppColors.slate, fontWeight: FontWeight.w500));
          break;
        case InputFieldLeading.none:
          break;
      }
      leadingWidget = Padding(
        padding: const EdgeInsets.only(left: 12, right: 8),
        child: child,
      );
    }

    // Build trailing slot
    Widget? trailingWidget;
    if (widget.trailing != InputFieldTrailing.none) {
      Widget child = const SizedBox.shrink();
      switch (widget.trailing) {
        case InputFieldTrailing.clear:
          final bool showClear = _controller.text.isNotEmpty && !isDisabled;
          child = AnimatedSwitcher(
            duration: AppMotion.duration(context, const Duration(milliseconds: 200)),
            switchInCurve: AppMotion.curveOut,
            switchOutCurve: AppMotion.curveGentleOut,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: AppMotion.blurIn(
                  animation,
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
                    child: child,
                  ),
                ),
              );
            },
            child: showClear
                ? GestureDetector(
                    key: const ValueKey('clear'),
                    onTap: () {
                      _controller.clear();
                      if (widget.onChanged != null) widget.onChanged!('');
                    },
                    child: widget.trailingWidget ?? Icon(Icons.close_rounded, size: iconSize, color: labelColor),
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          );
          break;
        case InputFieldTrailing.search:
          child = widget.trailingWidget ?? Icon(Icons.search, size: iconSize, color: labelColor);
          break;
        case InputFieldTrailing.chevron:
          child = widget.trailingWidget ?? AnimatedRotation(
            turns: _isFocused ? 0.5 : 0.0,
            duration: AppMotion.duration(context, const Duration(milliseconds: 200)),
            curve: AppMotion.curveOut,
            child: Icon(Icons.keyboard_arrow_down_rounded, size: iconSize, color: labelColor),
          );
          break;
        case InputFieldTrailing.none:
          break;
      }
      trailingWidget = Padding(
        padding: const EdgeInsets.only(left: 8, right: 12),
        child: child,
      );
    }

    final double strokeWidth = (isError || _isFocused) ? 1.5 : 1.0;

    // Build the input container decoration
    final Decoration fieldDecoration = widget.variant == InputFieldVariant.boxed
        ? SavSurface(
            curvature: 10,
            fillColor: Colors.white,
            strokeColor: borderStrokeColor,
            strokeWidth: strokeWidth,
            dropShadowColor: const Color(0x051F1F1F),
            dropShadowOffset: const Offset(0, 1),
            dropShadowBlur: 1.0,
          )
        : BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: borderStrokeColor,
                width: strokeWidth,
              ),
            ),
          );

    final Widget textInput = AnimatedContainer(
      duration: AppMotion.duration(context, AppMotion.durationHigh),
      curve: AppMotion.curveOut,
      decoration: fieldDecoration,
      height: height,
      child: Row(
        children: [
          ?leadingWidget,
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.variant == InputFieldVariant.underline ? 0.0 : 12.0),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: !isDisabled,
                onChanged: widget.onChanged,
                style: (widget.size == InputFieldSize.lg ? AppTextStyles.calloutRegular : AppTextStyles.bodyRegular).copyWith(
                  color: AppColors.obsidian,
                  fontSize: fontSize,
                ),
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  hintStyle: (widget.size == InputFieldSize.lg ? AppTextStyles.calloutRegular : AppTextStyles.bodyRegular).copyWith(
                    color: AppColors.sterling,
                    fontSize: fontSize,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          ?trailingWidget,
        ],
      ),
    );

    final Widget fieldWithHelper = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        if (widget.label != null)
          Text(
            widget.label!,
            style: AppTextStyles.caption550.copyWith(
              color: labelColor,
            ),
          ),
        textInput,
        if (widget.helperText != null)
          Text(
            widget.helperText!,
            style: AppTextStyles.captionRegular.copyWith(
              fontSize: 11,
              color: helperColor,
            ),
          ),
      ],
    );

    return AnimatedOpacity(
      opacity: isDisabled ? 0.4 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: fieldWithHelper,
    );
  }
}
