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

  static TextStyle _dm(double size, double weight, double lineHeight) =>
      TextStyle(
        fontFamily: _dmSans,
        fontSize: size,
        height: lineHeight,
        letterSpacing: 0,
        fontVariations: [
          FontVariation('wght', weight),
          const FontVariation('opsz', 32),
        ],
        fontFeatures: _features,
      );

  // — DM Sans ————————————————————————————————————————————
  static final headline      = _dm(18, 400, 1.25);
  static final onboardingTitles = _dm(20, 400, 1.20);
  static final bodyRegular   = _dm(14, 400, 1.25);
  static final bodyBold      = _dm(14, 500, 1.25); // ← Button label (Body/Bold)
  static final calloutRegular = _dm(16, 400, 1.25);
  static final calloutBold   = _dm(16, 500, 1.25);
  static final calloutCta    = _dm(16, 500, 1.25);
  static final calloutCta550 = _dm(16, 550, 1.25);
  static final captionRegular = _dm(12, 400, 1.20);

  // — Obviously (font not yet bundled — see class doc) ————————
  static const titleLargerText   = TextStyle(fontFamily: _obviously, fontSize: 48, height: 1.20, letterSpacing: 0);
  static const titleLargerSymbol = TextStyle(fontFamily: _obviously, fontSize: 30, height: 1.70, letterSpacing: 0);
  static const titleLargeText    = TextStyle(fontFamily: _obviously, fontSize: 40, height: 1.20, letterSpacing: 0);
  static const titleLargeSymbol  = TextStyle(fontFamily: _obviously, fontSize: 30, height: 1.40, letterSpacing: 0);
  static const titleMediumText   = TextStyle(fontFamily: _obviously, fontSize: 24, height: 1.20, letterSpacing: 0);
  static const titleMediumSymbol = TextStyle(fontFamily: _obviously, fontSize: 16, height: 25 / 16, letterSpacing: 0);
}
