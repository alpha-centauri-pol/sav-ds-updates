import 'package:flutter/material.dart';
import '../core/squircle.dart';
import '../core/tokens.dart';

enum BadgeType { count, dot }

enum BadgeSize { sm, md, lg }

class SavBadge extends StatelessWidget {
  const SavBadge({
    super.key,
    this.type = BadgeType.count,
    this.size = BadgeSize.sm,
    this.value,
    this.color = AppColors.obsidian,
    this.enableSurface = true,
    this.enableAnimation = true,
  });

  final BadgeType type;
  final BadgeSize size;
  final String? value;
  final Color color;
  final bool enableSurface;
  final bool enableAnimation;

  @override
  Widget build(BuildContext context) {
    if (type == BadgeType.dot) {
      final diameter = switch (size) {
        BadgeSize.sm => 6.0,
        BadgeSize.md => 10.0,
        BadgeSize.lg => 14.0,
      };

      return Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      );
    } else {
      // count badge
      final height = switch (size) {
        BadgeSize.sm => 18.0,
        BadgeSize.md => 24.0,
        BadgeSize.lg => 30.0,
      };

      final curvature = switch (size) {
        BadgeSize.sm => 4,
        BadgeSize.md => 6,
        BadgeSize.lg => 8,
      };

      final minWidth = height;

      return Container(
        height: height,
        constraints: BoxConstraints(minWidth: minWidth),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: enableSurface ? SavSurface(
          curvature: curvature,
          fillColor: color,
        ) : BoxDecoration(
          borderRadius: BorderRadius.circular(curvature.toDouble()),
          color: color,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: enableAnimation ? AppMotion.duration(context, AppMotion.durationHigh) : Duration.zero,
              transitionBuilder: (child, animation) {
                if (!enableAnimation) return child;
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.8, end: 1).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: AppMotion.curveOut,
                      ),
                    ),
                    child: child,
                  ),
                );
              },
              child: Text(
                value ?? '',
                key: ValueKey(value ?? ''),
                style: (switch (size) {
                  BadgeSize.sm => AppTextStyles.captionRegular.copyWith(
                        fontSize: 10,
                      ),
                  BadgeSize.md => AppTextStyles.captionRegular,
                  BadgeSize.lg => AppTextStyles.bodyBold.copyWith(fontSize: 14),
                }).copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
  }
}
