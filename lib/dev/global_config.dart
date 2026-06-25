import 'package:flutter/foundation.dart';

class PlaygroundRegistry {
  static final PlaygroundRegistry instance = PlaygroundRegistry._();
  PlaygroundRegistry._();

  final ValueNotifier<Map<String, String>> snippets = ValueNotifier({});

  void register(String id, String code) {
    // Avoid notifying listeners if there's no actual change to prevent unnecessary rebuilds
    if (snippets.value[id] == code) return;
    
    // Create a new map to ensure listeners are triggered
    final newMap = Map<String, String>.from(snippets.value);
    newMap[id] = code;
    snippets.value = newMap;
  }
}

class GlobalConfig {
  static final ValueNotifier<double> pressSensitivity = ValueNotifier(1.0);
}
