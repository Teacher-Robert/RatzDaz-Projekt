import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Layout/cyberpunk_theme.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: CyberpunkTheme.darkGrey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: CyberpunkTheme.neonBlue.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: CyberpunkTheme.neonBlue.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.logout,
                color: CyberpunkTheme.neonBlue,
                size: 24,
              ),
              onPressed: () => Navigator.pushReplacementNamed(context, '/'),
              tooltip: 'Ausloggen',
            ),
          ),
          Text(
            'RatzDAZ',
            style: GoogleFonts.orbitron(
              color: CyberpunkTheme.neonBlue,
              fontSize: 68,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: CyberpunkTheme.neonBlue.withOpacity(0.5),
                  offset: const Offset(0, 0),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
          ), // Placeholder für Balance auf der rechten Seite
        ],
      ),
    );
  }

  Widget _buildGameButton({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required String route,
  }) {
    return Container(
      width: 300, // Reduzierte Breite des Buttons
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: CyberpunkTheme.darkGrey,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: CyberpunkTheme.neonBlue.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CyberpunkTheme.neonBlue.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, route),
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CyberpunkTheme.neonBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: CyberpunkTheme.neonBlue,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.rajdhani(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: GoogleFonts.rajdhani(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: CyberpunkTheme.neonBlue.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              CyberpunkTheme.background,
              CyberpunkTheme.backgroundAccent,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(context),
              const SizedBox(height: 10),
              Padding(
                padding:
                    const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 0.0),
                child: Text(
                  'Willkommen zurück!',
                  style: GoogleFonts.rajdhani(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40), // Abstand zwischen Text und Buttons
              Center(
                child: Column(
                  children: [
                    _buildGameButton(
                      context: context,
                      title: 'Starte das Spiel',
                      description: 'Teste dein Wissen und sammle Punkte',
                      icon: Icons.play_arrow_rounded,
                      route: '/quiz',
                    ),
                    _buildGameButton(
                      context: context,
                      title: 'Belohnungsshop',
                      description:
                          'Tausche deine Punkte gegen tolle Belohnungen',
                      icon: Icons.shopping_bag_outlined,
                      route: '/shop',
                    ),
                    _buildGameButton(
                      context: context,
                      title: 'Wörtermanager',
                      description: 'Cluster-Freischaltung anpassen',
                      icon: Icons.settings,
                      route: '/word-manager',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
