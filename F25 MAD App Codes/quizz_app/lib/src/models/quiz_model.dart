class Quiz {
  final String id;
  final String title;
  final String subtitle;
  final int questionCount;
  final String imagePath;
  // Store colors as hex strings or int values if needed, 
  // but for simplicity we might rely on client-side mapping or store valid color strings.
  final String iconName; // e.g. "article" which maps to Icons.article
  final int colorHex;     // e.g. 0xFFEF5350

  Quiz({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.questionCount,
    required this.imagePath,
    required this.iconName,
    required this.colorHex,
  });

  factory Quiz.fromMap(Map<String, dynamic> data, String documentId) {
    return Quiz(
      id: documentId,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      questionCount: data['questionCount'] ?? 0,
      imagePath: data['imagePath'] ?? '',
      iconName: data['iconName'] ?? 'article',
      colorHex: data['colorHex'] ?? 0xFF2196F3,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'questionCount': questionCount,
      'imagePath': imagePath,
      'iconName': iconName,
      'colorHex': colorHex,
    };
  }
}

class Question {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;

  Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
  });

  factory Question.fromMap(Map<String, dynamic> data, String documentId) {
    return Question(
      id: documentId,
      questionText: data['questionText'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      correctOptionIndex: data['correctOptionIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
    };
  }
}
