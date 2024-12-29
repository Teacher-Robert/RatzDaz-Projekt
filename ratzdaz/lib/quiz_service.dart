import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cluster_manager.dart';
import 'question.dart';

class QuizService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final String username;
  final ClusterManager _clusterManager; // Wichtig: Als final deklarieren

  QuizService({
    required this.username,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _clusterManager = ClusterManager(); // Hier initialisieren

  Future<List<Question>> loadQuestions() async {
    try {
      print('DEBUG: QuizService - Start loadQuestions');

      // 1. Lade die JSON-Datei aus Firebase Storage
      final ref = _storage.ref().child('data/questions.json');
      final data = await ref.getData();
      final String jsonString = utf8.decode(data!);
      List<dynamic> jsonData = json.decode(jsonString);

      // 2. Konvertiere alle Fragen
      List<Question> allQuestions =
          jsonData.map((json) => Question.fromJson(json)).toList();
      print(
          'DEBUG: QuizService - Gesamtanzahl Fragen geladen: ${allQuestions.length}');

      // 3. Update Level aus Firebase
      DocumentSnapshot progressDoc =
          await _firestore.collection('quiz_progress').doc(username).get();
      if (progressDoc.exists) {
        Map<String, dynamic> userData =
            progressDoc.data() as Map<String, dynamic>;
        Map<String, dynamic> questionsData = userData['questions'] ?? {};

        print('DEBUG: QuizService - Aktualisiere Level aus quiz_progress');
        for (var question in allQuestions) {
          if (questionsData.containsKey(question.id)) {
            question.level = questionsData[question.id]['level'] ?? 0;
            print(
                'DEBUG: QuizService - Update Level für ${question.id} auf ${question.level}');
          }
        }
      }

      // 4. Cluster-Überprüfung durchführen
      print('DEBUG: QuizService - Starte Cluster-Überprüfung');
      await _clusterManager.checkClusterProgress(allQuestions, username);

      // 5. Fragen basierend auf freigeschalteten Clustern filtern
      List<int> availableClusters = _clusterManager.unlockedClusters;
      print(
          'DEBUG: QuizService - Verfügbare Cluster vor Filterung: $availableClusters');

      List<Question> availableQuestions = allQuestions
          .where((q) => availableClusters.contains(q.cluster))
          .toList();

      print('DEBUG: QuizService - Nach Filterung:');
      print(
          'DEBUG: QuizService - Verfügbare Fragen: ${availableQuestions.length}');
      print(
          'DEBUG: QuizService - Cluster-Verteilung: ${availableQuestions.map((q) => q.cluster).toSet().toList()}');

      // Detaillierte Analyse der gefilterten Fragen
      for (int cluster in availableClusters) {
        int count =
            availableQuestions.where((q) => q.cluster == cluster).length;
        print('DEBUG: QuizService - Fragen in Cluster $cluster: $count');
      }

      return availableQuestions;
    } catch (e) {
      print('DEBUG: QuizService - Fehler beim Laden der Fragen: $e');
      rethrow;
    }
  }
}
