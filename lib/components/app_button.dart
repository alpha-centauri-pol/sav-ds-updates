import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../core/squircle.dart';
import '../core/tokens.dart';
import '../core/noise.dart';

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    this.label = 'Label text',
    this.onPressed,
    this.variant = AppButtonVariant.secondary,
    this.size = AppButtonSize.regular,
    this.width = AppButtonWidth.hug,
    this.icon = AppButtonIcon.none,
    this.state = AppButtonState.normal,
    this.leading,
    this.trailing,
    this.fillColor,
    this.labelColor,
    this.strokeColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final AppButtonWidth width;
  final AppButtonIcon icon;
  final AppButtonState state;
  final Widget? leading;
  final Widget? trailing;
  final Color? fillColor;
  final Color? labelColor;
  final Color? strokeColor;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController.unbounded(vsync: this);

  static const _tapDownScale = 0.98;
  static const _tapUpScale = 1.0;
  static const _scaleDelta = _tapDownScale - _tapUpScale;
  static const _spring = SpringDescription(
    mass: 1,
    stiffness: 300,
    damping: 20,
  );

  bool get _enabled => widget.onPressed != null && widget.state == AppButtonState.normal;
  bool get _loading => widget.state == AppButtonState.loading;

  void _press(_) => _controller.animateWith(SpringSimulation(
      _spring, _controller.value, 1.0, _controller.velocity));

  void _release([_]) => _controller.animateWith(SpringSimulation(
      _spring, _controller.value, 0.0, _controller.velocity));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _defaultGlyph(double size, Color color) => Icon(
        Icons.star_border_rounded,
        size: size,
        color: color,
      );

  Widget _iconSlot(Widget? provided, double size, Color color) => SizedBox(
        width: size,
        height: size,
        child: Center(
          child: IconTheme(
            data: IconThemeData(size: size, color: color),
            child: provided ?? _defaultGlyph(size, color),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final sizeTokens = AppButtonSizeTokens.resolve(widget.size);
    final style = AppButtonStyleTokens.resolve(widget.variant, widget.size);

    final resolvedFillColor = widget.fillColor ?? style.fillColor;
    final resolvedLabelColor = widget.labelColor ?? style.labelColor;
    final resolvedStrokeColor = widget.strokeColor ?? style.strokeColor;

    final bool isIconOnly = widget.icon == AppButtonIcon.iconOnly;
    final double? buttonWidth = switch (widget.width) {
      AppButtonWidth.full => double.infinity,
      AppButtonWidth.half => null,
      AppButtonWidth.hug => isIconOnly ? sizeTokens.height : null,
    };

    final bool showLeading = widget.icon == AppButtonIcon.leading;
    final bool showTrailing = widget.icon == AppButtonIcon.trailing;
    final bool showLabel = widget.icon != AppButtonIcon.iconOnly;

    // Use white color as base for gradient ShaderMask to blend correctly
    final Color textIconColor = (widget.variant == AppButtonVariant.inline && widget.labelColor == null)
        ? Colors.white
        : resolvedLabelColor;

    final content = <Widget>[
      if (showLeading) _iconSlot(widget.leading, sizeTokens.iconSize, textIconColor),
      if (showLabel)
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppButtonTokens.labelInsetX),
          child: Text(
            widget.label,
            style: sizeTokens.textStyle.copyWith(color: textIconColor),
          ),
        ),
      if (showTrailing) _iconSlot(widget.trailing, sizeTokens.iconSize, textIconColor),
    ];

    final Widget rowWidget = Row(
      mainAxisSize: (widget.width == AppButtonWidth.full && !isIconOnly) ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: sizeTokens.gap,
      children: content,
    );

    final Widget buttonContent;
    if (widget.variant == AppButtonVariant.inline && widget.labelColor == null) {
      buttonContent = ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Color(0xFF1F3822), Color(0xFF437A61), Color(0xFF5B9A74)],
        ).createShader(bounds),
        child: rowWidget,
      );
    } else {
      buttonContent = rowWidget;
    }

    final Decoration decoration = switch (widget.variant) {
      AppButtonVariant.primary => ShapeDecoration(
          shape: SquircleBorder(
            curvature: style.curvature,
            strokeWidth: style.strokeWidth,
            strokeGradient: resolvedStrokeColor != null
                ? LinearGradient(colors: [resolvedStrokeColor, resolvedStrokeColor])
                : (style.strokeGradient ?? AppButtonTokens.primaryStrokeGradient),
          ),
          gradient: resolvedFillColor != null ? null : style.bgGradient,
          color: resolvedFillColor,
          shadows: style.shadows,
        ),
      AppButtonVariant.secondary => SecondaryDecoration(
          curvature: style.curvature,
          fillColor: resolvedFillColor ?? Colors.white,
          strokeColor: resolvedStrokeColor ?? const Color(0xFFE6E6E9),
          strokeWidth: style.strokeWidth,
        ),
      AppButtonVariant.inline => const BoxDecoration(color: Colors.transparent),
    };

    final button = RepaintBoundary(
      child: NoiseLayer(
        enabled: style.noiseEnabled,
        opacity: style.noiseOpacity,
        scale: style.noiseScale,
        curvature: style.curvature,
        child: DecoratedBox(
          decoration: decoration,
          child: SizedBox(
            height: sizeTokens.height,
            width: isIconOnly ? sizeTokens.height : buttonWidth,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isIconOnly ? 0 : sizeTokens.paddingX,
                vertical: sizeTokens.paddingY,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Visibility(
                    visible: !_loading,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: isIconOnly
                        ? Center(child: _iconSlot(widget.leading, sizeTokens.iconSize, textIconColor))
                        : buttonContent,
                  ),
                  if (_loading)
                    SizedBox(
                      width: sizeTokens.iconSize,
                      height: sizeTokens.iconSize,
                      child: CupertinoActivityIndicator(
                        radius: sizeTokens.iconSize / 2,
                        color: resolvedLabelColor,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final Widget displayWidget;
    if (widget.width == AppButtonWidth.full) {
      displayWidget = SizedBox(width: double.infinity, child: button);
    } else if (widget.width == AppButtonWidth.half && !isIconOnly) {
      displayWidget = FractionallySizedBox(widthFactor: 0.5, child: button);
    } else {
      displayWidget = button;
    }

    final Widget opacityWidget = AnimatedOpacity(
      opacity: (widget.state == AppButtonState.disabled) ? 0.4 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: displayWidget,
    );

    return GestureDetector(
      onTapDown: _enabled ? _press : null,
      onTapUp: _enabled ? _release : null,
      onTapCancel: _enabled ? _release : null,
      onTap: _enabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _tapUpScale + _scaleDelta * _controller.value,
          child: child,
        ),
        child: opacityWidget,
      ),
    );
  }
}
