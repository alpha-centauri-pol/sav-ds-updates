import 'package:flutter/material.dart';
import '../core/tokens.dart';

class MorphingText extends StatelessWidget {
  const MorphingText({
    super.key,
    required this.text,
    required this.style,
    this.duration,
  });

  final String text;
  final TextStyle style;
  final Duration? duration;

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = AppMotion.reduce(context);
    final List<String> chars = text.split('');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(chars.length, (index) {
        final String char = chars[index];
        return AppMotion.switcher(
          duration: reduceMotion ? Duration.zero : (duration ?? AppMotion.durationHigh),
          slideYEnter: 4.0,
          slideYExit: 2.0,
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
