class Question {
  final String id;
  final String questionText;
  final String correctAnswer;
  final List<String> incorrectAnswers;
  final String imagePath;
  final String audioPath;
  final int cluster;
  int level;
  final String category;

  Question({
    required this.id,
    required this.questionText,
    required this.correctAnswer,
    required this.incorrectAnswers,
    required this.imagePath,
    required this.audioPath,
    required this.cluster,
    this.level = 0,
    required this.category,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      questionText: json['questionText'],
      correctAnswer: json['correctAnswer'],
      incorrectAnswers: List<String>.from(json['incorrectAnswers']),
      imagePath: json['imagePath'],
      audioPath: json['audioPath'],
      cluster: json['cluster'],
      level: json['level'] ?? 0,
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'questionText': questionText,
        'correctAnswer': correctAnswer,
        'incorrectAnswers': incorrectAnswers,
        'imagePath': imagePath,
        'audioPath': audioPath,
        'cluster': cluster,
        'level': level,
        'category': category,
      };

  List<String> getAllAnswers() {
    List<String> allAnswers = List<String>.from(incorrectAnswers);
    allAnswers.add(correctAnswer);
    allAnswers.shuffle();
    return allAnswers;
  }
}
