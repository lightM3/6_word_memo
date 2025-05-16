import 'word_model.dart';

class UserWord {
  final int id;
  final int repetitionCount;
  final DateTime? nextRepetitionDate;
  final bool isMastered;
  final Word word;

  UserWord({
    required this.id,
    required this.repetitionCount,
    required this.nextRepetitionDate,
    required this.isMastered,
    required this.word,
  });

  factory UserWord.fromJson(Map<String, dynamic> json) {
    return UserWord(
      id: json['id'],
      repetitionCount: json['repetitionCount'],
      nextRepetitionDate:
          json['nextRepetitionDate'] != null
              ? DateTime.parse(json['nextRepetitionDate'])
              : null,
      isMastered: json['isMastered'],
      word: Word.fromJson(json['word']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'repetitionCount': repetitionCount,
      'nextRepetitionDate': nextRepetitionDate?.toIso8601String(),
      'isMastered': isMastered,
      'word': word.toJson(),
    };
  }
}
