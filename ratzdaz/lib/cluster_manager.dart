import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'question.dart';

class ClusterManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final List<int> _unlockedClusters = [1];

  List<int> get unlockedClusters => List.unmodifiable(_unlockedClusters);

  Future<void> checkClusterProgress(
      List<Question> allQuestions, String username) async {
    try {
      // Get user's progress data first
      DocumentSnapshot progressDoc =
          await _firestore.collection('quiz_progress').doc(username).get();
      Map<String, dynamic> progressData =
          progressDoc.exists ? progressDoc.data() as Map<String, dynamic> : {};
      Map<String, dynamic> questions = progressData['questions'] ?? {};

      // Get threshold from user document
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(username).get();
      double threshold = userDoc.get('unlock_threshold') ?? 60.0;

      // Reset clusters and always add cluster 1
      _unlockedClusters.clear();
      _unlockedClusters.add(1);

      // Get all unique cluster numbers
      List<int> allClusters =
          allQuestions.map((q) => q.cluster).toSet().toList()..sort();

      // Check each cluster sequentially
      for (int i = 0; i < allClusters.length - 1; i++) {
        int currentCluster = allClusters[i];
        int nextCluster = allClusters[i + 1];

        // Get questions for current cluster
        var clusterQuestions =
            allQuestions.where((q) => q.cluster == currentCluster).toList();

        int levelTwoOrHigherCount = 0;

        // Count questions at level 2 or higher
        for (var question in clusterQuestions) {
          if (questions.containsKey(question.id)) {
            int level = questions[question.id]['level'] ?? 0;
            if (level >= 2) levelTwoOrHigherCount++;
          }
        }

        double percentage =
            (levelTwoOrHigherCount / clusterQuestions.length) * 100;

        print('Cluster $currentCluster stats:');
        print('Total questions: ${clusterQuestions.length}');
        print('Level 2 or higher: $levelTwoOrHigherCount');
        print('Percentage: $percentage%');
        print('Threshold: $threshold%');

        // If threshold is met, unlock next cluster
        if (percentage >= threshold) {
          _unlockedClusters.add(nextCluster);
        } else {
          break; // Stop checking further clusters if threshold is not met
        }
      }

      print('Final unlocked clusters: $_unlockedClusters');
    } catch (e) {
      print('Error in checkClusterProgress: $e');
      _unlockedClusters.clear();
      _unlockedClusters.add(1);
    }
  }

  Map<int, double> calculateLevelWeights(List<Question> questions) {
    final factors = {
      0: 2.0, // Neue Wörter
      1: 1.8, // Kürzlich gelernt
      2: 1.6, // In Bearbeitung
      3: 1.4, // Gut bekannt
      4: 1.2, // Sehr gut bekannt
      5: 1.0, // Fast gemeistert
      6: 0.0 // Gemeistert
    };

    Map<int, int> levelCounts = {};
    for (var q in questions) {
      levelCounts[q.level] = (levelCounts[q.level] ?? 0) + 1;
    }

    Map<int, double> weights = {};
    double totalWeight = 0;

    for (var level in levelCounts.keys) {
      double percentage = levelCounts[level]! / questions.length;
      double weight = percentage * (factors[level] ?? 0.0);
      weights[level] = weight;
      totalWeight += weight;
    }

    if (totalWeight > 0) {
      weights.forEach((level, weight) {
        weights[level] = weight / totalWeight;
      });
    }

    return weights;
  }

  List<Question> selectQuestionsForQuiz(
      List<Question> allQuestions, int numberOfQuestions) {
    var availableQuestions = allQuestions
        .where((q) => _unlockedClusters.contains(q.cluster))
        .toList();

    if (availableQuestions.isEmpty) return [];

    // Statistik für alle verfügbaren Fragen
    Map<int, int> totalLevelStats = {};
    for (var question in availableQuestions) {
      totalLevelStats[question.level] =
          (totalLevelStats[question.level] ?? 0) + 1;
    }

    print('\nLevel-Statistik aller verfügbaren Fragen:');
    for (int i = 0; i <= 6; i++) {
      print('Level $i: ${totalLevelStats[i] ?? 0} Wörter');
    }

    List<Question> selectedQuestions = [];
    Random random = Random();

    while (selectedQuestions.length < numberOfQuestions &&
        availableQuestions.isNotEmpty) {
      Map<int, double> weights = calculateLevelWeights(availableQuestions);

      double randomValue = random.nextDouble();
      double cumulativeProbability = 0.0;
      int selectedLevel = 0;

      for (var entry in weights.entries) {
        cumulativeProbability += entry.value;
        if (randomValue <= cumulativeProbability) {
          selectedLevel = entry.key;
          break;
        }
      }

      var questionsForLevel =
          availableQuestions.where((q) => q.level == selectedLevel).toList();

      if (questionsForLevel.isNotEmpty) {
        var selectedQuestion =
            questionsForLevel[random.nextInt(questionsForLevel.length)];
        selectedQuestions.add(selectedQuestion);
        availableQuestions.remove(selectedQuestion);
      }
    }

    return selectedQuestions;
  }
}
