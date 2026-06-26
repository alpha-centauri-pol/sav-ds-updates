import 'package:flutter/foundation.dart';

/// Demo-only registry that collects the live code snippet for each component
/// playground so the gallery can show "active" configurations. Not part of the
/// `sav_ds` library — it exists purely to drive the example app.
class PlaygroundRegistry {
  PlaygroundRegistry._();
  static final PlaygroundRegistry instance = PlaygroundRegistry._();

  final ValueNotifier<Map<String, String>> snippets = ValueNotifier({});

  void register(String id, String code) {
    // Avoid notifying listeners if there's no actual change, to prevent
    // unnecessary rebuilds.
    if (snippets.value[id] == code) return;

    // Create a new map instance so listeners are triggered.
    snippets.value = Map<String, String>.from(snippets.value)..[id] = code;
  }
}
