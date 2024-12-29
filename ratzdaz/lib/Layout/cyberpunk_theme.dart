import 'package:flutter/material.dart';

class CyberpunkTheme {
  // Hauptfarben
  static const Color background = Color(0xFF1B2838);
  static const Color backgroundAccent = Color(0xFF213345);
  static const Color neonBlue = Color(0xFF00F0FF);
  static const Color neonPink = Color(0xFFFF0080);
  static const Color darkGrey = Color(0xFF1A1A1F);
  static const Color lightGrey = Color(0xFF2A2A35);

  // Container Dekorationen
  static BoxDecoration gradientBackground = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        background,
        backgroundAccent,
      ],
    ),
  );

  static BoxDecoration glowingContainer({
    required Color glowColor,
    double opacity = 0.3,
    double spreadRadius = 1,
    double blurRadius = 8,
  }) {
    return BoxDecoration(
      color: darkGrey,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(
        color: glowColor.withOpacity(opacity),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: glowColor.withOpacity(opacity),
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
        ),
      ],
    );
  }

  // Button Styles
  static ButtonStyle elevatedButtonStyle({
    Color? backgroundColor,
    Color? foregroundColor,
    double borderRadius = 18.0,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? darkGrey,
      foregroundColor: foregroundColor ?? Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(
          color: neonBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
    );
  }

  // Icon Button Style
  static BoxDecoration iconButtonDecoration({Color? glowColor}) {
    return glowingContainer(
      glowColor: glowColor ?? neonBlue,
      opacity: 0.2,
      blurRadius: 10,
    );
  }

  // Score Display Style
  static BoxDecoration scoreDisplayDecoration = glowingContainer(
    glowColor: neonBlue,
    opacity: 0.2,
    blurRadius: 10,
    spreadRadius: 2,
  );
}
