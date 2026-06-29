import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/tokens.dart';
import 'internal/managed_field_state.dart';
import 'sav_chip.dart';

enum AmountInputIntent { gold, purple, neutral }

enum AmountInputState { normal, error }

class AmountInput extends StatefulWidget {
  const AmountInput({
    super.key,
    this.currency = 'AED',
    this.intent = AmountInputIntent.neutral,
    this.state = AmountInputState.normal,
    this.helperText,
    this.nudgeText, // e.g. "0.1791g ⓘ"
    this.controller,
    this.focusNode,
    this.onChanged,
    this.enableGradient = true,
    this.enableMotion = true,
    this.enableTextAnimation = true,
  });

  final String currency;
  final AmountInputIntent intent;
  final AmountInputState state;
  final String? helperText;
  final String? nudgeText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final bool enableGradient;
  final bool enableMotion;
  final bool enableTextAnimation;

  @override
  State<AmountInput> createState() => _AmountInputState();
}

class _AmountInputState extends State<AmountInput>
    with TickerProviderStateMixin, ManagedFieldStateMixin<AmountInput> {
  @override
  FocusNode? get widgetFocusNode => widget.focusNode;

  @override
  TextEditingController? get widgetController => widget.controller;

  late final AnimationController _shakeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  late final AnimationController _scaleController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
  );

  @override
  void initState() {
    final initialText = controller.text;
    final formatted = _formatNumber(initialText);
    if (formatted != initialText) {
      controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    super.initState();
  }

  @override
  void didUpdateWidget(AmountInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == AmountInputState.error &&
        oldWidget.state != AmountInputState.error) {
      if (!AppMotion.reduce(context)) _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  void onFocusChanged() {
    if (!isFocused && !AppMotion.reduce(context)) {
      // Scale on commit
      _scaleController.forward(from: 0).then((_) {
        if (mounted) _scaleController.reverse();
      });
    }
  }

  String _formatNumber(String text) {
    if (text.isEmpty) return '';

    // Clean text: strip out anything that isn't a digit or a period
    var cleanText = text.replaceAll(RegExp(r'[^0-9.]'), '');

    // Handle multiple decimal points: keep only the first one
    final points = '.'.allMatches(cleanText).length;
    if (points > 1) {
      final firstPointIndex = cleanText.indexOf('.');
      final beforePoint = cleanText.substring(0, firstPointIndex);
      final afterPoint = cleanText.substring(firstPointIndex + 1).replaceAll('.', '');
      cleanText = '$beforePoint.$afterPoint';
    }

    final parts = cleanText.split('.');
    var intPart = parts[0];
    final hasDecimal = parts.length > 1;
    final decPart = hasDecimal ? parts[1] : '';

    // Strip leading zeros from the integer part
    if (intPart.startsWith('0') && intPart.length > 1) {
      intPart = intPart.replaceFirst(RegExp(r'^0+'), '');
      if (intPart.isEmpty) intPart = '0';
    }

    // Prepend 0 if integer part is empty but decimal point exists
    if (intPart.isEmpty && hasDecimal) {
      intPart = '0';
    }

    // Format integer part with commas
    final buffer = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(intPart[i]);
    }

    return buffer.toString() + (hasDecimal ? '.$decPart' : '');
  }

  @override
  void onTextChanged() {
    final text = controller.text;
    final formatted = _formatNumber(text);
    if (formatted != text) {
      final selection = controller.selection;

      int nonCommaCountBeforeCursor = 0;
      for (int i = 0; i < selection.end && i < text.length; i++) {
        if (text[i] != ',') {
          nonCommaCountBeforeCursor++;
        }
      }

      int newSelectionOffset = 0;
      int nonCommaCount = 0;
      while (newSelectionOffset < formatted.length &&
          nonCommaCount < nonCommaCountBeforeCursor) {
        if (formatted[newSelectionOffset] != ',') {
          nonCommaCount++;
        }
        newSelectionOffset++;
      }

      controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: newSelectionOffset),
      );
    } else {
      widget.onChanged?.call(formatted);
    }
  }

  void _handleChanged(String value) {
    if (mounted && !AppMotion.reduce(context)) {
      // subtle scale shift on change
      _scaleController.forward(from: 0.5).then((_) {
        if (mounted) _scaleController.reverse();
      });
    }
  }

  Widget _buildMotion(Widget child) {
    if (!widget.enableMotion) return child;
    return AnimatedBuilder(
      animation: Listenable.merge([_shakeController, _scaleController]),
      builder: (context, child) {
        final sinValue = math.sin(_shakeController.value * 3 * math.pi);
        final offset = sinValue * 8.0 * (1.0 - _shakeController.value);
        final scale = 1.0 + (_scaleController.value * 0.02);

        return Transform.translate(
          offset: Offset(offset, 0),
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  ({Color fallback, LinearGradient? gradient}) _resolveColors(bool isError) {
    if (isError) return (fallback: AppColors.bronzeError, gradient: null);

    switch (widget.intent) {
      case AmountInputIntent.gold:
        return (
          fallback: AppColors.obsidian,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.3016, 0.6919, 0.8871],
            colors: [
              AppColors.goldStandard800,
              AppColors.goldStandard700,
              AppColors.goldStandard500,
            ],
          )
        );
      case AmountInputIntent.purple:
        return (
          fallback: AppColors.obsidian,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.3016, 0.6919, 0.8871],
            colors: [
              AppColors.purplePower800,
              AppColors.purplePower700,
              AppColors.purplePower500,
            ],
          )
        );
      case AmountInputIntent.neutral:
        return (fallback: AppColors.obsidian, gradient: null);
    }
  }

  Widget _buildInputArea({
    required bool isError,
    required Color fallbackColor,
    required LinearGradient? textGradient,
  }) {
    final borderStrokeColor = isError
        ? AppColors.bronzeError
        : (isFocused ? AppColors.obsidian : AppColors.hairline);

    final arrowTurns = isError
        ? 0.75
        : (widget.intent == AmountInputIntent.purple ? 0.5 : 0.0);

    return AnimatedContainer(
      duration: AppMotion.duration(context, const Duration(milliseconds: 200)),
      curve: AppMotion.curveOut,
      width: 260,
      padding: const EdgeInsets.only(bottom: AppSpacing.md - 2), // 6
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: borderStrokeColor,
            width: isFocused ? 2.0 : 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedRotation(
            turns: arrowTurns,
            duration: AppMotion.duration(
              context,
              const Duration(milliseconds: 300),
            ),
            curve: AppMotion.curveOut,
            child: TweenAnimationBuilder<Color?>(
              duration: AppMotion.duration(
                context,
                const Duration(milliseconds: 300),
              ),
              tween: ColorTween(
                end: isError
                    ? AppColors.bronzeError
                    : (widget.intent == AmountInputIntent.gold
                        ? AppColors.goldStandard500
                        : (widget.intent == AmountInputIntent.purple
                            ? AppColors.purplePower500
                            : AppColors.slate)),
              ),
              builder: (context, color, child) {
                return Icon(
                  Icons.arrow_upward_rounded,
                  size: 16,
                  color: color,
                );
              },
            ),
          ),
          const SizedBox(width: AppSpacing.md - 2), // 6
          Text(
            widget.currency,
            style: AppTextStyles.bodyBold.copyWith(
              fontSize: 14,
              color: AppColors.slate,
            ),
          ),
          const SizedBox(width: AppSpacing.md), // 8
          SizedBox(
            width: 160,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                final textToMeasure = controller.text.isEmpty ? '0' : controller.text;

                final baseStyle = AppTextStyles.obviouslyLargeText.copyWith(
                  fontSize: 48,
                );

                final textPainter = TextPainter(
                  text: TextSpan(text: textToMeasure, style: baseStyle),
                  textDirection: TextDirection.ltr,
                  maxLines: 1,
                )..layout();

                final naturalWidth = textPainter.width;
                const baseFontSize = 48.0;
                const minFontSize = 18.0;

                final scale = naturalWidth > maxWidth ? maxWidth / naturalWidth : 1.0;
                final fontSize = (baseFontSize * scale).clamp(minFontSize, baseFontSize);

                final amountStyle = AppTextStyles.obviouslyLargeText.copyWith(
                  fontSize: fontSize,
                  color: textGradient != null ? Colors.white : fallbackColor,
                );

                final Widget textField = TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: _handleChanged,
                  textAlign: TextAlign.left,
                  style: amountStyle.copyWith(color: Colors.transparent),
                  cursorColor: isError ? AppColors.bronzeError : AppColors.obsidian,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: controller.text.isEmpty ? '0' : null,
                    hintStyle: amountStyle.copyWith(
                      color: textGradient != null
                          ? Colors.white.withValues(alpha: 0.3)
                          : fallbackColor.withValues(alpha: 0.3),
                    ),
                  ),
                );

                final Widget animatedText = AnimatedAmountText(
                  text: controller.text,
                  style: amountStyle,
                  enableAnimation: widget.enableTextAnimation,
                );

                final shadedAmountText = (textGradient != null && widget.enableGradient)
                    ? ShaderMask(
                        shaderCallback: (bounds) => textGradient.createShader(bounds),
                        child: animatedText,
                      )
                    : animatedText;

                return SizedBox(
                  height: 58,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      clipBehavior: Clip.hardEdge,
                      children: [
                        if (controller.text.isNotEmpty)
                          IgnorePointer(child: shadedAmountText),
                        textField,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isError = widget.state == AmountInputState.error;
    final colors = _resolveColors(isError);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMotion(
          _buildInputArea(
            isError: isError,
            fallbackColor: colors.fallback,
            textGradient: colors.gradient,
          ),
        ),
        const SizedBox(height: AppSpacing.lg), // 12
        if (widget.nudgeText != null)
          SavChip(
            label: widget.nudgeText!,
            tone: SavChipTone.neutral,
            trailingWidget: const Icon(
              Icons.info_outline_rounded,
              size: 14,
              color: AppColors.slate,
            ),
          ),
        if (widget.helperText != null) ...[
          const SizedBox(height: AppSpacing.md), // 8
          Text(
            widget.helperText!,
            style: AppTextStyles.captionRegular.copyWith(
              color: isError ? AppColors.bronzeError : AppColors.slate,
            ),
          ),
        ],
      ],
    );
  }
}

class AnimatedAmountText extends StatelessWidget {
  const AnimatedAmountText({
    required this.text,
    required this.style,
    this.enableAnimation = true,
    super.key,
  });
  final String text;
  final TextStyle style;
  final bool enableAnimation;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    final reduceMotion = AppMotion.reduce(context);
    final chars = text.split('');
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(chars.length, (index) {
          final char = chars[index];
          return AnimatedSwitcher(
            duration: (reduceMotion || !enableAnimation)
                ? Duration.zero
                : const Duration(milliseconds: 150),
            switchInCurve: AppMotion.curveOut,
            switchOutCurve: AppMotion.curveGentleOut,
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                alignment: Alignment.centerLeft,
                children: <Widget>[
                  ...previousChildren,
                  ?currentChild,
                ],
              );
            },
            transitionBuilder: (child, animation) {
              if (reduceMotion || !enableAnimation) {
                return FadeTransition(opacity: animation, child: child);
              }
              final isEntering = child.key == ValueKey('${index}_$char');
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0, isEntering ? 0.25 : -0.25),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(
              char,
              key: ValueKey('${index}_$char'),
              style: style,
            ),
          );
        }),
      ),
    );
  }
}
