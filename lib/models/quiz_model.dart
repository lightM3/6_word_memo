class QuizWord {
  final int id;
  final String engWord;
  final String trWord;
  final String? sampleSentence;
  final int repetitionCount;

  QuizWord({
    required this.id,
    required this.engWord,
    required this.trWord,
    this.sampleSentence,
    required this.repetitionCount,
  });

  factory QuizWord.fromJson(Map<String, dynamic> json) {
    return QuizWord(
      id: json['wordId'] ?? json['id'],
      engWord: json['engWord'],
      trWord: json['trWord'],
      sampleSentence: json['sampleSentence'],
      repetitionCount: json['repetitionCount'] ?? 0,
    );
  }
}

class QuizQuestion {
  final QuizWord word;
  final List<String> options;
  final int correctOptionIndex;

  QuizQuestion({
    required this.word,
    required this.options,
    required this.correctOptionIndex,
  });
}

class QuizSession {
  final List<QuizQuestion> questions;
  int currentQuestionIndex;
  List<bool> results;

  QuizSession({required this.questions, this.currentQuestionIndex = 0})
    : results = List.filled(questions.length, false);

  double getScore() {
    if (questions.isEmpty) return 0;
    int correct = results.where((r) => r).length;
    return correct / questions.length;
  }

  factory QuizSession.fromApi(List<dynamic> jsonList) {
    final List<QuizWord> allWords =
        jsonList.map((e) => QuizWord.fromJson(e)).toList();

    final List<String> allTrWords =
        allWords.map((w) => w.trWord).toSet().toList(); // tekrarları önle

    final questions =
        allWords.map((word) {
          // 3 yanlış şık oluştur
          final wrongOptions =
              allTrWords.where((tr) => tr != word.trWord).toList()..shuffle();

          final options = [word.trWord, ...wrongOptions.take(3)]..shuffle();

          return QuizQuestion(
            word: word,
            options: options,
            correctOptionIndex: options.indexOf(word.trWord),
          );
        }).toList();

    return QuizSession(questions: questions);
  }
}
