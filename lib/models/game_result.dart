import 'package:slova/models/word.dart';

class GameResult {
  final List<Word> guessedWords;
  final List<Word> skippedWords;
  final int totalTime;
  final int? categoryId;
  final String? categoryName;
  final String? difficulty;

  GameResult({
    required this.guessedWords,
    required this.skippedWords,
    required this.totalTime,
    this.categoryId,
    this.categoryName,
    this.difficulty,
  });

  int get score => guessedWords.length;

  int get totalWords => guessedWords.length + skippedWords.length;

  double get accuracy => totalWords > 0 ? (guessedWords.length / totalWords) * 100 : 0;
}
