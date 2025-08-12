import 'package:flutter/material.dart';

class AppColors {
  // Primary brand color
  static const Color primary = Color(0xFFFFA726); // Light Orange

  // Background colors
  static const Color bgColor = Color(
    0xFFFDF6EC,
  ); // Light background (old name kept for compatibility)
  static const Color background = Color(
    0xFFFDF6EC,
  ); // Alias for bgColor to avoid errors

  // Text colors
  static const Color textDark = Color(0xFF3E2723);
  static const Color textLight = Color(0xFF8D6E63);

  // Optional extra surface color for cards
  static const Color surface = Colors.white;
}
