import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginController {
  // Text controllers for form fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Firebase instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Dispose method to clean up controllers
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }

  // Login logic
  Future<void> handleLogin(BuildContext context) async {
    try {
      // Show loading indicator
      _showLoadingDialog(context);

      // Attempt to sign in
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // Hide loading indicator
      Navigator.pop(context);

      if (userCredential.user != null) {
        // Navigate to home screen on successful login
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      // Hide loading indicator
      Navigator.pop(context);

      // Show error message
      _showErrorDialog(context, _getErrorMessage(e.code));
    } catch (e) {
      // Hide loading indicator
      Navigator.pop(context);

      // Show generic error message
      _showErrorDialog(context, 'Ein unerwarteter Fehler ist aufgetreten.');
    }
  }

  // Helper method to show loading dialog
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // Helper method to show error dialog
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fehler'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Helper method to get localized error messages
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Kein Benutzer mit dieser E-Mail-Adresse gefunden.';
      case 'wrong-password':
        return 'Falsches Passwort.';
      case 'invalid-email':
        return 'Ungültige E-Mail-Adresse.';
      case 'user-disabled':
        return 'Dieser Benutzer wurde deaktiviert.';
      default:
        return 'Ein Fehler ist aufgetreten beim Anmelden.';
    }
  }
}
