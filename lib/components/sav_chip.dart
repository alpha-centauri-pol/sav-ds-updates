import 'package:flutter/material.dart';
import '../core/squircle.dart';
import '../core/noise.dart';
import '../core/tokens.dart';

enum SavChipSize { sm, lg }
enum SavChipTone { neutralDefault, neutral, success, negative, info }

class SavChip extends StatefulWidget {
  const SavChip({
    super.key,
    required this.label,
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

  @override
  State<SavChip> createState() => _SavChipState();
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

  @override
  Widget build(BuildContext context) {
    final double height = widget.size == SavChipSize.sm ? 24.0 : 36.0;
    final double padX = widget.size == SavChipSize.sm ? 6.0 : 10.0;
    final double gap = widget.size == SavChipSize.sm ? 4.0 : 6.0;
    final int curvature = widget.size == SavChipSize.sm ? 6 : 10;
    final double fontSize = widget.size == SavChipSize.sm ? 12.0 : 14.0;
    final double leadingContainerSize = widget.size == SavChipSize.sm ? 16.0 : 22.0;
    final double leadingIconSize = widget.size == SavChipSize.sm ? 12.0 : 14.0;

    Color defaultBg = Colors.transparent;
    Color defaultFg = AppColors.obsidian;
    Color? defaultStroke;

    switch (widget.tone) {
      case SavChipTone.neutralDefault:
        defaultBg = AppColors.white;
        defaultFg = AppColors.obsidian;
        defaultStroke = AppColors.transparent12;
        break;
      case SavChipTone.neutral:
        defaultBg = AppColors.transparent8;
        defaultFg = AppColors.slate;
        defaultStroke = null;
        break;
      case SavChipTone.success:
        defaultBg = AppColors.lushCapital100;
        defaultFg = AppColors.lushCapital600;
        defaultStroke = null;
        break;
      case SavChipTone.negative:
        defaultBg = AppColors.bronzeBounty100;
        defaultFg = AppColors.bronzeBounty600;
        defaultStroke = null;
        break;
      case SavChipTone.info:
        defaultBg = AppColors.wealthWeave100;
        defaultFg = AppColors.wealthWeave600;
        defaultStroke = null;
        break;
    }

    final bg = widget.fillColor ?? defaultBg;
    final fg = widget.labelColor ?? defaultFg;
    final stroke = widget.strokeColor ?? defaultStroke;

    Widget? leading;
    if (widget.leadingWidget != null) {
      leading = widget.leadingWidget;
    } else if (widget.leadingIcon != null) {
      leading = Container(
        width: leadingContainerSize,
        height: leadingContainerSize,
        decoration: SavSurface(
          curvature: widget.size == SavChipSize.sm ? 4 : 6,
          fillColor: AppColors.transparent4,
        ),
        child: Center(
          child: Icon(
            widget.leadingIcon,
            size: leadingIconSize,
            color: widget.leadingIconColor ?? fg,
          ),
        ),
      );
    }

    final content = Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: padX),
      decoration: SavSurface(
        curvature: curvature,
        fillColor: bg,
        strokeColor: stroke,
        strokeWidth: stroke != null ? 1.0 : 0.0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[
            leading,
            SizedBox(width: gap),
          ],
          Text(
            widget.label,
            style: AppTextStyles.chipLabel(fontSize).copyWith(color: fg),
          ),
          if (widget.trailingWidget != null) ...[
            SizedBox(width: gap),
            widget.trailingWidget!,
          ],
        ],
      ),
    );

    Widget displayWidget = content;
    if (widget.showLgNoise && widget.size == SavChipSize.lg && widget.tone == SavChipTone.neutralDefault) {
      displayWidget = NoiseLayer(
        enabled: true,
        opacity: 0.8,
        scale: 0.5,
        curvature: curvature,
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
