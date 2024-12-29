import 'package:flutter/material.dart';
import 'package:ratzdaz/Layout/cyberpunk_theme.dart';
import '../quiz_types.dart';

class QuizScreenLayout extends StatelessWidget {
  final QuizScreenData data;
  final VoidCallback onBackPressed;
  final Function(String) onAnswerSelected;
  final VoidCallback onAudioPressed;

  const QuizScreenLayout({
    Key? key,
    required this.data,
    required this.onBackPressed,
    required this.onAnswerSelected,
    required this.onAudioPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: CyberpunkTheme.gradientBackground,
        child: SafeArea(
          child: Stack(
            children: [
              _buildBackButton(),
              _buildScoreDisplay(context),
              _buildMainContent(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: 20,
      left: 20,
      child: Container(
        decoration: CyberpunkTheme.iconButtonDecoration(),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          onPressed: onBackPressed,
          style: IconButton.styleFrom(
            backgroundColor: Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget _buildScoreDisplay(BuildContext context) {
    return Positioned(
      top: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: CyberpunkTheme.scoreDisplayDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.stars_rounded,
                  color: CyberpunkTheme.neonBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${data.points}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: CyberpunkTheme.neonBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Frage ${data.currentQuestionIndex + 1}/${data.maxQuestions}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildMediaSection(),
          const SizedBox(height: 40),
          _buildAnswerButtons(),
        ],
      ),
    );
  }

  Widget _buildMediaSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            color: CyberpunkTheme.darkGrey,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: CyberpunkTheme.neonBlue.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              data.imageUrl,
              width: 300,
              height: 300,
              fit: BoxFit.contain, // Ändert sich von cover zu contain
            ),
          ),
        ),
        if (data.hasAudio) ...[
          const SizedBox(width: 20),
          Container(
            decoration: CyberpunkTheme.iconButtonDecoration(
              glowColor: CyberpunkTheme.neonBlue,
            ),
            child: IconButton(
              icon: Icon(
                Icons.volume_up,
                color: CyberpunkTheme.neonBlue,
                size: 32,
              ),
              onPressed: onAudioPressed,
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAnswerButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: CyberpunkTheme.darkGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CyberpunkTheme.neonBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: data.shuffledAnswers.map((answer) {
          // Text mit Bindestrich in zwei Zeilen aufteilen
          final parts = answer.split(' - ');
          final formattedAnswer = parts.join('\n\n');

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton(
                onPressed: () => onAnswerSelected(answer),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CyberpunkTheme.darkGrey,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                      color: CyberpunkTheme.neonBlue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ).copyWith(
                  overlayColor: MaterialStateProperty.all(
                    CyberpunkTheme.neonBlue.withOpacity(0.1),
                  ),
                ),
                child: Text(
                  formattedAnswer,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
