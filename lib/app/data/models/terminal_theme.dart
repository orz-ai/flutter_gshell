import 'package:flutter/material.dart';

class TerminalThemeData {
  final String name;
  final Color background;
  final Color foreground;
  
  TerminalThemeData({
    required this.name,
    required this.background,
    required this.foreground,
  });
  
  static List<TerminalThemeData> presetThemes = [
    TerminalThemeData(
      name: 'Default Dark',
      background: const Color(0xFF121212),
      foreground: Colors.white,
    ),
    TerminalThemeData(
      name: 'Solarized Dark',
      background: const Color(0xFF002B36),
      foreground: const Color(0xFF839496),
    ),
  ];
} 