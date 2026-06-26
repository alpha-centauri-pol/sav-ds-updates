import 'package:flutter/widgets.dart';

/// A wrapper that applies a subtle opacity fade when [disabled] is true.
class DisabledFade extends StatelessWidget {
  const DisabledFade({
    super.key,
    required this.disabled,
    required this.child,
  });

  final bool disabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: disabled ? 0.4 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: child,
    );
  }
}
