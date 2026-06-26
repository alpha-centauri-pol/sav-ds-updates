import 'package:flutter/widgets.dart';

/// A mixin that manages the lifecycle of a [TextEditingController] and [FocusNode]
/// for input fields. It creates them if not provided by the widget, listens to
/// them, and disposes of them only if it created them.
mixin ManagedFieldStateMixin<T extends StatefulWidget> on State<T> {
  /// The [FocusNode] provided by the widget, if any.
  FocusNode? get widgetFocusNode;

  /// The [TextEditingController] provided by the widget, if any.
  TextEditingController? get widgetController;

  late final FocusNode focusNode = widgetFocusNode ?? FocusNode();
  late final TextEditingController controller =
      widgetController ?? TextEditingController();

  bool get isFocused => focusNode.hasFocus;

  @override
  void initState() {
    super.initState();
    focusNode.addListener(_onFocusChange);
    controller.addListener(_onTextChange);
  }

  @override
  void dispose() {
    focusNode.removeListener(_onFocusChange);
    controller.removeListener(_onTextChange);
    if (widgetFocusNode == null) focusNode.dispose();
    if (widgetController == null) controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!mounted) return;
    setState(() {});
    onFocusChanged();
  }

  void _onTextChange() {
    if (!mounted) return;
    setState(() {});
    onTextChanged();
  }

  /// Hook for subclasses to respond to text changes.
  void onTextChanged() {}

  /// Hook for subclasses to respond to focus changes.
  void onFocusChanged() {}
}
