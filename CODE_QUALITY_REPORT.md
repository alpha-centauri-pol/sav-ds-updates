# Code Quality & Performance Report (`sav_ds`)

## Executive Summary
This report outlines the current code quality, linting status, and performance profile of the `sav_ds` Flutter design system. The project has transitioned from the default `flutter_lints` ruleset to the much stricter `very_good_analysis` ruleset to enforce higher quality standards. 

## B1. Baseline Analyzer Findings (19 Original Infos)
Before adopting the stricter ruleset, the baseline `flutter_lints` reported **19 info-level issues**. These are high-value and should be addressed first:

- **Deprecations (16):**
  - `withOpacity` → `.withValues(alpha: …)` — 8 sites
    (`amount_input.dart:185` ×2, `app_button.dart:293`, `otp_input.dart:171-172`, `selectable_row.dart:183`, `confetti.dart:180`, `playground.dart:142`).
  - `Color.value` → `.toARGB32()` / component accessors `.r/.g/.b` — 7 sites
    (`playgrounds.dart:41-43, 404, 465-467`).
  - `opacity` → `.a` — `confetti.dart:180`.
- **Unnecessary import:** `app_button.dart:1` imports `cupertino.dart` redundantly.
- **`use_null_aware_elements` (2):** `amount_input.dart:334`, `main.dart:269`.

## B2. Performance Leaks & Hotspots
Manual inspection reveals a few areas where performance and resource management can be improved:

- **Confetti rebuild storm (`lib/dev/confetti.dart:88`):** 
  `_updateParticles` calls `setState(() {})` every animation frame (~60 fps). This causes the entire `Stack` (including `widget.child`) to rebuild. Furthermore, the `CustomPaint` on line 100 lacks a `RepaintBoundary`. 
  **Recommended fix:** Drive the painter with an `AnimatedBuilder` off the `_controller` instead of using `setState`, and wrap the painter in a `RepaintBoundary` so only the paint layer updates.
- **Controller leak (`lib/dev/playground.dart:337`):** 
  `PropText` is a `StatelessWidget` that instantiates a `TextEditingController(text: value)` directly inside its `build()` method. A new controller is created on every rebuild and is never disposed, leading to memory leaks and cursor jumps.
  **Recommended fix:** Convert `PropText` to a `StatefulWidget` that owns and disposes the controller, or hoist the controller state to its parent.

## B3. What Looks Healthy
To balance the findings, there are several areas where the codebase demonstrates excellent practices:

- **Disposal is correct:** Every other stateful component managing controllers, timers, or focus nodes (`main.dart`, `input_field.dart`, `otp_input.dart`, `amount_input.dart`, `app_button.dart`, `sav_chip.dart`, `selectable_row.dart`) correctly implements a `dispose()` method.
- **Efficient Painters:** All `CustomPainter` implementations (`noise.dart`, `dirham_symbol.dart`, `selectable_row.dart`, `confetti.dart`) correctly implement `shouldRepaint` with proper field comparisons to prevent unnecessary redraws.
- **Style consistency:** Quote style (single quotes) and `const` usage are applied consistently throughout the codebase.

## B4. Optimization Opportunities (Lower Priority)
With the introduction of `very_good_analysis`, the analyzer now reports **700 issues** across the codebase. 

- **Highest-value rules to address first:** The vast majority of these 700 issues are formatting-related (e.g., `lines_longer_than_80_chars` and `avoid_redundant_argument_values`). The highest priority should be resolving the deprecations (noted in B1), followed by fixing any `prefer_const` or `unawaited_futures` hits that `very_good_analysis` uncovers.
- **Repaint Boundaries:** Add `RepaintBoundary` around continuously-animating painters (like the confetti) to isolate repaints and maintain a smooth 60fps UI.
- **File Splitting:** `lib/main.dart` has grown to nearly 800 lines. While not urgent, it is a strong candidate for splitting into smaller, domain-specific files (e.g., separating the playground tabs into their own files).
