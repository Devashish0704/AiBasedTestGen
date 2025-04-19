class QuizSettings {
  String questionType;
  String from;
  String difficulty;

  QuizSettings({
    this.questionType = 'MCQ',
    this.from = 'Topic',
    this.difficulty = 'Easy',
  });

  Map<String, dynamic> toJson() {
    return {
      'questionType': questionType,
      'from': from,
      'difficulty': difficulty,
    };
  }

   QuizSettings copyWith({String? difficulty}) {
    return QuizSettings(
      difficulty: difficulty ?? this.difficulty,
    );
  }

  factory QuizSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return QuizSettings();
    return QuizSettings(
      questionType: json['questionType'] ?? 'MCQ',
      from: json['from'] ?? 'Topic',
      difficulty: json['difficulty'] ?? 'Medium',
    );
  }
}
