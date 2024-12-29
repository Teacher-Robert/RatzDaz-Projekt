import 'package:flutter/material.dart';

class AppAuthProvider with ChangeNotifier {
  String? _username;

  String? get username => _username;
  bool get isLoggedIn => _username != null;

  void logIn(String username) {
    _username = username;
    notifyListeners();
  }

  void logOut() {
    _username = null;
    notifyListeners();
  }
}
