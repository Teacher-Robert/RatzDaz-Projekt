import 'package:flutter/material.dart';

class AppTheme {
  // Hauptfarben für die App
  static const Color primaryColor = Colors.blueGrey;
  static const Color buttonColor = Colors.white;
  static const Color buttonTextColor = Colors.black;
  static const Color backgroundColor = Colors.blueGrey;

  // Standard Textstil für den App-Text
  static const TextStyle appTitleStyle = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 20,
    color: buttonTextColor,
  );

  // Button-Layout-Informationen für ElevatedButton (Material 3)
  static ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: buttonColor, // Hintergrundfarbe des Buttons
    foregroundColor: buttonTextColor, // Textfarbe auf dem Button
    padding: const EdgeInsets.symmetric(
        horizontal: 50, vertical: 20), // Größe des Buttons
  );

  // Layout für Registrierung-Button (angepasst an Material 3)
  static ButtonStyle registerButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: buttonColor,
    foregroundColor: buttonTextColor,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  );

  // Gesamthintergrund
  static BoxDecoration appBackground = const BoxDecoration(
    color: backgroundColor, // Hintergrundfarbe
  );
}
