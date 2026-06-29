import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../core/noise.dart';
import '../core/squircle.dart';
import '../core/tokens.dart';
import 'internal/disabled_fade.dart';
import 'morphing_text.dart';

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
    this.textStyle,
    this.shadows = true,
    this.showNoise = true,
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
  final TextStyle? textStyle;
  final bool shadows;
  final bool showNoise;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController.unbounded(
    vsync: this,
  );

  static const _tapDownScale = 0.94;
  static const _tapUpScale = 1.0;
  static const double _scaleDelta = _tapDownScale - _tapUpScale;

  bool get _enabled =>
      widget.onPressed != null && widget.state == AppButtonState.normal;
  bool get _loading => widget.state == AppButtonState.loading;

  void _press(_) {
    if (AppMotion.reduce(context)) {
      _controller.value = 1.0;
    } else {
      _controller.animateWith(
        SpringSimulation(
          AppMotion.springInteractive,
          _controller.value,
          1,
          _controller.velocity,
        ),
      );
    }
    HapticFeedback.lightImpact();
  }

  void _release([_]) {
    if (AppMotion.reduce(context)) {
      _controller.value = 0.0;
    } else {
      _controller.animateWith(
        SpringSimulation(
          AppMotion.springInteractive,
          _controller.value,
          0,
          _controller.velocity,
        ),
      );
    }
  }

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

  Widget _buildContent(
    AppButtonSizeTokens sizeTokens,
    AppButtonStyleTokens style,
    Color textIconColor,
  ) {
    final isIconOnly = widget.icon == AppButtonIcon.iconOnly;
    final showLeading = widget.icon == AppButtonIcon.leading;
    final showTrailing = widget.icon == AppButtonIcon.trailing;
    final showLabel = widget.icon != AppButtonIcon.iconOnly;

    final content = <Widget>[
      if (showLeading)
        _iconSlot(widget.leading, sizeTokens.iconSize, textIconColor),
      if (showLabel)
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppButtonTokens.labelInsetX,
          ),
          child: MorphingText(
            text: widget.label,
            style: (widget.textStyle ?? sizeTokens.textStyle).copyWith(color: textIconColor),
          ),
        ),
      if (showTrailing)
        _iconSlot(widget.trailing, sizeTokens.iconSize, textIconColor),
    ];

    final Widget rowWidget = Row(
      mainAxisSize: (widget.width == AppButtonWidth.full && !isIconOnly)
          ? MainAxisSize.max
          : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: sizeTokens.gap,
      children: content,
    );

    if (widget.variant == AppButtonVariant.inline &&
        widget.labelColor == null) {
      return ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.lushCapital800,
            AppColors.lushCapital600,
            AppColors.lushCapital500,
          ],
        ).createShader(bounds),
        child: rowWidget,
      );
    }
    return rowWidget;
  }

  Decoration _buildDecoration(
    AppButtonStyleTokens style,
    Color? resolvedFillColor,
    Color? resolvedStrokeColor,
  ) {
    return switch (widget.variant) {
      AppButtonVariant.primary => SavSurface(
        curvature: style.curvature,
        fillColor: resolvedFillColor,
        fillGradient: resolvedFillColor != null ? null : style.bgGradient,
        strokeWidth: style.strokeWidth,
        strokeGradient: resolvedStrokeColor != null
            ? LinearGradient(colors: [resolvedStrokeColor, resolvedStrokeColor])
            : (style.strokeGradient ?? AppButtonTokens.primaryStrokeGradient),
        strokeSoftLight: true,
        shadows: widget.shadows ? style.shadows : null,
      ),
      AppButtonVariant.secondary => SavSurface(
        curvature: style.curvature,
        fillColor: resolvedFillColor ?? Colors.white,
        strokeColor: resolvedStrokeColor ?? AppColors.hairline,
        strokeWidth: style.strokeWidth,
        dropShadowColor: widget.shadows ? AppColors.transparent4 : Colors.transparent,
        dropShadowOffset: const Offset(1, 1),
        dropShadowBlur: 1.5,
        innerShadowColor: widget.shadows ? AppColors.transparent6 : Colors.transparent,
        innerShadowOffset: const Offset(-1, -1),
        innerShadowBlur: 1.5,
      ),
      AppButtonVariant.inline => const BoxDecoration(color: Colors.transparent),
    };
  }

  Widget _buildDecoratedButton(
    AppButtonSizeTokens sizeTokens,
    AppButtonStyleTokens style,
    Color textIconColor,
    Decoration decoration,
    double? buttonWidth,
    Color resolvedLabelColor,
  ) {
    final isIconOnly = widget.icon == AppButtonIcon.iconOnly;

    return RepaintBoundary(
      child: NoiseLayer(
        enabled: style.noiseEnabled && widget.showNoise,
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
              child: AnimatedSwitcher(
                duration: AppMotion.duration(context, AppMotion.durationHigh),
                switchInCurve: AppMotion.curveOut,
                switchOutCurve: AppMotion.curveGentleOut,
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  );
                },
                transitionBuilder: (child, animation) {
                  final isEntering = child.key == const ValueKey('loading');
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(
                        begin: isEntering ? 0.8 : 0.9,
                        end: 1,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _loading
                    ? SizedBox(
                        key: const ValueKey('loading'),
                        width: sizeTokens.iconSize,
                        height: sizeTokens.iconSize,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: resolvedLabelColor,
                        ),
                      )
                    : SizedBox(
                        key: const ValueKey('content'),
                        child: isIconOnly
                            ? Center(
                                child: _iconSlot(
                                  widget.leading,
                                  sizeTokens.iconSize,
                                  textIconColor,
                                ),
                              )
                            : _buildContent(sizeTokens, style, textIconColor),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sizeTokens = AppButtonSizeTokens.resolve(widget.size);
    final style = AppButtonStyleTokens.resolve(widget.variant, widget.size);

    final resolvedFillColor = widget.fillColor ?? style.fillColor;
    final resolvedLabelColor = widget.labelColor ?? style.labelColor;
    final resolvedStrokeColor = widget.strokeColor ?? style.strokeColor;

    final isIconOnly = widget.icon == AppButtonIcon.iconOnly;
    final buttonWidth = switch (widget.width) {
      AppButtonWidth.full => double.infinity,
      AppButtonWidth.half => null,
      AppButtonWidth.hug => isIconOnly ? sizeTokens.height : null,
    };

    final textIconColor =
        (widget.variant == AppButtonVariant.inline && widget.labelColor == null)
        ? Colors.white
        : resolvedLabelColor;

    final decoration = _buildDecoration(
      style,
      resolvedFillColor,
      resolvedStrokeColor,
    );

    final button = _buildDecoratedButton(
      sizeTokens,
      style,
      textIconColor,
      decoration,
      buttonWidth,
      resolvedLabelColor,
    );

    final Widget displayWidget;
    if (widget.width == AppButtonWidth.full) {
      displayWidget = SizedBox(width: double.infinity, child: button);
    } else if (widget.width == AppButtonWidth.half && !isIconOnly) {
      displayWidget = FractionallySizedBox(widthFactor: 0.5, child: button);
    } else {
      displayWidget = button;
    }

    final Widget opacityWidget = DisabledFade(
      disabled: widget.state == AppButtonState.disabled,
      child: displayWidget,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _enabled ? _press : null,
      onTapUp: _enabled ? _release : null,
      onTapCancel: _enabled ? _release : null,
      onTap: _enabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale =
              _tapUpScale +
              (_scaleDelta *
                  _controller.value *
                  AppButtonTokens.pressSensitivity);
          Widget current = child!;
          if (widget.variant == AppButtonVariant.inline) {
            current = Opacity(
              opacity: (1.0 - (0.3 * _controller.value)).clamp(0.0, 1.0),
              child: current,
            );
          } else {
            current = Stack(
              alignment: Alignment.center,
              children: [
                current,
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: ShapeDecoration(
                        shape: SquircleBorder(
                          curvature: style.curvature,
                          strokeWidth: 0,
                          strokeGradient: const LinearGradient(
                            colors: [Colors.transparent, Colors.transparent],
                          ),
                        ),
                        color: Colors.black.withValues(
                          alpha: (0.08 * _controller.value).clamp(0.0, 1.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return Transform.scale(
            scale: scale,
            child: current,
          );
        },
        child: opacityWidget,
      ),
    );
  }
}
