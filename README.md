# sav_ds — Sav Design System

A vendored, **dependency-free** Flutter component library and design-token set.
Everything ships inside the package (fonts, the noise texture, the squircle
geometry), so consumers get the full system with zero extra setup.

## Install

This is a private package — depend on it by path (or git):

```yaml
# pubspec.yaml
dependencies:
  sav_ds:
    path: ../sav_ds   # adjust to wherever the package lives
```

Then a single import gives you the whole public surface:

```dart
import 'package:sav_ds/sav_ds.dart';
```

The noise texture is bundled with the package and referenced via `package: 'sav_ds'`,
so you do not need to declare it in your app's pubspec.

**Note on Fonts:** Typography styles in `sav_ds` reference the `DM Sans` and `Obviously`
fonts by their plain family names. A consuming app **must register these font families**
in its own `pubspec.yaml`. You can point at the package's assets (e.g. `packages/sav_ds/assets/fonts/...`)
or copy the font files into your app (as the example app does).

## Quick start

```dart
import 'package:flutter/material.dart';
import 'package:sav_ds/sav_ds.dart';

class Example extends StatelessWidget {
  const Example({super.key});

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: 'Continue',
      variant: AppButtonVariant.primary,
      width: AppButtonWidth.full,
      onPressed: () {},
    );
  }
}
```

## What's included

**Tokens** (`AppColors`, `AppTextStyles`, `AppSpacing`, `AppMotion`, button tokens)
— the single source of truth for color, type, spacing and motion.

**Components**

| Component          | Purpose                                   |
| ------------------ | ----------------------------------------- |
| `AppButton`        | Primary/secondary/inline buttons          |
| `InputField`       | Labelled text field (boxed / underline)   |
| `OTPInput`         | One-time-code entry                       |
| `AmountInput`      | Currency amount entry                     |
| `SegmentedControl` | Segmented selector                        |
| `SelectableRow`    | List row with checkmark / radio indicator |
| `SavChip`          | Compact status / filter chip              |
| `SavBadge`         | Count / dot badge                         |

**Primitives** — `SquircleBorder` / `SavSurface` (squircle geometry + layered
shadows) and `NoiseLayer` (the subtle grain overlay).

## Run the gallery

The `example/` app is an interactive gallery and playground for every
component. It depends on the library via a local path:

```bash
cd example
flutter pub get
flutter run
```

## Develop

The toolchain is **Flutter 3.44.1 / Dart 3.12.1**.

```bash
flutter pub get
flutter analyze   # strict very_good_analysis ruleset — expected: no issues
flutter test      # component smoke tests
```

Lint configuration lives in `analysis_options.yaml` (the `example/` app inherits
it). The library code is held to a clean `flutter analyze` under
`very_good_analysis`.
