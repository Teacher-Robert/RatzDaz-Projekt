class QuizScreenData {
  final int points;
  final int currentQuestionIndex;
  final int maxQuestions;
  final String imageUrl;
  final bool hasAudio;
  final List<String> shuffledAnswers;

  QuizScreenData({
    required this.points,
    required this.currentQuestionIndex,
    required this.maxQuestions,
    required this.imageUrl,
    required this.hasAudio,
    required this.shuffledAnswers,
  });
}
