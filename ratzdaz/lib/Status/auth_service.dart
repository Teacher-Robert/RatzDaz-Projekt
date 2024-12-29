import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerUser({
    required String username,
    required String password,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    try {
      if (username.isEmpty || password.isEmpty) {
        onError('Bitte alle Felder ausfüllen');
        return;
      }

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(username).get();
      if (userDoc.exists) {
        onError('Benutzername bereits vergeben');
        return;
      }

      await _firestore.collection('users').doc(username).set({
        'username': username,
        'password': password,
        'unlock_threshold': 60.0,
      });

      onSuccess('Benutzer erfolgreich registriert!');
    } catch (e) {
      onError('Fehler bei der Registrierung: $e');
    }
  }

  Future<void> loginUser({
    required String username,
    required String password,
    required Function(String) onSuccess,
    required Function(String) onError,
    required Function(String) onLoginSuccess,
  }) async {
    try {
      if (username.isEmpty || password.isEmpty) {
        onError('Bitte alle Felder ausfüllen');
        return;
      }

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(username).get();
      if (!userDoc.exists) {
        onError('Benutzername nicht gefunden!');
        return;
      }

      String storedPassword = userDoc.get('password');
      if (storedPassword != password) {
        onError('Falsches Passwort!');
        return;
      }

      onSuccess('Erfolgreich angemeldet!');
      onLoginSuccess(username);
    } catch (e) {
      onError('Fehler bei der Anmeldung: $e');
    }
  }
}
