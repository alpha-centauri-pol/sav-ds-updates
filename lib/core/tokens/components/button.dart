import 'package:flutter/material.dart';
import '../colors.dart';
import '../typography.dart';

enum AppButtonVariant { primary, secondary, inline }
enum AppButtonSize { small, regular, large }
enum AppButtonWidth { hug, half, full }
enum AppButtonIcon { none, leading, trailing, iconOnly }
enum AppButtonState { normal, disabled, loading }

/// Resolved size token values.
class AppButtonSizeTokens {
  const AppButtonSizeTokens({
    required this.height,
    required this.paddingX,
    required this.paddingY,
    required this.gap,
    required this.iconSize,
    required this.textStyle,
  });

  final double height;
  final double paddingX;
  final double paddingY;
  final double gap;
  final double iconSize;
  final TextStyle textStyle;

  static AppButtonSizeTokens resolve(AppButtonSize size) => switch (size) {
        AppButtonSize.small => AppButtonSizeTokens(
            height: 34.0,
            paddingX: 12.0,
            paddingY: 7.0,
            gap: 2.0,
            iconSize: 16.0,
            textStyle: AppTextStyles.bodyBold,
          ),
        AppButtonSize.regular => AppButtonSizeTokens(
            height: 40.0,
            paddingX: 10.0,
            paddingY: 9.0,
            gap: 2.0,
            iconSize: 18.0,
            textStyle: AppTextStyles.bodyBold,
          ),
        AppButtonSize.large => AppButtonSizeTokens(
            height: 48.0,
            paddingX: 16.0,
            paddingY: 14.0,
            gap: 8.0,
            iconSize: 20.0,
            textStyle: AppTextStyles.calloutCta,
          ),
      };
}

/// Resolved style token values.
class AppButtonStyleTokens {
  const AppButtonStyleTokens({
    required this.noiseEnabled,
    required this.noiseOpacity,
    required this.noiseScale,
    required this.curvature,
    required this.labelColor,
    required this.bgGradient,
    required this.fillColor,
    required this.strokeColor,
    required this.strokeWidth,
    required this.strokeGradient,
    required this.hasSecondaryDecoration,
    required this.hasInlineGradient,
    required this.shadows,
  });

  final bool noiseEnabled;
  final double noiseOpacity;
  final double noiseScale;
  final int curvature;
  final Color labelColor;
  final LinearGradient? bgGradient;
  final Color? fillColor;
  final Color? strokeColor;
  final double strokeWidth;
  final LinearGradient? strokeGradient;
  final bool hasSecondaryDecoration;
  final bool hasInlineGradient;
  final List<BoxShadow>? shadows;

  static AppButtonStyleTokens resolve(AppButtonVariant variant, AppButtonSize size) {
    return switch (variant) {
      AppButtonVariant.primary => AppButtonStyleTokens(
          noiseEnabled: true,
          noiseOpacity: 0.6,
          noiseScale: 1.0,
          curvature: 10,
          labelColor: AppColors.white,
          bgGradient: AppButtonTokens.primaryBgGradient,
          fillColor: null,
          strokeColor: null,
          strokeWidth: 1.25,
          strokeGradient: AppButtonTokens.primaryStrokeGradient,
          hasSecondaryDecoration: false,
          hasInlineGradient: false,
          shadows: const [
            BoxShadow(
              color: Color(0x3D000000), // #000 @ 24%
              offset: Offset(0, 8),
              blurRadius: 20,
              spreadRadius: -4,
            ),
            BoxShadow(
              color: Color(0x29000000), // #000 @ 16%
              offset: Offset(0, 2),
              blurRadius: 6,
              spreadRadius: 0,
            ),
          ],
        ),
      AppButtonVariant.secondary => AppButtonStyleTokens(
          noiseEnabled: size != AppButtonSize.small,
          noiseOpacity: size == AppButtonSize.large ? 0.4 : 0.6,
          noiseScale: 1.0,
          curvature: 10,
          labelColor: const Color(0xCC1F1F1F), // #1f1f1fcc (darkTransparent80)
          bgGradient: null,
          fillColor: AppColors.white,
          strokeColor: AppColors.hairline,
          strokeWidth: 1.0,
          strokeGradient: null,
          hasSecondaryDecoration: true,
          hasInlineGradient: false,
          shadows: null,
        ),
      AppButtonVariant.inline => AppButtonStyleTokens(
          noiseEnabled: false,
          noiseOpacity: 0.0,
          noiseScale: 1.0,
          curvature: 10,
          labelColor: const Color(0xCC1F1F1F),
          bgGradient: null,
          fillColor: Colors.transparent,
          strokeColor: Colors.transparent,
          strokeWidth: 0.0,
          strokeGradient: null,
          hasSecondaryDecoration: false,
          hasInlineGradient: true,
          shadows: null,
        ),
    };
  }
}

abstract final class AppButtonTokens {
  // — Primary tokens (legacy) ————————————————————————————————————
  static const primaryCurvature    = 10;
  static const primaryStrokeWidth  = 1.25;
  static const primaryNoiseEnabled = true;
  static const primaryNoiseOpacity = 0.6;
  static const primaryNoiseScale   = 1.0;
  static const primaryTapDownScale = 0.98;
  static const primaryTapUpScale   = 1.0;
  static const labelInsetX         = 2.0;

  static const primaryBgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.slate, AppColors.obsidian],
  );

  static const primaryStrokeGradient = LinearGradient(
    begin: Alignment(-1.0, -1.0),
    end: Alignment(-0.9, 2.9),
    colors: [AppColors.white, AppColors.lumen, AppColors.white],
    stops: [0.0, 0.8, 0.879808],
  );

  static const primarySpring = SpringDescription(
    mass: 1,
    stiffness: 300,
    damping: 20,
  );
}
