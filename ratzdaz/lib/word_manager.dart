import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ratzdaz/question.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Layout/cyberpunk_theme.dart';
import 'Layout/cyberpunk_theme.dart';
import 'Status/auth_provider.dart';
import 'cluster_manager.dart';

class WordManager extends StatefulWidget {
  const WordManager({super.key});

  @override
  State<WordManager> createState() => _WordManagerState();
}

class _WordManagerState extends State<WordManager> {
  final _formKey = GlobalKey<FormState>();
  final _percentageController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isAuthenticated = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Neue Zustandsvariablen für die Statistik
  Map<int, int> _levelStatistics = {};
  Map<int, int> _clusterStatistics = {};
  int _totalWords = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentPercentage();
  }

  Future<void> _updateThreshold() async {
    if (_formKey.currentState!.validate()) {
      try {
        final username = context.read<AppAuthProvider>().username;
        if (username == null) return;

        final percentage = double.parse(_percentageController.text);

        await _firestore
            .collection('users')
            .doc(username)
            .update({'unlock_threshold': percentage});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Schwellenwert aktualisiert')),
          );
        }

        // Aktualisiere die Statistiken nach dem Update
        await _loadStatistics();
      } catch (e) {
        print('Fehler beim Aktualisieren des Schwellenwerts: $e');
      }
    }
  }

  Future<void> _loadCurrentPercentage() async {
    try {
      final username = context.read<AppAuthProvider>().username;
      if (username == null) return;

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(username).get();

      if (!userDoc.exists ||
          !(userDoc.data() as Map<String, dynamic>)
              .containsKey('unlock_threshold')) {
        await _firestore
            .collection('users')
            .doc(username)
            .set({'unlock_threshold': 60.0}, SetOptions(merge: true));
        _percentageController.text = '60.0';
      } else {
        _percentageController.text =
            (userDoc.get('unlock_threshold') as num).toString();
      }

      // Lade auch direkt die Statistiken
      if (_isAuthenticated) {
        await _loadStatistics();
      }
    } catch (e) {
      print('Fehler beim Laden des Schwellenwerts: $e');
    }
  }

  // Neue Methode zum Laden der Statistiken
  Future<void> _loadStatistics() async {
    if (!_isAuthenticated) return;

    setState(() => _isLoading = true);

    try {
      final username = context.read<AppAuthProvider>().username;
      if (username == null) return;

      print('\n=== STARTING STATISTICS LOAD ===');

      // 1. Lade alle Fragen
      final ref = FirebaseStorage.instance.ref().child('data/questions.json');
      final data = await ref.getData();
      final String jsonString = utf8.decode(data!);
      List<dynamic> jsonData = json.decode(jsonString);
      List<Question> allQuestions =
          jsonData.map((json) => Question.fromJson(json)).toList();

      print('Total questions loaded: ${allQuestions.length}');
      print('Questions per cluster:');
      var questionsPerCluster = <int, int>{};
      for (var q in allQuestions) {
        questionsPerCluster[q.cluster] =
            (questionsPerCluster[q.cluster] ?? 0) + 1;
      }
      questionsPerCluster.forEach((cluster, count) {
        print('Cluster $cluster: $count questions');
      });

      // 2. Lade die Level-Informationen
      print('\n=== LOADING PROGRESS DATA ===');
      DocumentSnapshot progressDoc =
          await _firestore.collection('quiz_progress').doc(username).get();

      // 3. Prüfe Cluster-Status
      print('\n=== CHECKING CLUSTER PROGRESS ===');
      final clusterManager = ClusterManager();
      await clusterManager.checkClusterProgress(allQuestions, username);
      List<int> unlockedClusters = clusterManager.unlockedClusters;
      print('Unlocked clusters: $unlockedClusters');

      // Reset Statistiken
      _levelStatistics = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};
      _clusterStatistics = {};
      _totalWords = 0;

      print('\n=== PROCESSING QUESTIONS ===');
      if (progressDoc.exists) {
        Map<String, dynamic> data = progressDoc.data() as Map<String, dynamic>;
        Map<String, dynamic> questions = data['questions'] ?? {};

        print('Progress data found for ${questions.length} questions');

        // Verarbeite Fragen nach Cluster
        for (int cluster in unlockedClusters) {
          print('\nProcessing Cluster $cluster:');
          var clusterQuestions =
              allQuestions.where((q) => q.cluster == cluster).toList();
          print(
              'Found ${clusterQuestions.length} questions in cluster $cluster');

          for (var question in clusterQuestions) {
            int level = 0;
            if (questions.containsKey(question.id)) {
              level = questions[question.id]['level'] ?? 0;
              print('Question ${question.id}: Level $level');
            }
            question.level = level;

            _levelStatistics[level] = (_levelStatistics[level] ?? 0) + 1;
            _clusterStatistics[cluster] =
                (_clusterStatistics[cluster] ?? 0) + 1;
            _totalWords++;
          }
        }

        print('\n=== FINAL STATISTICS ===');
        print('Total words: $_totalWords');
        print('Clusters: $_clusterStatistics');
        print('Levels: $_levelStatistics');
      } else {
        print('No progress data found');
      }
    } catch (e, stackTrace) {
      print('Error in _loadStatistics: $e');
      print('Stack trace: $stackTrace');
      _levelStatistics = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};
      _clusterStatistics = {};
      _totalWords = 0;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _authenticate() async {
    if (_passwordController.text == 'teacher') {
      setState(() => _isAuthenticated = true);
      _passwordController.clear();
      await _loadStatistics(); // Lade Statistiken nach erfolgreicher Authentifizierung
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falsches Passwort')),
        );
      }
    }
  }

  // Widget für die Statistik-Karte
  Widget _buildStatisticCard(String title, String value) {
    return Card(
      color: CyberpunkTheme.backgroundAccent.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: CyberpunkTheme.neonBlue,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget für die Level-Statistik
  Widget _buildLevelStatistics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Level-Übersicht',
          style: TextStyle(
            color: CyberpunkTheme.neonBlue,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(7, (index) {
          int count = _levelStatistics[index] ?? 0;
          double percentage = _totalWords > 0 ? (count / _totalWords) * 100 : 0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level $index: $count Wörter (${percentage.toStringAsFixed(1)}%)',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    CyberpunkTheme.neonBlue.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
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
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: CyberpunkTheme.neonBlue,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 20),
                Text(
                  'Wörtermanager',
                  style: TextStyle(
                    color: CyberpunkTheme.neonBlue,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                if (!_isAuthenticated) ...[
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Admin-Passwort',
                      labelStyle: TextStyle(color: CyberpunkTheme.neonBlue),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: CyberpunkTheme.neonBlue),
                      ),
                    ),
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _authenticate,
                    child: const Text('Authentifizieren'),
                  ),
                ] else ...[
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Schwellenwert-Einstellung
                          Form(
                            key: _formKey,
                            child: TextFormField(
                              controller: _percentageController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Freischaltungs-Schwellenwert (%)',
                                labelStyle:
                                    TextStyle(color: CyberpunkTheme.neonBlue),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: CyberpunkTheme.neonBlue),
                                ),
                              ),
                              style: const TextStyle(color: Colors.white),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Bitte einen Wert eingeben';
                                }
                                final number = double.tryParse(value);
                                if (number == null ||
                                    number < 0 ||
                                    number > 100) {
                                  return 'Bitte eine Zahl zwischen 0 und 100 eingeben';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _updateThreshold,
                            child: const Text('Schwellenwert aktualisieren'),
                          ),
                          const SizedBox(height: 40),

                          // Statistik-Übersicht
                          if (_isLoading)
                            const Center(child: CircularProgressIndicator())
                          else ...[
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatisticCard(
                                    'Gesamtzahl Wörter',
                                    '$_totalWords',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildStatisticCard(
                                    'Freigeschaltete Cluster',
                                    '${_clusterStatistics.length}',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            _buildLevelStatistics(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _percentageController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
