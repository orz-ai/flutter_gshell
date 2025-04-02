import 'package:flutter/material.dart';

class TerminalThemeData {
  final Color background;
  final Color foreground;
  final Color cursor;
  final Color selection;
  final Color black;
  final Color red;
  final Color green;
  final Color yellow;
  final Color blue;
  final Color magenta;
  final Color cyan;
  final Color white;
  final Color brightBlack;
  final Color brightRed;
  final Color brightGreen;
  final Color brightYellow;
  final Color brightBlue;
  final Color brightMagenta;
  final Color brightCyan;
  final Color brightWhite;
  final String name;

  const TerminalThemeData({
    required this.background,
    required this.foreground,
    required this.cursor,
    required this.selection,
    required this.black,
    required this.red,
    required this.green,
    required this.yellow,
    required this.blue,
    required this.magenta,
    required this.cyan,
    required this.white,
    required this.brightBlack,
    required this.brightRed,
    required this.brightGreen,
    required this.brightYellow,
    required this.brightBlue,
    required this.brightMagenta,
    required this.brightCyan,
    required this.brightWhite,
    required this.name,
  });

  // 默认主题
  static const TerminalThemeData defaultTheme = TerminalThemeData(
    name: '默认主题',
    background: Color(0xFF1E1E1E),
    foreground: Color(0xFFD4D4D4),
    cursor: Color(0xFFD4D4D4),
    selection: Color(0xFF264F78),
    black: Color(0xFF000000),
    red: Color(0xFFCD3131),
    green: Color(0xFF0DBC79),
    yellow: Color(0xFFE5E510),
    blue: Color(0xFF2472C8),
    magenta: Color(0xFFBC3FBC),
    cyan: Color(0xFF11A8CD),
    white: Color(0xFFE5E5E5),
    brightBlack: Color(0xFF666666),
    brightRed: Color(0xFFF14C4C),
    brightGreen: Color(0xFF23D18B),
    brightYellow: Color(0xFFF5F543),
    brightBlue: Color(0xFF3B8EEA),
    brightMagenta: Color(0xFFD670D6),
    brightCyan: Color(0xFF29B8DB),
    brightWhite: Color(0xFFFFFFFF),
  );

  // 预设主题列表
  static final List<TerminalThemeData> presetThemes = [
    defaultTheme,
    const TerminalThemeData(
      name: '暗黑主题',
      background: Color(0xFF000000),
      foreground: Color(0xFFFFFFFF),
      cursor: Color(0xFFFFFFFF),
      selection: Color(0xFF4D4D4D),
      black: Color(0xFF000000),
      red: Color(0xFFFF0000),
      green: Color(0xFF00FF00),
      yellow: Color(0xFFFFFF00),
      blue: Color(0xFF0000FF),
      magenta: Color(0xFFFF00FF),
      cyan: Color(0xFF00FFFF),
      white: Color(0xFFFFFFFF),
      brightBlack: Color(0xFF808080),
      brightRed: Color(0xFFFF0000),
      brightGreen: Color(0xFF00FF00),
      brightYellow: Color(0xFFFFFF00),
      brightBlue: Color(0xFF0000FF),
      brightMagenta: Color(0xFFFF00FF),
      brightCyan: Color(0xFF00FFFF),
      brightWhite: Color(0xFFFFFFFF),
    ),
    const TerminalThemeData(
      name: 'Solarized Dark',
      background: Color(0xFF002B36),
      foreground: Color(0xFF839496),
      cursor: Color(0xFF839496),
      selection: Color(0xFF073642),
      black: Color(0xFF073642),
      red: Color(0xFFDC322F),
      green: Color(0xFF859900),
      yellow: Color(0xFFB58900),
      blue: Color(0xFF268BD2),
      magenta: Color(0xFFD33682),
      cyan: Color(0xFF2AA198),
      white: Color(0xFFEEE8D5),
      brightBlack: Color(0xFF002B36),
      brightRed: Color(0xFFCB4B16),
      brightGreen: Color(0xFF586E75),
      brightYellow: Color(0xFF657B83),
      brightBlue: Color(0xFF839496),
      brightMagenta: Color(0xFF6C71C4),
      brightCyan: Color(0xFF93A1A1),
      brightWhite: Color(0xFFFDF6E3),
    ),
    const TerminalThemeData(
      name: 'Solarized Light',
      background: Color(0xFFFDF6E3),
      foreground: Color(0xFF657B83),
      cursor: Color(0xFF657B83),
      selection: Color(0xFFEEE8D5),
      black: Color(0xFF073642),
      red: Color(0xFFDC322F),
      green: Color(0xFF859900),
      yellow: Color(0xFFB58900),
      blue: Color(0xFF268BD2),
      magenta: Color(0xFFD33682),
      cyan: Color(0xFF2AA198),
      white: Color(0xFFEEE8D5),
      brightBlack: Color(0xFF002B36),
      brightRed: Color(0xFFCB4B16),
      brightGreen: Color(0xFF586E75),
      brightYellow: Color(0xFF657B83),
      brightBlue: Color(0xFF839496),
      brightMagenta: Color(0xFF6C71C4),
      brightCyan: Color(0xFF93A1A1),
      brightWhite: Color(0xFFFDF6E3),
    ),
    const TerminalThemeData(
      name: 'One Dark',
      background: Color(0xFF282C34),
      foreground: Color(0xFFABB2BF),
      cursor: Color(0xFFABB2BF),
      selection: Color(0xFF3E4451),
      black: Color(0xFF5C6370),
      red: Color(0xFFE06C75),
      green: Color(0xFF98C379),
      yellow: Color(0xFFE5C07B),
      blue: Color(0xFF61AFEF),
      magenta: Color(0xFFC678DD),
      cyan: Color(0xFF56B6C2),
      white: Color(0xFFABB2BF),
      brightBlack: Color(0xFF4B5263),
      brightRed: Color(0xFFBE5046),
      brightGreen: Color(0xFF98C379),
      brightYellow: Color(0xFFD19A66),
      brightBlue: Color(0xFF61AFEF),
      brightMagenta: Color(0xFFC678DD),
      brightCyan: Color(0xFF56B6C2),
      brightWhite: Color(0xFFFFFFFF),
    ),
  ];
} 