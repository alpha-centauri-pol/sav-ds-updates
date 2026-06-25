import 'package:flutter/material.dart';
import '../core/squircle.dart';
import '../core/tokens.dart';

enum SegmentedControlStyle { pill, underline }
enum SegmentedControlSize { sm, md }
enum SegmentedControlContent { text, icon, iconText }

class SegmentedItem {
  const SegmentedItem({
    required this.label,
    this.icon,
    this.subtitle,
  });

  final String label;
  final IconData? icon;
  final String? subtitle;
}

class SegmentedControl extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
    this.style = SegmentedControlStyle.pill,
    this.size = SegmentedControlSize.md,
    this.content = SegmentedControlContent.text,
    this.isFullWidth = true,
  });

  final List<SegmentedItem> items;
  final int selected;
  final ValueChanged<int> onChanged;
  final SegmentedControlStyle style;
  final SegmentedControlSize size;
  final SegmentedControlContent content;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final bool isPill = style == SegmentedControlStyle.pill;
    final Curve springCurve = SpringCurve(AppMotion.springDefault);

    // Dimensions based on size
    final double height = size == SegmentedControlSize.md ? 40.0 : 32.0;
    final double fontSize = size == SegmentedControlSize.md ? 14.0 : 12.0;
    final double iconSize = size == SegmentedControlSize.md ? 18.0 : 16.0;
    final int curvature = size == SegmentedControlSize.md ? 10 : 8;

    final double alignValue = items.length > 1
        ? -1.0 + (selected * (2.0 / (items.length - 1)))
        : 0.0;

    final List<Widget> segmentButtons = List.generate(items.length, (index) {
      final item = items[index];
      final isSelected = index == selected;

      final Color fgColor = isSelected
          ? AppColors.obsidian
          : AppColors.slate;

      // Render segment content
      Widget segmentChild = const SizedBox.shrink();
      final hasIcon = content != SegmentedControlContent.text && item.icon != null;
      final hasText = content != SegmentedControlContent.icon;

      if (hasIcon && hasText) {
        segmentChild = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            TweenAnimationBuilder<Color?>(
              duration: AppMotion.duration(context, const Duration(milliseconds: 220)),
              curve: springCurve,
              tween: ColorTween(end: fgColor),
              builder: (context, color, child) => Icon(item.icon, size: iconSize, color: color),
            ),
            AnimatedDefaultTextStyle(
              duration: AppMotion.duration(context, const Duration(milliseconds: 220)),
              curve: springCurve,
              style: (isSelected ? AppTextStyles.bodyBold : AppTextStyles.bodyRegular).copyWith(
                fontSize: fontSize,
                color: fgColor,
              ),
              child: Text(item.label),
            ),
          ],
        );
      } else if (hasIcon) {
        segmentChild = TweenAnimationBuilder<Color?>(
          duration: AppMotion.duration(context, const Duration(milliseconds: 220)),
          curve: springCurve,
          tween: ColorTween(end: fgColor),
          builder: (context, color, child) => Icon(item.icon, size: iconSize, color: color),
        );
      } else if (hasText) {
        segmentChild = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedDefaultTextStyle(
              duration: AppMotion.duration(context, const Duration(milliseconds: 220)),
              curve: springCurve,
              style: (isSelected ? AppTextStyles.bodyBold : AppTextStyles.bodyRegular).copyWith(
                fontSize: fontSize,
                color: fgColor,
              ),
              child: Text(item.label),
            ),
            if (item.subtitle != null) ...[
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: AppMotion.duration(context, const Duration(milliseconds: 220)),
                curve: springCurve,
                style: AppTextStyles.captionRegular.copyWith(
                  fontSize: fontSize - 2,
                  color: AppColors.slate,
                ),
                child: Text(item.subtitle!),
              ),
            ],
          ],
        );
      }

      final Widget button = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(index),
        child: SizedBox(
          height: height,
          child: Center(child: segmentChild),
        ),
      );

      if (isFullWidth) {
        return Expanded(child: button);
      } else {
        return SizedBox(width: 80.0, child: button);
      }
    });

    Widget trackWidget;

    if (isPill) {
      trackWidget = Container(
        height: height,
        padding: const EdgeInsets.all(4),
        decoration: SavSurface(
          curvature: curvature,
          fillColor: AppColors.darkTransparent4,
        ),
        child: ClipPath(
          clipper: ShapeBorderClipper(
            shape: SquircleBorder(
              curvature: curvature,
              strokeWidth: 0,
              strokeGradient: const LinearGradient(colors: [Colors.transparent, Colors.transparent]),
            ),
          ),
          child: Stack(
            children: [
              // Sliding indicator
              Positioned.fill(
                child: AnimatedAlign(
                  alignment: Alignment(alignValue, 0.0),
                  duration: AppMotion.duration(context, const Duration(milliseconds: 220)),
                  curve: springCurve,
                  child: FractionallySizedBox(
                    widthFactor: items.isNotEmpty ? (1.0 / items.length) : 1.0,
                    heightFactor: 1.0,
                    child: Container(
                      decoration: SavSurface(
                        curvature: curvature - 1,
                        fillColor: Colors.white,
                        dropShadowColor: const Color(0x14000000),
                        dropShadowOffset: const Offset(0, 2),
                        dropShadowBlur: 2.0,
                      ),
                    ),
                  ),
                ),
              ),
              Row(children: segmentButtons),
            ],
          ),
        ),
      );
    } else {
      trackWidget = Container(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 10.0),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.hairline,
              width: 1.0,
            ),
          ),
        ),
        child: Stack(
          children: [
            // Sliding indicator bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 2.0,
              child: AnimatedAlign(
                alignment: Alignment(alignValue, 0.0),
                duration: AppMotion.duration(context, const Duration(milliseconds: 220)),
                curve: springCurve,
                child: FractionallySizedBox(
                  widthFactor: items.isNotEmpty ? (1.0 / items.length) : 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.obsidian,
                      borderRadius: BorderRadius.circular(0.5),
                    ),
                  ),
                ),
              ),
            ),
            Row(children: segmentButtons),
          ],
        ),
      );
    }

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: trackWidget,
      );
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: trackWidget,
      );
    }
  }
}
