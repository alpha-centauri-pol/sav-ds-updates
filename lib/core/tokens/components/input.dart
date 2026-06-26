import 'package:flutter/widgets.dart';
import '../../../components/input_field.dart';

class InputFieldSizeTokens {
  const InputFieldSizeTokens({
    required this.height,
    required this.fontSize,
    required this.iconSize,
  });

  final double height;
  final double fontSize;
  final double iconSize;

  static InputFieldSizeTokens resolve(InputFieldSize size) => switch (size) {
        InputFieldSize.md => const InputFieldSizeTokens(
            height: 40.0,
            fontSize: 14.0,
            iconSize: 18.0,
          ),
        InputFieldSize.lg => const InputFieldSizeTokens(
            height: 48.0,
            fontSize: 15.0,
            iconSize: 20.0,
          ),
      };
}
