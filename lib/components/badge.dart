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
  });

  final BadgeType type;
  final BadgeSize size;
  final String? value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (type == BadgeType.dot) {
      final double diameter = switch (size) {
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
      final double height = switch (size) {
        BadgeSize.sm => 18.0,
        BadgeSize.md => 24.0,
        BadgeSize.lg => 30.0,
      };


      final int curvature = switch (size) {
        BadgeSize.sm => 4,
        BadgeSize.md => 6,
        BadgeSize.lg => 8,
      };

      final double minWidth = height;

      return Container(
        height: height,
        constraints: BoxConstraints(minWidth: minWidth),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: SavSurface(
          curvature: curvature,
          fillColor: color,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: AppMotion.duration(context, AppMotion.durationHigh),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: animation, curve: AppMotion.curveOut)),
                  child: child,
                ),
              ),
              child: Text(
                value ?? '',
                key: ValueKey(value ?? ''),
                style: (switch (size) {
                  BadgeSize.sm => AppTextStyles.caption550.copyWith(fontSize: 10),
                  BadgeSize.md => AppTextStyles.caption550,
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
