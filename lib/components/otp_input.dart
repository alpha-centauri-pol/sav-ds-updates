import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/physics.dart';
import '../core/squircle.dart';
import '../core/tokens.dart';

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

class _OTPInputState extends State<OTPInput> with TickerProviderStateMixin {
  late final TextEditingController _controller = widget.controller ?? TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _wasCompleted = false;

  late final AnimationController _shakeController = AnimationController.unbounded(vsync: this, value: 0.0);
  late final AnimationController _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  late final Animation<double> _pulseAnimation = TweenSequence<double>([
    TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.04).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
    TweenSequenceItem(tween: Tween<double>(begin: 1.04, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 50),
  ]).animate(_pulseController);

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChanged);
    _wasCompleted = _controller.text.length == widget.length;
  }

  @override
  void didUpdateWidget(OTPInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == OTPInputState.error && oldWidget.state != OTPInputState.error) {
      if (!AppMotion.reduce(context)) {
        final spring = SpringDescription(mass: 1, stiffness: 200, damping: 6);
        _shakeController.animateWith(SpringSimulation(spring, 10.0, 0.0, 0.0));
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) _controller.dispose();
    _focusNode.dispose();
    _shakeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!mounted) return;
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _onTextChanged() {
    if (!mounted) return;
    final text = _controller.text;
    if (text.length == widget.length && !_wasCompleted) {
      _wasCompleted = true;
      if (!AppMotion.reduce(context)) {
        _pulseController.forward(from: 0.0);
      }
      if (widget.onCompleted != null) widget.onCompleted!(text);
    } else if (text.length < widget.length) {
      _wasCompleted = false;
    }
    if (widget.onChanged != null) widget.onChanged!(text);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final String value = _controller.text;
    final bool isError = widget.state == OTPInputState.error;
    final bool reduceMotion = AppMotion.reduce(context);

    return RepaintBoundary(
      child: GestureDetector(
      onTap: () {
        if (!_focusNode.hasFocus) {
          _focusNode.requestFocus();
        }
      },
      child: Stack(
        children: [
          // Invisible text field
          SizedBox(
            width: 0,
            height: 0,
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.length),
                ],
              ),
            ),
          ),
          // Row of visual cells
          AnimatedBuilder(
            animation: _shakeController,
            builder: (context, child) {
              final double offset = reduceMotion ? 0.0 : _shakeController.value;
              return Transform.translate(
                offset: Offset(offset, 0),
                child: child,
              );
            },
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(widget.length, (index) {
                  final isCurrent = index == value.length;
                  final isFilled = index < value.length;
                  final isActive = isCurrent && _isFocused;

                  // Border colors
                  Color borderColor = AppColors.hairline;
                  if (isError) {
                    borderColor = AppColors.bronzeError;
                  } else if (isActive) {
                    borderColor = AppColors.obsidian;
                  }

                  final String char = isFilled ? value[index] : '';

                  return AnimatedScale(
                    scale: (isActive && !reduceMotion) ? 1.05 : 1.0,
                    duration: AppMotion.duration(context, AppMotion.durationHigh),
                    curve: AppMotion.curveOut,
                    child: AnimatedContainer(
                      duration: AppMotion.duration(context, AppMotion.durationHigh),
                      curve: AppMotion.curveOut,
                      width: 44,
                      height: 48,
                      decoration: SavSurface(
                        curvature: 8,
                        fillColor: Colors.white,
                        strokeColor: borderColor,
                        strokeWidth: isActive || isError ? 1.5 : 1.0,
                        dropShadowColor: isError
                            ? AppColors.bronzeError.withOpacity(0.08)
                            : (isActive ? AppColors.obsidian.withOpacity(0.08) : const Color(0x051F1F1F)),
                        dropShadowOffset: isActive ? const Offset(0, 2) : const Offset(0, 1),
                        dropShadowBlur: isActive ? 8.0 : 1.0,
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: AppMotion.duration(context, AppMotion.durationHigh),
                          transitionBuilder: (child, animation) {
                            if (reduceMotion) {
                              return FadeTransition(opacity: animation, child: child);
                            }
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: Tween(begin: 0.85, end: 1.0).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: char.isNotEmpty
                              ? Text(
                                  char,
                                  key: ValueKey(char),
                                  style: AppTextStyles.bodyBold.copyWith(
                                    fontSize: 18,
                                    color: AppColors.obsidian,
                                  ),
                                )
                              : Text(
                                  '—',
                                  key: const ValueKey('empty'),
                                  style: AppTextStyles.bodyRegular.copyWith(
                                    color: isError ? AppColors.bronzeError : AppColors.sterling,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
