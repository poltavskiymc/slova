import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slova/models/word.dart';
import 'package:slova/repositories/word_repository.dart';
import 'package:slova/providers/database_provider.dart';

// Repository provider
final wordRepositoryProvider = Provider<WordRepository>((ref) {
  return WordRepository();
});

// Words by category provider
final wordsByCategoryProvider = FutureProvider.family<List<Word>, int>((ref, categoryId) async {
  // Ensure database is initialized first
  await ref.watch(databaseProvider.future);
  final repository = ref.watch(wordRepositoryProvider);
  return await repository.getWordsByCategory(categoryId);
});

// Words by category and difficulty provider
final wordsByCategoryAndDifficultyProvider =
    FutureProvider.family<List<Word>, WordQueryParams>((ref, params) async {
  // Ensure database is initialized first
  await ref.watch(databaseProvider.future);
  final repository = ref.watch(wordRepositoryProvider);
  return await repository.getWordsByCategoryAndDifficulty(params.categoryId, params.difficulty);
});

class WordQueryParams {
  final int categoryId;
  final Difficulty difficulty;

  WordQueryParams({
    required this.categoryId,
    required this.difficulty,
  });
}