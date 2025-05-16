class Word {
  final String engWord;
  final String trWord;
  final String? sampleSentence;
  final String? imagePath;
  final String? audioPath;
  final String? category;

  Word({
    required this.engWord,
    required this.trWord,
    this.sampleSentence,
    this.imagePath,
    this.audioPath,
    this.category,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      engWord: json['engWord'],
      trWord: json['trWord'],
      sampleSentence: json['sampleSentence'],
      imagePath: json['imagePath'],
      audioPath: json['audioPath'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'engWord': engWord,
      'trWord': trWord,
      'sampleSentence': sampleSentence,
      'imagePath': imagePath,
      'audioPath': audioPath,
      'category': category,
    };
  }
}
