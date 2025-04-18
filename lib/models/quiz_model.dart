// lib/models/quiz_model.dart
import 'word_model.dart';

class QuizQuestion {
  final Word word;
  final List<String> options; // Türkçe karşılık seçenekleri
  final int correctOptionIndex;

  QuizQuestion({
    required this.word,
    required this.options,
    required this.correctOptionIndex,
  });
}

class QuizSession {
  final List<QuizQuestion> questions;
  final DateTime quizDate;
  int currentQuestionIndex = 0;
  List<bool> results = [];

  QuizSession({
    required this.questions,
    required this.quizDate,
  }) {
    results = List.filled(questions.length, false);
  }

  bool isCompleted() {
    return currentQuestionIndex >= questions.length;
  }

  double getScore() {
    if (results.isEmpty) return 0;
    int correctCount = results.where((result) => result).length;
    return correctCount / results.length;
  }
}