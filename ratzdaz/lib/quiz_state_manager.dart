import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import 'quiz_service.dart';
import 'question.dart';
import 'cluster_manager.dart';

class QuizStateManager {
  final FirebaseFirestore _firestore;
  final AudioPlayer audioPlayer;
  final String username;
  late final QuizService
      _quizService; // Verwenden Sie 'late', da wir es im Konstruktor initialisieren
  final ClusterManager _clusterManager = ClusterManager();

  final int maxQuestions = 10;
  List<Question> questions = [];
  int currentQuestionIndex = 0;
  String imageUrl = '';
  String audioUrl = '';
  int points = 0;
  int attempts = 0;
  List<String> shuffledAnswers = [];
  bool isLoading = true;

  QuizStateManager({
    required this.username,
    FirebaseFirestore? firestore,
    AudioPlayer? player,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        audioPlayer = player ?? AudioPlayer() {
    // Initialisiere QuizService mit dem username
    _quizService = QuizService(username: username, firestore: _firestore);
  }

  Future<void> initialize() async {
    try {
      await loadUserProgress(); // Erst User-Fortschritt laden
      await loadQuestions(); // Dann Fragen laden (inkl. Cluster-Check)
      isLoading = false;
    } catch (e) {
      print('Fehler bei der Initialisierung: $e');
      isLoading = false;
    }
  }

  Future<void> loadUserProgress() async {
    if (username.isEmpty) {
      print('Kein Benutzer angemeldet');
      return;
    }

    DocumentSnapshot userDoc =
        await _firestore.collection('quiz_progress').doc(username).get();

    if (userDoc.exists) {
      points = userDoc['points'] ?? 0;
    }
  }

  Future<void> loadQuestions() async {
    try {
      var allQuestions = await _quizService.loadQuestions();

      // Prüfe Cluster-Fortschritt
      _clusterManager.checkClusterProgress(allQuestions, username);

      // Wähle Fragen basierend auf Level-Gewichtung und Clustern
      questions =
          _clusterManager.selectQuestionsForQuiz(allQuestions, maxQuestions);

      if (questions.isNotEmpty) {
        _shuffleAnswers();
        await loadMedia();
      } else {
        print('Keine Fragen verfügbar.');
      }
    } catch (e) {
      print('Fehler beim Laden der Fragen: $e');
    }
  }

  void _shuffleAnswers() {
    if (questions.isEmpty || currentQuestionIndex >= questions.length) return;

    Question currentQuestion = questions[currentQuestionIndex];
    shuffledAnswers = List.from(currentQuestion.getAllAnswers());
    shuffledAnswers.shuffle();
  }

  Future<void> loadMedia() async {
    if (questions.isEmpty || currentQuestionIndex >= questions.length) {
      imageUrl = 'https://via.placeholder.com/150?text=Bild+nicht+verfügbar';
      audioUrl = '';
      return;
    }

    try {
      Question currentQuestion = questions[currentQuestionIndex];

      final refImage =
          FirebaseStorage.instance.ref().child(currentQuestion.imagePath);
      imageUrl = await refImage.getDownloadURL();

      DocumentSnapshot userDoc =
          await _firestore.collection('quiz_progress').doc(username).get();

      Map<String, dynamic> userData =
          userDoc.data() as Map<String, dynamic>? ?? {};
      Map<String, dynamic> questionsData = userData['questions'] ?? {};
      Map<String, dynamic> currentQuestionData =
          questionsData[currentQuestion.id] ?? {'level': 0};

      int currentLevel = currentQuestionData['level'];

      if (currentLevel < 3) {
        try {
          final refAudio =
              FirebaseStorage.instance.ref().child(currentQuestion.audioPath);
          audioUrl = await refAudio.getDownloadURL();
        } catch (audioError) {
          print('Fehler beim Laden der Audiodatei: $audioError');
          audioUrl = '';
        }
      } else {
        audioUrl = '';
      }
    } catch (e) {
      print('Fehler beim Laden der Medien: $e');
      try {
        final placeholderRef =
            FirebaseStorage.instance.ref().child('images/placeholder.jpg');
        imageUrl = await placeholderRef.getDownloadURL();
      } catch (placeholderError) {
        print('Fehler beim Laden des Platzhalter-Bildes: $placeholderError');
        imageUrl = 'https://via.placeholder.com/150?text=Bild+nicht+verfügbar';
      }
    }
  }

  Future<bool?> handleAnswer(String selectedAnswer) async {
    Question currentQuestion = questions[currentQuestionIndex];
    bool isCorrect = selectedAnswer == currentQuestion.correctAnswer;

    if (username.isEmpty) {
      print('Kein Benutzer angemeldet');
      return null;
    }

    DocumentSnapshot userDoc =
        await _firestore.collection('quiz_progress').doc(username).get();

    Map<String, dynamic> userData =
        userDoc.data() as Map<String, dynamic>? ?? {};
    Map<String, dynamic> questionsData = userData['questions'] ?? {};
    Map<String, dynamic> currentQuestionData =
        questionsData[currentQuestion.id] ?? {'level': 0, 'attempts': 0};

    int currentLevel = currentQuestionData['level'];

    if (isCorrect && attempts == 0) {
      points += 2;
      currentLevel++;
      attempts = 0;
      await updateFirestore(currentQuestion, currentLevel);
      return true;
    } else if (isCorrect) {
      attempts = 0;
      await updateFirestore(currentQuestion, currentLevel);
      return true;
    } else {
      attempts++;

      if (attempts >= 2) {
        currentLevel = (currentLevel > 0) ? currentLevel - 1 : 0;
        attempts = 0;
        await updateFirestore(currentQuestion, currentLevel);
        return false;
      }
      return null;
    }
  }

  Future<void> updateFirestore(Question question, int level) async {
    await _firestore.collection('quiz_progress').doc(username).set({
      'points': points,
      'questions': {
        question.id: {
          'Vokabel': question.correctAnswer,
          'level': level,
          'attempts': FieldValue.increment(1)
        }
      }
    }, SetOptions(merge: true));
  }

  Future<void> moveToNextQuestion() async {
    if (!isQuizFinished) {
      currentQuestionIndex++;
      attempts = 0;
      await loadMedia();
      _shuffleAnswers();
    }
  }

  bool get isQuizFinished => currentQuestionIndex >= maxQuestions - 1;

  void dispose() {
    audioPlayer.dispose();
  }
}
