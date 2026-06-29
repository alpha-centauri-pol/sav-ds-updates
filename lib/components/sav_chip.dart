import 'package:flutter/material.dart';

import '../core/noise.dart';
import '../core/squircle.dart';
import '../core/tokens.dart';

enum SavChipSize { sm, lg }

enum SavChipTone { neutralDefault, neutral, success, negative, info }

class SavChip extends StatefulWidget {
  const SavChip({
    required this.label,
    super.key,
    this.size = SavChipSize.sm,
    this.tone = SavChipTone.neutralDefault,
    this.leadingIcon,
    this.leadingIconColor,
    this.leadingWidget,
    this.trailingWidget,
    this.fillColor,
    this.labelColor,
    this.strokeColor,
    this.showLgNoise = false,
    this.animateEntry = false,
    this.entryDelay,
    this.enableSurface = true,
  });

  final String label;
  final SavChipSize size;
  final SavChipTone tone;
  final IconData? leadingIcon;
  final Color? leadingIconColor;
  final Widget? leadingWidget;
  final Widget? trailingWidget;
  final Color? fillColor;
  final Color? labelColor;
  final Color? strokeColor;
  final bool showLgNoise;
  final bool animateEntry;
  final Duration? entryDelay;
  final bool enableSurface;

  @override
  State<SavChip> createState() => _SavChipState();
}

class SavChipTokens {
  const SavChipTokens({
    required this.height,
    required this.padX,
    required this.gap,
    required this.curvature,
    required this.fontSize,
    required this.leadingContainerSize,
    required this.leadingIconSize,
  });
  final double height;
  final double padX;
  final double gap;
  final int curvature;
  final double fontSize;
  final double leadingContainerSize;
  final double leadingIconSize;

  static SavChipTokens resolve(SavChipSize size) => switch (size) {
        SavChipSize.sm => const SavChipTokens(
            height: 24.0,
            padX: 6.0,
            gap: 4.0,
            curvature: 6,
            fontSize: 12.0,
            leadingContainerSize: 16.0,
            leadingIconSize: 12.0,
          ),
        SavChipSize.lg => const SavChipTokens(
            height: 36.0,
            padX: 10.0,
            gap: 6.0,
            curvature: 10,
            fontSize: 14.0,
            leadingContainerSize: 22.0,
            leadingIconSize: 14.0,
          ),
      };
}

class _SavChipState extends State<SavChip> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animateEntry) {
      if (widget.entryDelay != null) {
        Future.delayed(widget.entryDelay!, () {
          if (mounted) _controller.forward();
        });
      } else {
        _controller.forward();
      }
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  (Color bg, Color fg, Color? stroke) _resolveToneColors() {
    var defaultBg = Colors.transparent;
    var defaultFg = AppColors.obsidian;
    Color? defaultStroke;

    switch (widget.tone) {
      case SavChipTone.neutralDefault:
        defaultBg = AppColors.white;
        defaultFg = AppColors.obsidian;
        defaultStroke = AppColors.transparent12;
      case SavChipTone.neutral:
        defaultBg = AppColors.transparent8;
        defaultFg = AppColors.slate;
        defaultStroke = null;
      case SavChipTone.success:
        defaultBg = AppColors.lushCapital100;
        defaultFg = AppColors.lushCapital600;
        defaultStroke = null;
      case SavChipTone.negative:
        defaultBg = AppColors.bronzeBounty100;
        defaultFg = AppColors.bronzeBounty600;
        defaultStroke = null;
      case SavChipTone.info:
        defaultBg = AppColors.wealthWeave100;
        defaultFg = AppColors.wealthWeave600;
        defaultStroke = null;
    }

    final bg = widget.fillColor ?? defaultBg;
    final fg = widget.labelColor ?? defaultFg;
    final stroke = widget.strokeColor ?? defaultStroke;
    
    return (bg, fg, stroke);
  }

  Widget? _buildLeading(SavChipTokens tokens, Color fg) {
    if (widget.leadingWidget != null) {
      return widget.leadingWidget;
    } else if (widget.leadingIcon != null) {
      return Container(
        width: tokens.leadingContainerSize,
        height: tokens.leadingContainerSize,
        decoration: widget.enableSurface ? SavSurface(
          curvature: widget.size == SavChipSize.sm ? 4 : 6,
          fillColor: AppColors.transparent4,
        ) : BoxDecoration(
          borderRadius: BorderRadius.circular(widget.size == SavChipSize.sm ? 4 : 6),
          color: AppColors.transparent4,
        ),
        child: Center(
          child: Icon(
            widget.leadingIcon,
            size: tokens.leadingIconSize,
            color: widget.leadingIconColor ?? fg,
          ),
        ),
      );
    }
    return null;
  }

  Widget _buildContent(
    SavChipTokens tokens,
    Color bg,
    Color fg,
    Color? stroke,
    Widget? leading,
  ) {
    return Container(
      height: tokens.height,
      padding: EdgeInsets.symmetric(horizontal: tokens.padX),
      decoration: widget.enableSurface ? SavSurface(
        curvature: tokens.curvature,
        fillColor: bg,
        strokeColor: stroke,
        strokeWidth: stroke != null ? 1.0 : 0.0,
      ) : BoxDecoration(
        borderRadius: BorderRadius.circular(tokens.curvature.toDouble()),
        color: bg,
        border: stroke != null ? Border.all(color: stroke, width: 1.0) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading,
            SizedBox(width: tokens.gap),
          ],
          Text(
            widget.label,
            style: AppTextStyles.bodyBold.copyWith(fontSize: tokens.fontSize, color: fg),
          ),
          if (widget.trailingWidget != null) ...[
            SizedBox(width: tokens.gap),
            widget.trailingWidget!,
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SavChipTokens.resolve(widget.size);
    final (bg, fg, stroke) = _resolveToneColors();
    final leading = _buildLeading(tokens, fg);
    final content = _buildContent(tokens, bg, fg, stroke, leading);

    Widget displayWidget = content;
    if (widget.showLgNoise &&
        widget.size == SavChipSize.lg &&
        widget.tone == SavChipTone.neutralDefault) {
      displayWidget = NoiseLayer(
        enabled: true,
        opacity: 0.8,
        scale: 0.5,
        curvature: tokens.curvature,
        child: content,
      );
    }

    if (AppMotion.reduce(context)) return displayWidget;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = AppMotion.curveOut.transform(_controller.value);
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1.0 - value)),
            child: child,
          ),
        );
      },
      child: displayWidget,
    );
  }
}
