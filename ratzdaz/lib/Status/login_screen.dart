import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import '../Layout/cyberpunk_theme.dart';
import 'auth_service.dart';

class LoginScreen extends StatelessWidget {
  final AuthService _authService = AuthService();
  final String _teacherPassword = "teacher";

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: CyberpunkTheme.gradientBackground,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'RatzDAZ',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    color: CyberpunkTheme.neonBlue,
                    fontSize: 62,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: CyberpunkTheme.neonBlue.withOpacity(0.5),
                        offset: const Offset(0, 0),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Container(
                  width: 300,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: CyberpunkTheme.glowingContainer(
                    glowColor: CyberpunkTheme.neonBlue,
                  ),
                  child: ElevatedButton(
                    onPressed: () => _showTeacherPasswordDialog(context),
                    style: CyberpunkTheme.elevatedButtonStyle(
                      backgroundColor: CyberpunkTheme.darkGrey,
                      foregroundColor: CyberpunkTheme.neonBlue,
                    ),
                    child: const Text('Registrierung',
                        style: TextStyle(fontSize: 18)),
                  ),
                ),
                Container(
                  width: 300,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: CyberpunkTheme.glowingContainer(
                    glowColor: CyberpunkTheme.neonBlue,
                  ),
                  child: ElevatedButton(
                    onPressed: () => _showLoginDialog(context),
                    style: CyberpunkTheme.elevatedButtonStyle(
                      backgroundColor: CyberpunkTheme.darkGrey,
                      foregroundColor: CyberpunkTheme.neonBlue,
                    ),
                    child:
                        const Text('Anmeldung', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTeacherPasswordDialog(BuildContext context) {
    TextEditingController passwordController = TextEditingController();
    bool isPasswordVisible = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: CyberpunkTheme.darkGrey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: const Text(
                'Lehrer-Authentifizierung',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              content: TextField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Lehrer-Passwort',
                  labelStyle: TextStyle(color: CyberpunkTheme.neonBlue),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: CyberpunkTheme.neonBlue.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: CyberpunkTheme.neonBlue,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: CyberpunkTheme.neonBlue,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Abbrechen',
                    style: TextStyle(
                      color: CyberpunkTheme.neonPink,
                      fontSize: 16,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (passwordController.text == _teacherPassword) {
                      Navigator.pop(context);
                      _showRegistrationDialog(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Falsches Passwort'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Bestätigen',
                    style: TextStyle(
                      color: CyberpunkTheme.neonBlue,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showRegistrationDialog(BuildContext context) {
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: CyberpunkTheme.darkGrey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Registrierung',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Benutzername',
                  labelStyle: TextStyle(color: CyberpunkTheme.neonBlue),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: CyberpunkTheme.neonBlue.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: CyberpunkTheme.neonBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Passwort',
                  labelStyle: TextStyle(color: CyberpunkTheme.neonBlue),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: CyberpunkTheme.neonBlue.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: CyberpunkTheme.neonBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Abbrechen',
                style: TextStyle(
                  color: CyberpunkTheme.neonPink,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _authService.registerUser(
                  username: usernameController.text,
                  password: passwordController.text,
                  onSuccess: (message) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                    Navigator.of(context).pop();
                  },
                  onError: (message) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  },
                );
              },
              child: Text(
                'Registrieren',
                style: TextStyle(
                  color: CyberpunkTheme.neonBlue,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLoginDialog(BuildContext context) {
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: CyberpunkTheme.darkGrey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Anmeldung',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Benutzername',
                  labelStyle: TextStyle(color: CyberpunkTheme.neonBlue),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: CyberpunkTheme.neonBlue.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: CyberpunkTheme.neonBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Passwort',
                  labelStyle: TextStyle(color: CyberpunkTheme.neonBlue),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: CyberpunkTheme.neonBlue.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: CyberpunkTheme.neonBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Abbrechen',
                style: TextStyle(
                  color: CyberpunkTheme.neonPink,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _authService.loginUser(
                  username: usernameController.text,
                  password: passwordController.text,
                  onSuccess: (message) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  },
                  onError: (message) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  },
                  onLoginSuccess: (username) {
                    context.read<AppAuthProvider>().logIn(username);
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, '/game');
                  },
                );
              },
              child: Text(
                'Anmelden',
                style: TextStyle(
                  color: CyberpunkTheme.neonBlue,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
