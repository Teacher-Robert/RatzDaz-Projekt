import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:ratzdaz/quiz_screen.dart';
import 'package:ratzdaz/shop_screen.dart';
import 'Status/firebase_options.dart';
import 'Status/login_screen.dart';
import 'game_screen.dart';
import 'package:provider/provider.dart';
import 'Status/auth_provider.dart';
import 'word_manager.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
    );

    await FirebaseAuth.instance.signInAnonymously();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppAuthProvider>(
            create: (_) => AppAuthProvider(),
          ),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    print('Initialisierungsfehler: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RatzDAZ App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/game': (context) => const GameScreen(),
        '/quiz': (context) => const QuizScreen(),
        '/shop': (context) => const ShopScreen(),
        '/word-manager': (context) => const WordManager(),
      },
    );
  }
}
