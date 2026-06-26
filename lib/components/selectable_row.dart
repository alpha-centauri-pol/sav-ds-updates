import 'package:flutter/material.dart';
import '../core/tokens.dart';
import 'internal/disabled_fade.dart';

enum SelectableRowIndicator { checkmark, radioDot }

enum SelectableRowState { normal, disabled }

class SelectableRow extends StatefulWidget {
  const SelectableRow({
    required this.label,
    super.key,
    this.onTap,
    this.secondary,
    this.indicator = SelectableRowIndicator.checkmark,
    this.selected = false,
    this.divider = true,
    this.state = SelectableRowState.normal,
    this.leadingWidget,
  });

  final String label;
  final VoidCallback? onTap;
  final String? secondary;
  final SelectableRowIndicator indicator;
  final bool selected;
  final bool divider;
  final SelectableRowState state;
  final Widget? leadingWidget;

  @override
  State<SelectableRow> createState() => _SelectableRowState();
}

class _SelectableRowState extends State<SelectableRow>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late final AnimationController _flashController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final Animation<double> _flashAnimation = Tween<double>(begin: 1, end: 0)
      .animate(
        CurvedAnimation(parent: _flashController, curve: Curves.easeOut),
      );

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.state != SelectableRowState.disabled) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.state != SelectableRowState.disabled) {
      setState(() => _isPressed = false);
    }
  }

  void _handleTapCancel() {
    if (widget.state != SelectableRowState.disabled) {
      setState(() => _isPressed = false);
    }
  }

  void _handleTap() {
    if (widget.state != SelectableRowState.disabled) {
      if (!AppMotion.reduce(context)) {
        _flashController.forward(from: 0);
      }
      widget.onTap?.call();
    }
  }

  Widget _buildCheckmarkIndicator(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: AppMotion.duration(context, AppMotion.durationHigh),
      curve: AppMotion.curveOut,
      tween: Tween<double>(begin: 0, end: widget.selected ? 1.0 : 0.0),
      builder: (context, progress, child) {
        return SizedBox(
          width: 20,
          height: 20,
          child: CustomPaint(
            painter: CheckmarkPainter(
              progress: progress,
              color: AppColors.obsidian,
            ),
          ),
        );
      },
    );
  }

  Widget _buildRadioDotIndicator(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.duration(context, AppMotion.durationHigh),
      curve: AppMotion.curveOut,
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: widget.selected ? AppColors.obsidian : AppColors.hairline,
          width: 2,
        ),
      ),
      child: Center(
        child: AnimatedScale(
          scale: widget.selected ? 1.0 : 0.0,
          duration: AppMotion.duration(
            context,
            const Duration(milliseconds: 220),
          ),
          curve: SpringCurve(AppMotion.springDefault),
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.obsidian,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(BuildContext context) {
    return switch (widget.indicator) {
      SelectableRowIndicator.checkmark => _buildCheckmarkIndicator(context),
      SelectableRowIndicator.radioDot => _buildRadioDotIndicator(context),
    };
  }

  Widget _buildRowContent(BuildContext context, Widget indicatorWidget) {
    return Row(
      children: [
        // Leading slot
        if (widget.leadingWidget != null) ...[
          widget.leadingWidget!,
          const SizedBox(width: 12),
        ],
        // Label and secondary subtext column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: AppTextStyles.bodyBold.copyWith(
                  color: AppColors.obsidian,
                ),
              ),
              if (widget.secondary != null) ...[
                const SizedBox(height: 2),
                Text(
                  widget.secondary!,
                  style: AppTextStyles.captionRegular.copyWith(
                    color: AppColors.slate,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Indicator
        indicatorWidget,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.state == SelectableRowState.disabled;
    final indicatorWidget = _buildIndicator(context);
    final rowContent = _buildRowContent(context, indicatorWidget);

    final Widget buildWidget = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: isDisabled ? null : _handleTap,
      child: AnimatedBuilder(
        animation: _flashController,
        builder: (context, child) {
          final flashOpacity = _flashAnimation.value * 0.08;
          final color = _isPressed
              ? AppColors.darkTransparent4
              : (_flashController.isAnimating
                    ? Colors.black.withValues(alpha: flashOpacity)
                    : Colors.transparent);
          return Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: color,
              border: widget.divider
                  ? const Border(
                      bottom: BorderSide(
                        color: AppColors.hairline,
                      ),
                    )
                  : null,
            ),
            child: child,
          );
        },
        child: rowContent,
      ),
    );

    return RepaintBoundary(
      child: DisabledFade(
        disabled: isDisabled,
        child: buildWidget,
      ),
    );
  }
}

class CheckmarkPainter extends CustomPainter {
  CheckmarkPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 2.0,
  });
  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.25, size.height * 0.5)
      ..lineTo(size.width * 0.42, size.height * 0.7)
      ..lineTo(size.width * 0.78, size.height * 0.3);

    final pathMetrics = path.computeMetrics();
    final totalLength = pathMetrics.fold<double>(
      0,
      (prev, metric) => prev + metric.length,
    );
    final targetLength = totalLength * progress;

    double currentLength = 0;
    final animatedPath = Path();

    for (final metric in pathMetrics) {
      if (currentLength >= targetLength) break;
      final remainingLength = targetLength - currentLength;
      if (remainingLength >= metric.length) {
        animatedPath.addPath(metric.extractPath(0, metric.length), Offset.zero);
        currentLength += metric.length;
      } else {
        animatedPath.addPath(
          metric.extractPath(0, remainingLength),
          Offset.zero,
        );
        currentLength += remainingLength;
      }
    }

    canvas.drawPath(animatedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
