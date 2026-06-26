import 'package:flutter/material.dart';

/// Formats a [Color] as the Dart source literal shown in generated snippets,
/// e.g. `Color(0xFF1F1F1F)`.
String colorLiteral(Color c) =>
    'Color(0x${c.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()})';
