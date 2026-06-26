import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../core/tokens.dart';
import 'internal/managed_field_state.dart';

enum OTPInputState { normal, error }

class OTPInput extends StatefulWidget {
  const OTPInput({
    super.key,
    this.length = 6,
    this.state = OTPInputState.normal,
    this.controller,
    this.onChanged,
    this.onCompleted,
  });

  final int length;
  final OTPInputState state;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  @override
  State<OTPInput> createState() => _OTPInputState();
}

class _OTPInputState extends State<OTPInput>
    with TickerProviderStateMixin, ManagedFieldStateMixin<OTPInput> {
  @override
  FocusNode? get widgetFocusNode => null; // OTPInput creates its own focus node
  @override
  TextEditingController? get widgetController => widget.controller;

  bool _wasCompleted = false;

  late final AnimationController _shakeController =
      AnimationController.unbounded(vsync: this);
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final Animation<double> _pulseAnimation = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 1,
        end: 1.04,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 50,
    ),
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 1.04,
        end: 1,
      ).chain(CurveTween(curve: Curves.easeIn)),
      weight: 50,
    ),
  ]).animate(_pulseController);

  @override
  void initState() {
    super.initState();
    _wasCompleted = controller.text.length == widget.length;
  }

  @override
  void didUpdateWidget(OTPInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == OTPInputState.error &&
        oldWidget.state != OTPInputState.error) {
      if (!AppMotion.reduce(context)) {
        const spring = SpringDescription(mass: 1, stiffness: 200, damping: 6);
        _shakeController.animateWith(SpringSimulation(spring, 10, 0, 0));
      }
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void onTextChanged() {
    final text = controller.text;
    if (text.length == widget.length && !_wasCompleted) {
      _wasCompleted = true;
      if (!AppMotion.reduce(context)) {
        _pulseController.forward(from: 0);
      }
      widget.onCompleted?.call(text);
    } else if (text.length < widget.length) {
      _wasCompleted = false;
    }
    widget.onChanged?.call(text);
  }

  Widget _buildCell(int index, String value, bool isError, bool reduceMotion) {
    final isCurrent = index == value.length;
    final isFilled = index < value.length;
    final isActive = isCurrent && isFocused;

    final char = isFilled ? value[index] : '';

    Widget cellContent;
    if (char.isNotEmpty) {
      final textWidget = Text(
        char,
        key: ValueKey(char),
        style: AppTextStyles.obviouslyOtp.copyWith(
          color: Colors.white,
        ),
      );

      cellContent = isError
          ? Text(
              char,
              key: ValueKey(char),
              style: AppTextStyles.obviouslyOtp.copyWith(
                color: AppColors.bronzeError,
              ),
            )
          : ShaderMask(
              shaderCallback: (bounds) => AppGradients.otpTextGradient.createShader(
                Rect.fromLTWH(0, 0, bounds.width, bounds.height),
              ),
              child: textWidget,
            );
    } else {
      cellContent = Text(
        '-',
        key: const ValueKey('empty'),
        style: AppTextStyles.obviouslyOtp.copyWith(
          color: isError ? AppColors.bronzeError : AppColors.sterling,
        ),
      );
    }

    return AnimatedScale(
      scale: (isActive && !reduceMotion) ? 1.08 : 1.0,
      duration: AppMotion.duration(context, AppMotion.durationHigh),
      curve: AppMotion.curveOut,
      child: Container(
        height: 61,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: AnimatedSwitcher(
          duration: AppMotion.duration(context, AppMotion.durationHigh),
          transitionBuilder: (child, animation) {
            if (reduceMotion) {
              return FadeTransition(opacity: animation, child: child);
            }
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.85, end: 1).animate(animation),
                child: child,
              ),
            );
          },
          child: cellContent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final value = controller.text;
    final isError = widget.state == OTPInputState.error;
    final reduceMotion = AppMotion.reduce(context);

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          if (!focusNode.hasFocus) {
            focusNode.requestFocus();
          }
        },
        child: Stack(
          children: [
            SizedBox.shrink(
              child: Opacity(
                opacity: 0,
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(widget.length),
                  ],
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                final offset = reduceMotion ? 0.0 : _shakeController.value;
                return Transform.translate(
                  offset: Offset(offset, 0),
                  child: child,
                );
              },
              child: ScaleTransition(
                scale: _pulseAnimation,
                child: Row(
                  spacing: 4,
                  children: List.generate(
                    widget.length,
                    (index) => Expanded(
                      child: _buildCell(index, value, isError, reduceMotion),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
