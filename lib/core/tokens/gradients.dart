import 'package:flutter/material.dart';
import 'colors.dart';

/// Gradient variables exported from the Sav Design System.
abstract final class AppGradients {
  static const titleGradientBlack = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.slate, AppColors.obsidian],
  );

  static const titleGradientBlue = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.wealthWeave500, AppColors.wealthWeave800],
  );

  static const titleGradientGreen = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.lushCapital500, AppColors.lushCapital800],
  );

  static const titleGradientYellow = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.goldStandard500, AppColors.goldStandard800],
  );

  static const titleGradientPurple = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.purplePower500, AppColors.purplePower800],
  );

  static const titleGradientTeal = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.cyanReserve500, AppColors.cyanReserve800],
  );

  static const titleGradientPink = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.satinVault500, AppColors.satinVault800],
  );

  static const titleGradientBronze = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.bronzeBounty500, AppColors.bronzeBounty800],
  );

  static const inputBgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.white, AppColors.lumen],
  );

  static const inputStrokeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.transparent12, AppColors.transparent2],
  );

  static const otpTextGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.obsidian,
      AppColors.slate,
      AppColors.sterling,
    ],
    stops: [0.4, 0.8, 1.0],
  );

  static final leftSquircleOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.lumen.withValues(alpha: 0.4),
      AppColors.lumen.withValues(alpha: 0.2),
      AppColors.lumen.withValues(alpha: 0),
    ],
    stops: const [0, 0.2, 1.0],
  );
}
