import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'Status/auth_provider.dart';
import 'Layout/cyberpunk_theme.dart';
import 'quiz_service.dart';
import 'question.dart';
import 'Layout/layout_quiz.dart';
import 'quiz_types.dart';
import 'quiz_state_manager.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late QuizStateManager _quizManager;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final username = context.read<AppAuthProvider>().username;
    _quizManager = QuizStateManager(username: username ?? '');
    _initializeQuiz();
  }

  Future<void> _initializeQuiz() async {
    setState(() => _isLoading = true);
    await _quizManager.initialize();
    setState(() => _isLoading = false);
  }

  void _showAnswerFeedback(bool isCorrect) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: CyberpunkTheme.darkGrey.withOpacity(0.95),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isCorrect
                    ? CyberpunkTheme.neonBlue.withOpacity(0.6)
                    : CyberpunkTheme.neonPink.withOpacity(0.6),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isCorrect
                      ? CyberpunkTheme.neonBlue.withOpacity(0.2)
                      : CyberpunkTheme.neonPink.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel_outlined,
                  color: isCorrect
                      ? CyberpunkTheme.neonBlue
                      : CyberpunkTheme.neonPink,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  isCorrect ? 'Richtig' : 'Falsch',
                  style: TextStyle(
                    color: isCorrect
                        ? CyberpunkTheme.neonBlue
                        : CyberpunkTheme.neonPink,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                    decoration: TextDecoration.none, // Keine Unterstreichung
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Automatisch schließen nach 800ms
    Future.delayed(const Duration(milliseconds: 800), () {
      Navigator.of(context).pop();
    });
  }

  void _showEndDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: CyberpunkTheme.darkGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: CyberpunkTheme.neonBlue.withOpacity(0.3),
            width: 1,
          ),
        ),
        title: Text(
          "Sehr gut gemacht!",
          style: TextStyle(
            color: CyberpunkTheme.neonBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Du hast nun ${_quizManager.points} Punkte!\nWillst du zurück ins Hauptmenü oder erneut spielen?",
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          Container(
            decoration: CyberpunkTheme.iconButtonDecoration(),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/game');
              },
              icon: const Icon(Icons.home),
              color: CyberpunkTheme.neonBlue,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: CyberpunkTheme.iconButtonDecoration(),
            child: IconButton(
              onPressed: () {
                setState(() {
                  _quizManager = QuizStateManager(
                      username: context.read<AppAuthProvider>().username ?? '');
                  _initializeQuiz();
                });
                Navigator.pop(context);
              },
              icon: const Icon(Icons.replay),
              color: CyberpunkTheme.neonBlue,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAnswer(String answer) async {
    final result = await _quizManager.handleAnswer(answer);
    if (result == true) {
      if (mounted) {
        _showAnswerFeedback(true);
      }
      if (_quizManager.isQuizFinished) {
        await Future.delayed(const Duration(milliseconds: 1000));
        _showEndDialog();
      } else {
        await Future.delayed(const Duration(milliseconds: 1000));
        await _quizManager.moveToNextQuestion();
        if (mounted) {
          setState(() {});
        }
      }
    } else if (result == false) {
      if (mounted) {
        _showAnswerFeedback(false);
        await Future.delayed(const Duration(milliseconds: 1000));
      }
      await _quizManager.moveToNextQuestion();
      if (mounted) {
        setState(() {});
      }
    } else {
      if (mounted) {
        _showAnswerFeedback(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _quizManager.isLoading) {
      return Scaffold(
        backgroundColor: CyberpunkTheme.background,
        body: Center(
          child: CircularProgressIndicator(
            color: CyberpunkTheme.neonBlue,
          ),
        ),
      );
    }
    return QuizScreenLayout(
      data: QuizScreenData(
        points: _quizManager.points,
        currentQuestionIndex: _quizManager.currentQuestionIndex,
        maxQuestions: _quizManager.maxQuestions,
        imageUrl: _quizManager.imageUrl,
        hasAudio: _quizManager.audioUrl.isNotEmpty,
        shuffledAnswers: _quizManager.shuffledAnswers,
      ),
      onBackPressed: () => Navigator.pushNamed(context, '/game'),
      onAnswerSelected: _handleAnswer,
      onAudioPressed: () {
        _quizManager.audioPlayer.setSourceUrl(_quizManager.audioUrl);
        _quizManager.audioPlayer.resume();
      },
    );
  }

  @override
  void dispose() {
    _quizManager.dispose();
    super.dispose();
  }
}
