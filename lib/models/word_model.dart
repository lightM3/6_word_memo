class Word {
  final int id;
  final String engWord;
  final String trWord;
  final String? sampleSentence;
  final String? imagePath;
  final DateTime? dateAdded;
  final int repetitionCount;
  final DateTime? nextRepetitionDate;
  final String? category; 

  Word({
    required this.id,
    required this.engWord,
    required this.trWord,
    this.sampleSentence,
    this.imagePath,
    this.dateAdded,
    this.repetitionCount = 0,
    this.nextRepetitionDate,
    this.category,
  });
}
