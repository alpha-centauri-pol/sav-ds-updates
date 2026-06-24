# Sav Design System — Context Handoff

> Handoff for the next agent (Antigravity). This file is the cold-start brief: read it top-to-bottom and you have everything needed to continue without re-deriving context.

---

## 0. Paths & toolchain

| Thing | Path |
|-------|------|
| **Flutter app (this project)** | `/Users/google/Claude/Projects/sav_ds` |
| **Planning docs (markdown)** | `/Users/google/Claude/Projects/Sav DS/` (8 `.md` files — read for full design rationale) |
| **Helper/reference package** | `/Users/google/Downloads/sav-helpers/` (source we vendored from) |
| **Flutter SDK** | `~/flutter/bin/flutter` (NOT on PATH) — Flutter 3.44.1 / Dart 3.12.1 |
| **Token source of truth** | Figma export JSON (colors + text styles); pasted into the original task brief |
| **Figma file** | `Q0Bkg0Cb4IO0HDHw1CxXU8` — "Sav Design System" |
| **Button design node** | `193:6300` (group) / `197:5514` (Primary frame) |

Run / verify:
```bash
cd "/Users/google/Claude/Projects/sav_ds"
~/flutter/bin/flutter pub get
~/flutter/bin/flutter analyze        # clean
~/flutter/bin/flutter test           # passing
~/flutter/bin/flutter run -d <deviceId>   # iPhone 17 sim verified
```

---

## 1. What this project is

A from-scratch Flutter implementation of the **Sav Design System**. Goal: ~5 canonical components
(Button, Badge, Tag, Segmented, SelectableRow) with a clean prop API + design tokens, **no external
packages** (everything vendored). The broader plan lives in `Sav DS/03..08_*.md`.

**Current scope delivered: Button → Primary variant only.** Everything else is scaffolding/next-up.

Key constraints (locked with the user):
- **No external packages.** Helper code (squircle, noise) was *copied in*, not added as a dependency.
- **Vendor, don't depend.** `sav-helpers` is reference source, not a path dependency.
- App lives in its own folder (`sav_ds`), separate from the `Sav DS/` planning docs.

---

## 2. File structure

```
lib/
  main.dart                       # demo gallery (3 button examples)
  core/
    squircle.dart                 # VENDORED verbatim from sav-helpers — figma-squircle port
                                  #   SquircleBorder(curvature 0–10, strokeWidth, strokeGradient)
    noise.dart                    # VENDORED verbatim — NoiseLayer: tiled noise.png, soft-light overlay
    tokens.dart                   # barrel export
    tokens/
      colors.dart                 # AppColors — full palette from Figma JSON (Light mode)
      typography.dart             # AppTextStyles — DM Sans styles done; Obviously titles stubbed
      spacing.dart                # AppSpacing — general scale
      tokens/components/button.dart # AppButtonTokens — Primary style values + exact Figma dims
  components/
    app_button.dart               # AppButton + AppButtonVariant enum
assets/
  images/noise.png                # VENDORED from sav-helpers
  fonts/DMSans[opsz,wght].ttf     # VENDORED (variable font)
  fonts/DMSans-Italic[opsz,wght].ttf
test/widget_test.dart             # smoke test for the gallery
HANDOFF.md                        # this file
```

`pubspec.yaml`: only `flutter` + `cupertino_icons` deps; `flutter_lints` dev. Fonts + `assets/images/`
registered.

---

## 3. Tokens (built from the Figma JSON export)

- **`AppColors`** — every color variable from the "🎨 Colors" collection, camelCased
  (`savPrimaryWhite` → `white`, brand ramps `wealthWeave500` etc., `transparent0..80` ink overlays).
  Values are Figma **Light** mode. The `transparent*` ramp is the only set that differs in Dark
  (ink → light overlay); when dark mode is built, move that ramp behind a `ThemeExtension`.
- **`AppTextStyles`** — DM Sans styles are real (variable font bundled). **"Bold" tokens = weight 500**
  (matches the Figma export, e.g. Body/Bold resolves to 500). `bodyBold` (14/500) is the **button label**.
  The `Title/*` styles use the **Obviously** family which is **NOT bundled** — defined for API
  completeness, fall back to default font until the font files are added to `assets/fonts/`.
- **`AppSpacing`** — general 2/4/8/12/16/20 scale. Component-specific dims live with the component.
- **`AppButtonTokens`** — Primary-only so far: dims (height 48, padX 10, padY 9, gap 2, label inset 2,
  icon 20), curvature 10, strokeWidth 1.25, noise (enabled/0.6/scale 1.0), bg gradient (slate→obsidian),
  rim stroke gradient (white→lumen→white, soft-light), press spring + tap scales.

---

## 4. The Button (what's implemented)

`AppButton` mirrors the Figma component API and is built to extend cleanly to other variants.

```dart
AppButton({
  String label = 'Label text',
  VoidCallback? onPressed,
  AppButtonVariant variant = AppButtonVariant.primary, // enum: only `primary` for now
  Widget? leading,        // null + showLeadingIcon → placeholder star glyph
  Widget? trailing,
  bool showLabel = true,
  bool showLeadingIcon = true,
  bool showTrailingIcon = true,
  bool isFullWidth = false, // false = hug (Figma frame); true = stretch to parent width
})
```

Faithful to node 197:5514: 48px height, 10/9 cell padding, centered content row
`[leading 20px] · label(±2px) · [trailing 20px]` with 2px gaps; ink gradient fill clipped to a
**curvature-10 squircle** with a soft-light rim stroke + soft-light **noise** overlay; spring
press-scale to 0.98 (`flutter/physics` SpringSimulation, not a state prop).

Style is resolved once per variant via the private `_ButtonStyle` (Layer-B: fill/noise/stroke/
squircle/motion — never per-instance). To add a variant: add the enum case, a `_secondary`/etc.
`_ButtonStyle`, its tokens in `button.dart`, and the `switch` arms in `_AppButtonState`.

**Verified:** analyze clean, test passing, rendered on iPhone 17 simulator and visually matched to the
Figma Primary frame.

---

## 5. Decisions made (revisit if needed)

1. **Noise opacity = 0.6** — kept sav-helpers' tuned value, not the Figma layer's raw 40%, because the
   `NoiseLayer` modulate+soft-light pipeline isn't a 1:1 map to a Figma layer opacity. Looks right on
   device; tweak in `AppButtonTokens.primaryNoiseOpacity`.
2. **Placeholder icons** = `Icons.star_border_rounded` (Material) for the Figma instance-swap slots.
   No icon system yet (would need an external pkg or a vendored icon set). Real glyphs passed via
   `leading`/`trailing`.
3. **`bodyBold` = weight 500** (Figma "Body/Bold" exports as weight 500 via the variable axis).
4. **Hug by default** (`isFullWidth: false`) to match the Figma frame; full-width CTA is opt-in. (The
   standardisation doc 05 suggests Primary defaults full-width in product use — choose per usage.)

---

## 6. Next up (suggested order)

1. **Button: secondary / tertiary / icon-only** variants (see `Sav DS/05_button-standardisation.md`
   §STEP 4 for the per-variant token spec; `08_figma-build-recipe.md` §1 for prop matrix).
   - Secondary: white/elevated fill, hairline stroke, dark label, e1 shadow, no noise.
   - Link/tertiary: transparent, dotted underline (locked), no shadow.
   - Icon-only: square/near-circle squircle, single glyph.
   - Also: `state` (default/disabled/loading) and `intent` (neutral/positive/negative) per doc 05 §STEP 3.
2. **Bundle the Obviously font** → finish `AppTextStyles.title*`.
3. **Real icon set** (vendored SVGs-as-paths or an icon font) to replace placeholder stars.
4. **Components 2–5**: Badge, Tag, Segmented, SelectableRow — prop APIs in
   `Sav DS/08_figma-build-recipe.md`.
5. **Dark mode** via `ThemeExtension` (start with the `transparent*` ramp).

---

## 7. Reference docs (in `Sav DS/`)

- `05_button-standardisation.md` — canonical button spec, 6-prop API, full visual token values.
- `06_button-build-workflow.md` — tokens→Figma→Flutter workflow.
- `07_components-2to5-standardisation.md` — the other 4 components.
- `08_figma-build-recipe.md` — exact Figma prop/variant/variable structure per component.
