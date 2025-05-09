import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:duo_lingo/services/api_service.dart';
import '../../models/quiz_model.dart';
import 'quiz_result_page.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  QuizSession? _quizSession;
  bool _answered = false;
  int? _selectedOptionIndex;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuizData();
  }

  Future<void> _loadQuizData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return;

    final data = await ApiService.fetchQuiz(token);
    final session = QuizSession.fromApi(data);

    setState(() {
      _quizSession = session;
      _isLoading = false;
    });
  }

  void _checkAnswer(int index) {
    if (_answered || _quizSession == null) return;

    setState(() {
      _selectedOptionIndex = index;
      _answered = true;

      final currentQuestion =
          _quizSession!.questions[_quizSession!.currentQuestionIndex];
      final isCorrect = index == currentQuestion.correctOptionIndex;
      _quizSession!.results[_quizSession!.currentQuestionIndex] = isCorrect;
    });

    Future.delayed(Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _answered = false;
        _selectedOptionIndex = null;

        if (_quizSession!.currentQuestionIndex <
            _quizSession!.questions.length - 1) {
          _quizSession!.currentQuestionIndex++;
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => QuizResultPage(quizSession: _quizSession!),
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Kelime Sınavı')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_quizSession == null || _quizSession!.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Kelime Sınavı')),
        body: Center(
          child: Text(
            'Bugün için sınavlık kelimeniz yok.',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final currentQuestion =
        _quizSession!.questions[_quizSession!.currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Kelime Sınavı'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                '${_quizSession!.currentQuestionIndex + 1}/${_quizSession!.questions.length}',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value:
                  (_quizSession!.currentQuestionIndex + 1) /
                  _quizSession!.questions.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),
            SizedBox(height: 24),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      currentQuestion.word.engWord,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    if (currentQuestion.word.sampleSentence != null)
                      Text(
                        currentQuestion.word.sampleSentence!,
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              '${currentQuestion.word.repetitionCount}/6 Tekrar',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ...List.generate(currentQuestion.options.length, (index) {
              final isCorrect = index == currentQuestion.correctOptionIndex;
              final isSelected = _selectedOptionIndex == index;
              Color? buttonColor;

              if (_answered) {
                if (isCorrect) {
                  buttonColor = Colors.green;
                } else if (isSelected) {
                  buttonColor = Colors.red;
                }
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _answered ? null : () => _checkAnswer(index),
                  child: Text(
                    currentQuestion.options[index],
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
