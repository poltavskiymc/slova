enum Difficulty { easy, medium, hard }

class Word {
  final int? id;
  final String text;
  final Difficulty difficulty;
  final int categoryId;

  Word({
    this.id,
    required this.text,
    required this.difficulty,
    required this.categoryId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'difficulty': difficulty.name,
      'categoryId': categoryId,
    };
  }

  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'] as int?,
      text: map['text'] as String,
      difficulty: Difficulty.values.firstWhere(
        (e) => e.name == map['difficulty'],
      ),
      categoryId: map['categoryId'] as int,
    );
  }
}
