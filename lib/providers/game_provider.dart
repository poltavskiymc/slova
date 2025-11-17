import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slova/models/word.dart';

// Provider для хранения параметров текущей игры
class GameParameters {
  final int categoryId;
  final String categoryName;
  final Difficulty difficulty;

  GameParameters({
    required this.categoryId,
    required this.categoryName,
    required this.difficulty,
  });
}

final gameParametersProvider = StateProvider<GameParameters?>((ref) => null);
