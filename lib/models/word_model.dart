class Word {
  final int id;
  final String engWord;
  final String trWord;
  final String? sampleSentence;
  final String? category;
  final String? imagePath;
  final String? audioPath;
  final DateTime? dateAdded;
  final int repetitionCount;

  Word({
    required this.id,
    required this.engWord,
    required this.trWord,
    this.sampleSentence,
    this.category,
    this.imagePath,
    this.audioPath,
    this.dateAdded,
    this.repetitionCount = 0,
  });

  factory Word.fromApi(Map<String, dynamic> json) {
    return Word(
      id: json["wordId"] ?? json["id"],
      engWord: json["engWord"],
      trWord: json["trWord"],
      sampleSentence: json["sampleSentence"],
      category: json["category"],
      imagePath: json["imagePath"],
      audioPath: json["audioPath"],
      dateAdded:
          json["addedDate"] != null
              ? DateTime.tryParse(json["addedDate"])
              : null,
      repetitionCount: json["repetitionCount"] ?? 0,
    );
  }
}
