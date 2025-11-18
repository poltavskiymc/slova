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
final wordsByCategoryProvider =
    FutureProvider.family<List<Word>, int>((ref, categoryId) async {
  developer
      .log('WordProvider: Starting to load words for category $categoryId');
  // Ensure database is initialized first
  await ref.watch(databaseProvider.future);
  developer.log('WordProvider: Database initialized, getting repository');
  final repository = ref.watch(wordRepositoryProvider);
  final words = await repository.getWordsByCategory(categoryId);
  developer.log(
      'WordProvider: Loaded ${words.length} words for category $categoryId');
  return words;
});

// Words by category and difficulty provider
final wordsByCategoryAndDifficultyProvider =
    FutureProvider.family<List<Word>, WordQueryParams>((ref, params) async {
  developer.log(
      'WordProvider: Starting to load words for category ${params.categoryId} and difficulty ${params.difficulty}');
  // Ensure database is initialized first
  await ref.watch(databaseProvider.future);
  developer.log('WordProvider: Database initialized, getting repository');
  final repository = ref.watch(wordRepositoryProvider);
  final words = await repository.getWordsByCategoryAndDifficulty(
      params.categoryId, params.difficulty);
  developer.log(
      'WordProvider: Loaded ${words.length} words for category ${params.categoryId} and difficulty ${params.difficulty}');
  return words;
});

// Word count by category provider
final wordCountByCategoryProvider =
    FutureProvider.family<int, int>((ref, categoryId) async {
  developer.log('WordProvider: Getting word count for category $categoryId');
  // Ensure database is initialized first
  await ref.watch(databaseProvider.future);
  developer.log('WordProvider: Database initialized, getting repository');
  final repository = ref.watch(wordRepositoryProvider);
  final words = await repository.getWordsByCategory(categoryId);
  final count = words.length;
  developer.log('WordProvider: Category $categoryId has $count words');
  return count;
});

// Current category words provider for editing
final currentCategoryWordsProvider =
    StateNotifierProvider.family<WordsNotifier, List<Word>, int?>(
  (ref, categoryId) => WordsNotifier(ref, categoryId),
);

class WordsNotifier extends StateNotifier<List<Word>> {
  final Ref ref;
  final int? categoryId;

  WordsNotifier(this.ref, this.categoryId) : super([]) {
    if (categoryId != null) {
      _loadWords();
    }
  }

  void _sortWords() {
    state = List<Word>.from(state)
      ..sort((a, b) {
        // Сначала сортируем по сложности: Легкая -> Средняя -> Сложная
        final difficultyOrder = {
          Difficulty.easy: 0,
          Difficulty.medium: 1,
          Difficulty.hard: 2,
        };

        final aOrder = difficultyOrder[a.difficulty] ?? 0;
        final bOrder = difficultyOrder[b.difficulty] ?? 0;

        if (aOrder != bOrder) {
          return aOrder.compareTo(bOrder);
        }

        // Внутри одной сложности сортируем по алфавиту
        return a.text.toLowerCase().compareTo(b.text.toLowerCase());
      });
  }

  Future<void> _loadWords() async {
    if (categoryId == null) return;

    try {
      final words = await ref.read(wordsByCategoryProvider(categoryId!).future);
      print('Loaded ${words.length} words for category $categoryId');
      state = List.from(words);
      _sortWords();
    } catch (e) {
      print('Error loading words for category $categoryId: $e');
      state = [];
    }
  }

  void addWord(String text, Difficulty difficulty) {
    final newWord = Word(
      text: text,
      difficulty: difficulty,
      categoryId: categoryId ?? 0,
    );
    // Добавляем в начало списка, затем сортируем
    state = [newWord, ...state];
    _sortWords();
  }

  void updateWord(int index, String text, Difficulty difficulty) {
    if (index < 0 || index >= state.length) return;

    // Если текст пустой, удаляем слово
    if (text.trim().isEmpty) {
      final newState = List<Word>.from(state);
      newState.removeAt(index);
      state = newState;
      return;
    }

    final updatedWord = Word(
      id: state[index].id,
      text: text,
      difficulty: difficulty,
      categoryId: state[index].categoryId,
    );

    final newState = List<Word>.from(state);
    newState[index] = updatedWord;
    state = newState;
    _sortWords();
  }

  void removeWord(int index) {
    if (index < 0 || index >= state.length) return;

    final newState = List<Word>.from(state);
    newState.removeAt(index);
    state = newState;
  }

  Future<void> saveWords() async {
    final wordRepo = ref.read(wordRepositoryProvider);

    for (final word in state) {
      if (word.text.trim().isEmpty) continue;

      final wordToSave = Word(
        id: word.id,
        text: word.text.trim(),
        difficulty: word.difficulty,
        categoryId: categoryId ?? 0,
      );

      if (word.id == null) {
        await wordRepo.insertWord(wordToSave);
      } else {
        await wordRepo.updateWord(wordToSave);
      }
    }

    // Invalidate related providers
    ref.invalidate(wordsByCategoryProvider(categoryId!));
    ref.invalidate(wordCountByCategoryProvider(categoryId!));
  }
}

class WordQueryParams {
  final int categoryId;
  final Difficulty difficulty;

  WordQueryParams({
    required this.categoryId,
    required this.difficulty,
  });
}
