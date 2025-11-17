import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slova/models/word.dart';
import 'package:slova/repositories/word_repository.dart';
import 'package:slova/providers/database_provider.dart';
import 'dart:developer' as developer;

// Repository provider
final wordRepositoryProvider = Provider<WordRepository>((ref) {
  return WordRepository();
});

// Words by category provider
final wordsByCategoryProvider = FutureProvider.family<List<Word>, int>((ref, categoryId) async {
  developer.log('WordProvider: Starting to load words for category $categoryId');
  // Ensure database is initialized first
  await ref.watch(databaseProvider.future);
  developer.log('WordProvider: Database initialized, getting repository');
  final repository = ref.watch(wordRepositoryProvider);
  final words = await repository.getWordsByCategory(categoryId);
  developer.log('WordProvider: Loaded ${words.length} words for category $categoryId');
  return words;
});

// Words by category and difficulty provider
final wordsByCategoryAndDifficultyProvider =
    FutureProvider.family<List<Word>, WordQueryParams>((ref, params) async {
  developer.log('WordProvider: Starting to load words for category ${params.categoryId} and difficulty ${params.difficulty}');
  // Ensure database is initialized first
  await ref.watch(databaseProvider.future);
  developer.log('WordProvider: Database initialized, getting repository');
  final repository = ref.watch(wordRepositoryProvider);
  final words = await repository.getWordsByCategoryAndDifficulty(params.categoryId, params.difficulty);
  developer.log('WordProvider: Loaded ${words.length} words for category ${params.categoryId} and difficulty ${params.difficulty}');
  return words;
});

class WordQueryParams {
  final int categoryId;
  final Difficulty difficulty;

  WordQueryParams({
    required this.categoryId,
    required this.difficulty,
  });
}