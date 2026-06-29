import 'package:flutter/material.dart';
import '../core/tokens.dart';

class MorphingText extends StatelessWidget {
  const MorphingText({
    required this.text,
    required this.style,
    super.key,
    this.duration,
  });

  final String text;
  final TextStyle style;
  final Duration? duration;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = AppMotion.reduce(context);
    final chars = text.split('');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(chars.length, (index) {
        final char = chars[index];
        return AppMotion.switcher(
          duration: reduceMotion
              ? Duration.zero
              : (duration ?? AppMotion.durationHigh),
          slideYEnter: 4,
          slideYExit: 2,
          child: Text(
            char,
            key: ValueKey('${index}_$char'),
            style: style,
          ),
        );
      }),
    );
  }
}
