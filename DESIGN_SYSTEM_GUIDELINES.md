# Sav Design System Guidelines

This document outlines the strict coding standards and token usage rules for building components and interfaces within the Sav Design System. To ensure visual consistency and a unified aesthetic across our application, **all styles must be derived from defined tokens**.

## 1. Colors

**Rule: NEVER use hardcoded hex colors, RGB, or arbitrary `Colors.*` values (like `Colors.red`).**

All colors must be sourced from the `AppColors` token definitions.

*   **Correct:** `color: AppColors.wealthWeave500`
*   **Correct:** `color: AppColors.obsidian`
*   **Incorrect:** `color: Color(0xFF1F1F1F)`
*   **Incorrect:** `color: Colors.blue`

## 2. Gradients

**Rule: NEVER construct inline `LinearGradient` or `RadialGradient` objects with arbitrary colors.**

All gradients used in the UI must be sourced from the predefined `AppGradients` tokens. This ensures our premium look and dynamic aesthetic are maintained everywhere.

*   **Correct:** `gradient: AppGradients.titleGradientBlue`
*   **Correct:** `gradient: AppGradients.titleGradientBlack`
*   **Incorrect:** `gradient: LinearGradient(colors: [Color(0xFF5C9EF5), Color(0xFF1E1E52)])`

## 3. Typography

**Rule: NEVER instantiate raw `TextStyle()` objects with arbitrary fonts, sizes, or weights.**

All text styles must use the predefined semantic and structural tokens in `AppTextStyles`. Our typography relies heavily on specific variable font configurations (`fontVariations` and `fontWeight`) that should not be manually reconstructed.

*   **Correct:** `style: AppTextStyles.bodyBold`
*   **Correct:** `style: AppTextStyles.calloutCta`
*   **Incorrect:** `style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)`

> [!IMPORTANT]
> If you need to change the color of a specific typography token for a component layout, use the `.copyWith(color: ...)` method, ensuring the overriding color is also an `AppColors` token.

## 4. Spacing and Motion

Follow the same principles for spacing constraints (margins, padding, gaps) and motion tokens (durations, curves, spring physics). Always rely on `AppSpacing` and `AppMotion` values.

## Summary

If a design requires a color, gradient, or typography style that does not exist in the tokens, **do not hardcode it**. Discuss the addition of a new token with the design team so the system remains the single source of truth.
