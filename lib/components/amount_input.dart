import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../core/tokens.dart';
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
  });

  final String currency;
  final AmountInputIntent intent;
  final AmountInputState state;
  final String? helperText;
  final String? nudgeText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;

  @override
  State<AmountInput> createState() => _AmountInputState();
}

class _AmountInputState extends State<AmountInput> with TickerProviderStateMixin {
  late final TextEditingController _controller = widget.controller ?? TextEditingController();
  late final FocusNode _focusNode = widget.focusNode ?? FocusNode();
  bool _isFocused = false;

  late final AnimationController _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
  late final AnimationController _scaleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChange);
  }

  @override
  void didUpdateWidget(AmountInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == AmountInputState.error && oldWidget.state != AmountInputState.error) {
      if (!AppMotion.reduce(context)) _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.removeListener(_onTextChange);
    if (widget.focusNode == null) _focusNode.dispose();
    if (widget.controller == null) _controller.dispose();
    _shakeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!mounted) return;
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    if (!_isFocused && !AppMotion.reduce(context)) {
      // Scale on commit
      _scaleController.forward(from: 0).then((_) {
        if (mounted) _scaleController.reverse();
      });
    }
  }

  void _onTextChange() {
    if (!mounted) return;
    setState(() {});
  }

  void _handleChanged(String value) {
    if (mounted && !AppMotion.reduce(context)) {
       // subtle scale shift on change
       _scaleController.forward(from: 0.5).then((_) {
         if (mounted) _scaleController.reverse();
       });
    }
    if (widget.onChanged != null) widget.onChanged!(value);
  }

  Widget _buildMotion(Widget child) {
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
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isError = widget.state == AmountInputState.error;

    // Define gradients based on intent
    LinearGradient? textGradient;
    Color fallbackColor = AppColors.obsidian;

    if (isError) {
      fallbackColor = AppColors.bronzeError;
    } else {
      switch (widget.intent) {
        case AmountInputIntent.gold:
          textGradient = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.3016, 0.6919, 0.8871],
            colors: [
              AppColors.goldStandard800,
              AppColors.goldStandard700,
              AppColors.goldStandard500,
            ],
          );
          break;
        case AmountInputIntent.purple:
          textGradient = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.3016, 0.6919, 0.8871],
            colors: [
              AppColors.purplePower800,
              AppColors.purplePower700,
              AppColors.purplePower500,
            ],
          );
          break;
        case AmountInputIntent.neutral:
          fallbackColor = AppColors.obsidian;
          break;
      }
    }

    final Color borderStrokeColor = isError
        ? AppColors.bronzeError
        : (_isFocused ? AppColors.obsidian : AppColors.hairline);

    // Main text style for numbers (Obviously Narrow Semibold)
    final TextStyle amountStyle = AppTextStyles.obviouslyNarrow.copyWith(
      fontSize: 48,
      color: textGradient != null ? Colors.white : fallbackColor,
    );

    final Widget textField = TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: _handleChanged,
      textAlign: TextAlign.left,
      style: amountStyle.copyWith(color: Colors.transparent),
      cursorColor: isError ? AppColors.bronzeError : AppColors.obsidian,
      cursorWidth: 2.0,
      decoration: InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
        hintText: _controller.text.isEmpty ? '0' : null,
        hintStyle: amountStyle.copyWith(
          color: textGradient != null ? Colors.white.withOpacity(0.3) : fallbackColor.withOpacity(0.3),
        ),
      ),
    );

    // Render the animated characters
    final Widget animatedText = AnimatedAmountText(
      text: _controller.text,
      style: amountStyle,
    );

    // Apply gradient text mask if needed
    final Widget shadedAmountText = textGradient != null
        ? ShaderMask(
            shaderCallback: (bounds) => textGradient!.createShader(bounds),
            child: animatedText,
          )
        : animatedText;

    final double arrowTurns = isError 
        ? 0.75 
        : (widget.intent == AmountInputIntent.purple ? 0.5 : 0.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildMotion(
          AnimatedContainer(
            duration: AppMotion.duration(context, const Duration(milliseconds: 200)),
            curve: AppMotion.curveOut,
            width: 260,
            padding: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: borderStrokeColor,
                  width: _isFocused ? 2.0 : 1.0,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedRotation(
                  turns: arrowTurns,
                  duration: AppMotion.duration(context, const Duration(milliseconds: 300)),
                  curve: AppMotion.curveOut,
                  child: TweenAnimationBuilder<Color?>(
                    duration: AppMotion.duration(context, const Duration(milliseconds: 300)),
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
                const SizedBox(width: 6),
                Text(
                  widget.currency,
                  style: AppTextStyles.bodyBold.copyWith(
                    fontSize: 14,
                    color: AppColors.slate,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 160,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      if (_controller.text.isNotEmpty)
                        IgnorePointer(
                          child: shadedAmountText,
                        ),
                      textField,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
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
          const SizedBox(height: 8),
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
  final String text;
  final TextStyle style;

  const AnimatedAmountText({
    super.key,
    required this.text,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    final reduceMotion = AppMotion.reduce(context);
    final chars = text.split('');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(chars.length, (index) {
        final char = chars[index];
        return AnimatedSwitcher(
          duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 150),
          switchInCurve: AppMotion.curveOut,
          switchOutCurve: AppMotion.curveGentleOut,
          layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
            return Stack(
              alignment: Alignment.centerLeft,
              children: <Widget>[
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          transitionBuilder: (child, animation) {
            if (reduceMotion) {
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
    );
  }
}
