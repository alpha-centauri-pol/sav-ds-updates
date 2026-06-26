import 'package:flutter/material.dart';

/// Text styles exported from the Sav Design System.
///
/// DM Sans is a variable font (bundled). "Bold" tokens render at weight 500
/// (medium) — matching the Figma export, where e.g. Body/Bold resolves to
/// weight 500. The Title/* styles use the "Obviously" family, which is **not
/// bundled yet**; they are defined here for API completeness and will fall back
/// to the default font until the Obviously font files are added to assets.
abstract final class AppTextStyles {
  static const _dmSans = 'DM Sans';
  static const _obviously = 'Obviously';



  // OpenType features observed on Sav text in Figma (case-sensitive forms +
  // stylistic sets). opsz pinned to 32 to match the design source.
  static const _features = <FontFeature>[
    FontFeature('case'),
    FontFeature('ss03'),
    FontFeature('ss01'),
  ];

  static TextStyle _dm(double size, double weight, double lineHeight, {double opsz = 32}) =>
      TextStyle(
        fontFamily: _dmSans,
        fontWeight: FontWeight(weight.toInt()),
        fontSize: size,
        height: lineHeight,
        letterSpacing: 0,
        fontVariations: [
          FontVariation('wght', weight),
          FontVariation('opsz', opsz),
        ],
        fontFeatures: _features,
      );

  static TextStyle _obv(double size, double lineHeight) => TextStyle(
        fontFamily: _obviously,
        fontWeight: FontWeight.w600,
        fontSize: size,
        height: lineHeight,
        letterSpacing: 0,
      );

  static final TextStyle obviouslyLargeText = _obv(36, 1.20);
  static final TextStyle obviouslyLargeSymbol = _obv(30, 1.50);
  static final TextStyle obviouslyMediumText = _obv(24, 1.20);
  static final TextStyle obviouslyMediumSymbol = _obv(16, 24 / 16);
  static final TextStyle obviouslyOtp = _obv(40, 1.20);
  static final TextStyle bodyRegular = _dm(14, 400, 1.25, opsz: 32);
  static final TextStyle bodyBold = _dm(14, 500, 1.25, opsz: 32);
  static final TextStyle calloutRegular = _dm(16, 450, 1.25, opsz: 36);
  static final TextStyle calloutBold = _dm(16, 500, 1.25, opsz: 36);
  static final TextStyle calloutCta = _dm(16, 550, 1.25, opsz: 36);
  static final TextStyle captionRegular = _dm(12, 450, 1.20, opsz: 32);
}
