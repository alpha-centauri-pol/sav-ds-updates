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

class SegmentedControlTokens {
  const SegmentedControlTokens({
    required this.height,
    required this.fontSize,
    required this.iconSize,
    required this.curvature,
  });

  final double height;
  final double fontSize;
  final double iconSize;
  final int curvature;

  static SegmentedControlTokens resolve(SegmentedControlSize size) =>
      switch (size) {
        SegmentedControlSize.sm => const SegmentedControlTokens(
            height: 32.0,
            fontSize: 12.0,
            iconSize: 16.0,
            curvature: 8,
          ),
        SegmentedControlSize.md => const SegmentedControlTokens(
            height: 40.0,
            fontSize: 14.0,
            iconSize: 18.0,
            curvature: 10,
          ),
      };
}

class SegmentedControl extends StatelessWidget {
  const SegmentedControl({
    required this.items,
    required this.selected,
    required this.onChanged,
    super.key,
    this.style = SegmentedControlStyle.pill,
    this.size = SegmentedControlSize.md,
    this.content = SegmentedControlContent.text,
    this.isFullWidth = true,
    this.enableSurface = true,
    this.enableSelectionAnimation = true,
  });

  final List<SegmentedItem> items;
  final int selected;
  final ValueChanged<int> onChanged;
  final SegmentedControlStyle style;
  final SegmentedControlSize size;
  final SegmentedControlContent content;
  final bool isFullWidth;
  final bool enableSurface;
  final bool enableSelectionAnimation;

  Widget _buildSegmentChild(
    BuildContext context,
    SegmentedItem item,
    bool isSelected,
    Color fgColor,
    SegmentedControlTokens tokens,
    Curve springCurve,
  ) {
    final hasIcon = content != SegmentedControlContent.text && item.icon != null;
    final hasText = content != SegmentedControlContent.icon;

    if (hasIcon && hasText) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.sm, // 6
        children: [
          TweenAnimationBuilder<Color?>(
            duration: enableSelectionAnimation ? AppMotion.duration(context, const Duration(milliseconds: 220)) : Duration.zero,
            curve: springCurve,
            tween: ColorTween(end: fgColor),
            builder: (context, color, child) =>
                Icon(item.icon, size: tokens.iconSize, color: color),
          ),
          AnimatedDefaultTextStyle(
            duration: enableSelectionAnimation ? AppMotion.duration(context, const Duration(milliseconds: 220)) : Duration.zero,
            curve: springCurve,
            style: (isSelected ? AppTextStyles.bodyBold : AppTextStyles.bodyRegular)
                .copyWith(fontSize: tokens.fontSize, color: fgColor),
            child: Text(item.label),
          ),
        ],
      );
    } else if (hasIcon) {
      return TweenAnimationBuilder<Color?>(
        duration: enableSelectionAnimation ? AppMotion.duration(context, const Duration(milliseconds: 220)) : Duration.zero,
        curve: springCurve,
        tween: ColorTween(end: fgColor),
        builder: (context, color, child) =>
            Icon(item.icon, size: tokens.iconSize, color: color),
      );
    } else if (hasText) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedDefaultTextStyle(
            duration: enableSelectionAnimation ? AppMotion.duration(context, const Duration(milliseconds: 220)) : Duration.zero,
            curve: springCurve,
            style: (isSelected ? AppTextStyles.bodyBold : AppTextStyles.bodyRegular)
                .copyWith(fontSize: tokens.fontSize, color: fgColor),
            child: Text(item.label),
          ),
          if (item.subtitle != null) ...[
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: enableSelectionAnimation ? AppMotion.duration(context, const Duration(milliseconds: 220)) : Duration.zero,
              curve: springCurve,
              style: AppTextStyles.captionRegular.copyWith(
                fontSize: tokens.fontSize - 2,
                color: AppColors.slate,
              ),
              child: Text(item.subtitle!),
            ),
          ],
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSegmentButton(
    BuildContext context,
    int index,
    SegmentedControlTokens tokens,
    Curve springCurve,
  ) {
    final item = items[index];
    final isSelected = index == selected;
    final fgColor = isSelected ? AppColors.obsidian : AppColors.slate;

    final segmentChild = _buildSegmentChild(
      context,
      item,
      isSelected,
      fgColor,
      tokens,
      springCurve,
    );

    final button = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(index),
      child: SizedBox(
        height: tokens.height,
        child: Center(child: segmentChild),
      ),
    );

    if (isFullWidth) {
      return Expanded(child: button);
    } else {
      return SizedBox(width: 80, child: button);
    }
  }

  Widget _buildPillTrack(
    BuildContext context,
    List<Widget> segmentButtons,
    double alignValue,
    SegmentedControlTokens tokens,
    Curve springCurve,
  ) {
    return Container(
      height: tokens.height,
      padding: const EdgeInsets.all(AppSpacing.sm), // 4
      decoration: enableSurface ? SavSurface(
        curvature: tokens.curvature,
        fillColor: AppColors.darkTransparent4,
      ) : BoxDecoration(
        borderRadius: BorderRadius.circular(tokens.curvature.toDouble()),
        color: AppColors.darkTransparent4,
      ),
      child: ClipPath(
        clipper: ShapeBorderClipper(
          shape: SquircleBorder(
            curvature: tokens.curvature,
            strokeWidth: 0,
            strokeGradient: const LinearGradient(
              colors: [Colors.transparent, Colors.transparent],
            ),
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedAlign(
                alignment: Alignment(alignValue, 0),
                duration: enableSelectionAnimation ? AppMotion.duration(context, const Duration(milliseconds: 220)) : Duration.zero,
                curve: springCurve,
                child: FractionallySizedBox(
                  widthFactor: items.isNotEmpty ? (1.0 / items.length) : 1.0,
                  heightFactor: 1,
                  child: Container(
                    decoration: enableSurface ? SavSurface(
                      curvature: tokens.curvature - 1,
                      fillColor: Colors.white,
                      dropShadowColor: Colors.black.withValues(alpha: 0.08),
                      dropShadowOffset: const Offset(0, 2),
                      dropShadowBlur: 2,
                    ) : BoxDecoration(
                      borderRadius: BorderRadius.circular((tokens.curvature - 1).toDouble()),
                      color: Colors.white,
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
  }

  Widget _buildUnderlineTrack(
    BuildContext context,
    List<Widget> segmentButtons,
    double alignValue,
    SegmentedControlTokens tokens,
    Curve springCurve,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: 10), // 32
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.hairline),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 2,
            child: AnimatedAlign(
              alignment: Alignment(alignValue, 0),
              duration: enableSelectionAnimation ? AppMotion.duration(context, const Duration(milliseconds: 220)) : Duration.zero,
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

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final isPill = style == SegmentedControlStyle.pill;
    final Curve springCurve = SpringCurve(AppMotion.springDefault);
    final tokens = SegmentedControlTokens.resolve(size);

    final alignValue = items.length > 1
        ? -1.0 + (selected * (2.0 / (items.length - 1)))
        : 0.0;

    final segmentButtons = List<Widget>.generate(
      items.length,
      (index) => _buildSegmentButton(context, index, tokens, springCurve),
    );

    final trackWidget = isPill
        ? _buildPillTrack(context, segmentButtons, alignValue, tokens, springCurve)
        : _buildUnderlineTrack(context, segmentButtons, alignValue, tokens, springCurve);

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
