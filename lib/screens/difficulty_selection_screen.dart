import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slova/models/word.dart';
import 'package:slova/providers/word_provider.dart';
import 'package:slova/providers/game_provider.dart';
import 'package:slova/screens/game_screen.dart';
import 'dart:developer' as developer;

class DifficultySelectionScreen extends ConsumerWidget {
  final int categoryId;
  final String categoryName;

  // Публичный статический метод для запуска игры с сохраненными параметрами
  static Future<void> startGameWithSavedParameters(
      BuildContext context, WidgetRef ref) async {
    final gameParams = ref.read(gameParametersProvider);
    if (gameParams != null) {
      // Создаем временный экран для запуска игры
      final tempScreen = DifficultySelectionScreen(
        categoryId: gameParams.categoryId,
        categoryName: gameParams.categoryName,
      );
      await tempScreen.startGame(context, ref, gameParams.difficulty);
    }
  }

  const DifficultySelectionScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  String _getDifficultyName(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.all:
        return 'Все';
      case Difficulty.easy:
        return 'Легкая';
      case Difficulty.medium:
        return 'Средняя';
      case Difficulty.hard:
        return 'Сложная';
    }
  }

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.all:
        return Colors.blue;
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.hard:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Выберите уровень сложности',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 48),
            // Все кнопки сложностей
            ...Difficulty.values.map((difficulty) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 8.0,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      developer.log('До загрузки');
                      startGame(context, ref, difficulty);
                      developer.log('После загрузки');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getDifficultyColor(difficulty),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _getDifficultyName(difficulty),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> startGame(
      BuildContext context, WidgetRef ref, Difficulty difficulty) async {
    // Показываем индикатор загрузки
    showDialog<Widget>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      late List<Word> gameWords;

      developer.log(
          'Loading words for category: $categoryId, difficulty: $difficulty');

      if (difficulty == Difficulty.all) {
        final wordsAsync =
            await ref.read(wordsByCategoryProvider(categoryId).future);
        gameWords = wordsAsync;
        developer.log('Loaded ${gameWords.length} words for all difficulties');
      } else {
        final wordsAsync = await ref.read(wordsByCategoryAndDifficultyProvider(
          WordQueryParams(categoryId: categoryId, difficulty: difficulty),
        ).future);
        gameWords = wordsAsync;
        developer
            .log('Loaded ${gameWords.length} words for difficulty $difficulty');
      }

      developer.log(
          'DifficultySelectionScreen: Words loaded successfully, processing...');

      // Скрываем индикатор загрузки
      if (context.mounted) {
        developer.log(
            'DifficultySelectionScreen: Context mounted, hiding loading indicator...');
        Navigator.of(context).pop();
        developer.log('DifficultySelectionScreen: Loading indicator hidden');

        if (gameWords.isEmpty) {
          developer
              .log('DifficultySelectionScreen: ERROR - gameWords is empty!');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Нет слов для выбранной сложности')),
          );
          return;
        }

        developer.log(
            'DifficultySelectionScreen: gameWords not empty, proceeding...');

        developer.log(
            'DifficultySelectionScreen: Starting game with ${gameWords.length} words for difficulty $difficulty');

        // Сохраняем параметры игры для возможности повторного запуска
        ref.read(gameParametersProvider.notifier).state = GameParameters(
          categoryId: categoryId,
          categoryName: categoryName,
          difficulty: difficulty,
        );

        // Логируем слова перед передачей
        for (int i = 0; i < gameWords.length; i++) {
          developer.log(
              'DifficultySelectionScreen: Passing word $i: ${gameWords[i].text}');
        }

        try {
          developer
              .log('DifficultySelectionScreen: Creating GameScreen widget...');
          final gameScreen = GameScreen(
            categoryId: categoryId,
            categoryName: categoryName,
            difficulty: difficulty,
            gameWords: gameWords,
          );
          developer.log(
              'DifficultySelectionScreen: GameScreen widget created successfully');

          developer
              .log('DifficultySelectionScreen: Creating MaterialPageRoute...');
          final route = MaterialPageRoute<Widget>(
            builder: (context) => gameScreen,
            fullscreenDialog: true,
          );
          developer.log(
              'DifficultySelectionScreen: MaterialPageRoute created successfully');

          developer.log('DifficultySelectionScreen: Calling Navigator.push...');
          Navigator.push(context, route);
          developer.log(
              'DifficultySelectionScreen: Navigator.push completed successfully');
        } catch (innerError) {
          developer.log(
              'DifficultySelectionScreen: ERROR during GameScreen creation/navigation: $innerError');
          developer.log(
              'DifficultySelectionScreen: Inner error type: ${innerError.runtimeType}');
          developer.log(
              'DifficultySelectionScreen: Inner stack trace: ${StackTrace.current}');
          rethrow; // Перебрасываем ошибку в outer catch
        }
      }
    } catch (error) {
      developer.log('DifficultySelectionScreen: ERROR in _startGame: $error');
      developer
          .log('DifficultySelectionScreen: Error type: ${error.runtimeType}');
      developer
          .log('DifficultySelectionScreen: Stack trace: ${StackTrace.current}');

      // Скрываем индикатор загрузки
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $error')),
        );
      }
    }
  }
}
