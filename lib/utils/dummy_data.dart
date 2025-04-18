import '../models/word_model.dart';
import '../models/quiz_model.dart';

class DummyData {
  static List<Word> getWords() {
    return [
      Word(
        id: 1,
        engWord: 'apple',
        trWord: 'elma',
        sampleSentence: 'I eat an apple every day.',
        repetitionCount: 2,
        dateAdded: DateTime.now().subtract(Duration(days: 10)),
        nextRepetitionDate: DateTime.now(),
        category: 'fruit',
      ),
      Word(
        id: 2,
        engWord: 'book',
        trWord: 'kitap',
        sampleSentence: 'I read a book last night.',
        repetitionCount: 4,
        dateAdded: DateTime.now().subtract(Duration(days: 45)),
        nextRepetitionDate: DateTime.now(),
        category: 'object',
      ),
      Word(
        id: 3,
        engWord: 'car',
        trWord: 'araba',
        sampleSentence: 'He drives a red car.',
        repetitionCount: 1,
        dateAdded: DateTime.now().subtract(Duration(days: 3)),
        nextRepetitionDate: DateTime.now().add(Duration(days: 4)),
        category: 'vehicle',
      ),
      Word(
        id: 4,
        engWord: 'house',
        trWord: 'ev',
        sampleSentence: 'They live in a big house.',
        repetitionCount: 0,
        dateAdded: DateTime.now(),
        nextRepetitionDate: DateTime.now().add(Duration(days: 1)),
        category: 'object',
      ),
      Word(
        id: 5,
        engWord: 'computer',
        trWord: 'bilgisayar',
        sampleSentence: 'I work on my computer every day.',
        repetitionCount: 3,
        dateAdded: DateTime.now().subtract(Duration(days: 30)),
        nextRepetitionDate: DateTime.now().add(Duration(days: 60)),
        category: 'technology',
      ),
    ];
  }

  static List<String> getTurkishWords() {
    return [
      'elma', 'kitap', 'araba', 'ev', 'bilgisayar',
      'kalem', 'masa', 'sandalye', 'su', 'ekmek'
    ];
  }

  static QuizSession generateQuizSession() {
    final words = getWords();
    final trWords = getTurkishWords();

    List<QuizQuestion> questions = [];

    for (var word in words) {
      List<String> options = [word.trWord];

      while (options.length < 4) {
        String randomTr = trWords[DateTime.now().microsecond % trWords.length];
        if (!options.contains(randomTr) && randomTr != word.trWord) {
          options.add(randomTr);
        }
      }

      options.shuffle();
      int correctIndex = options.indexOf(word.trWord);

      questions.add(QuizQuestion(
        word: word,
        options: options,
        correctOptionIndex: correctIndex,
      ));
    }

    return QuizSession(
      questions: questions,
      quizDate: DateTime.now(),
    );
  }
}
