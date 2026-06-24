import 'package:flutter/material.dart';

/// Color variables exported from the Sav Design System ("🎨 Colors" collection).
///
/// Values mirror the Figma "Light" mode. The handful of tokens that differ in
/// Dark mode are the `savTransparent*` ramp (ink overlay → light overlay); those
/// will move behind a `ThemeExtension` when dark mode is built. Everything else
/// is mode-agnostic in the source file.
abstract final class AppColors {
  // — Sav Primary ————————————————————————————————————————
  static const white    = Color(0xFFFFFFFF); // sav-primary-white
  static const lumen    = Color(0xFFF6F6F6); // sav-primary-lumen
  static const sterling = Color(0xFFB4B4B4); // sav-primary-sterling
  static const slate    = Color(0xFF7A7A7A); // sav-primary-slate
  static const obsidian = Color(0xFF1F1F1F); // sav-primary-obsidian

  // — Sav Transparent (ink overlay, Light mode) ——————————————
  // Base ink is #1F1F1F (obsidian) at increasing opacity.
  static const transparent0  = Color(0x001F1F1F);
  static const transparent2  = Color(0x051F1F1F); // 0.02
  static const transparent4  = Color(0x0A1F1F1F); // 0.04
  static const transparent8  = Color(0x141F1F1F); // 0.08
  static const transparent12 = Color(0x1F1F1F1F); // 0.12
  static const transparent20 = Color(0x331F1F1F); // 0.20
  static const transparent40 = Color(0x661F1F1F); // 0.40
  static const transparent60 = Color(0x991F1F1F); // 0.60
  static const transparent80 = Color(0xCC1F1F1F); // 0.80

  // — Sav Transparent Light / Dark Overlay ——————————————
  static const lightTransparent40 = Color(0x66FFFFFF); // #ffffff66
  static const lightTransparent80 = Color(0xCCFFFFFF); // #ffffffcc
  static const darkTransparent80  = Color(0xCC1F1F1F); // #1f1f1fcc

  // — Wealth Weave (blue) ————————————————————————————————
  static const wealthWeave100 = Color(0xFFF2F6FC);
  static const wealthWeave500 = Color(0xFF5C9EF5);
  static const wealthWeave600 = Color(0xFF2E79DC);
  static const wealthWeave700 = Color(0xFF14399F);
  static const wealthWeave800 = Color(0xFF1E1E52);

  // — Gold Standard ————————————————————————————————————
  static const goldStandard100 = Color(0xFFF9FBF1);
  static const goldStandard500 = Color(0xFFCFBD63);
  static const goldStandard600 = Color(0xFFA68E38);
  static const goldStandard700 = Color(0xFF62531D);
  static const goldStandard800 = Color(0xFF352B0B);

  // — Purple Power ——————————————————————————————————————
  static const purplePower100 = Color(0xFFF6F4F9);
  static const purplePower500 = Color(0xFF7863BA);
  static const purplePower600 = Color(0xFF6447A8);
  static const purplePower700 = Color(0xFF4C426B);
  static const purplePower800 = Color(0xFF2C2354);

  // — Cyan Reserve ——————————————————————————————————————
  static const cyanReserve100 = Color(0xFFF3F9F8);
  static const cyanReserve500 = Color(0xFF40BBBD);
  static const cyanReserve600 = Color(0xFF007581);
  static const cyanReserve700 = Color(0xFF26616C);
  static const cyanReserve800 = Color(0xFF072A2D);

  // — Satin Vault ———————————————————————————————————————
  static const satinVault100 = Color(0xFFF9F5F9);
  static const satinVault500 = Color(0xFFC27694);
  static const satinVault600 = Color(0xFF92566B);
  static const satinVault700 = Color(0xFF5F2E48);
  static const satinVault800 = Color(0xFF301022);

  // — Lush Capital (green) ——————————————————————————————
  static const lushCapital100 = Color(0xFFF1F9F1);
  static const lushCapital500 = Color(0xFF5B9A74);
  static const lushCapital600 = Color(0xFF437A61);
  static const lushCapital700 = Color(0xFF295139);
  static const lushCapital800 = Color(0xFF1F3822);

  // — Bronze Bounty —————————————————————————————————————
  static const bronzeBounty100 = Color(0xFFFEF8F3);
  static const bronzeBounty500 = Color(0xFFC6853F);
  static const bronzeBounty600 = Color(0xFF935629);
  static const bronzeBounty700 = Color(0xFF542B0D);
  static const bronzeBounty800 = Color(0xFF331704);
}
