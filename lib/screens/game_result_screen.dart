import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slova/models/game_result.dart';
import 'package:slova/models/word.dart';
import 'package:slova/providers/game_provider.dart';
import 'package:slova/screens/difficulty_selection_screen.dart';

class GameResultScreen extends ConsumerWidget {
  final GameResult result;

  const GameResultScreen({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Результаты игры'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text(
              'В МЕНЮ',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Статистика
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'СТАТИСТИКА',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem(
                            'Отгадано',
                            result.guessedWords.length.toString(),
                            Colors.green),
                        _buildStatItem('Пропущено',
                            result.skippedWords.length.toString(), Colors.red),
                        _buildStatItem(
                            'Всего', result.totalWords.toString(), Colors.blue),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Точность: ${result.accuracy.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Время: ${result.totalTime} сек',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Отгаданные слова
            if (result.guessedWords.isNotEmpty) ...[
              const Text(
                '✅ ОТГАДАННЫЕ СЛОВА',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              ...result.guessedWords
                  .map((word) => _buildWordItem(word, Colors.green.shade100)),
            ],

            const SizedBox(height: 24),

            // Пропущенные слова
            if (result.skippedWords.isNotEmpty) ...[
              const Text(
                '❌ ПРОПУЩЕННЫЕ СЛОВА',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              ...result.skippedWords
                  .map((word) => _buildWordItem(word, Colors.red.shade100)),
            ],

            const SizedBox(height: 32),

            // Кнопки действий
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Возврат к выбору сложности (выход на один экран назад)
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Выбрать сложность'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final gameParams = ref.read(gameParametersProvider);
                      if (gameParams != null) {
                        // Запуск игры заново с теми же параметрами
                        await DifficultySelectionScreen
                            .startGameWithSavedParameters(context, ref);
                      } else {
                        // Если параметров нет, возвращаемся к выбору сложности
                        Navigator.of(context).pop();
                      }
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('ЕЩЁ РАЗ'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Кнопка в главное меню
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.home),
                label: const Text('В ГЛАВНОЕ МЕНЮ'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildWordItem(Word word, Color backgroundColor) {
    return Card(
      color: backgroundColor,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(
          word.text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Сложность: ${_getDifficultyName(word.difficulty)}',
          style: TextStyle(
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

  String _getDifficultyName(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Легкая';
      case Difficulty.medium:
        return 'Средняя';
      case Difficulty.hard:
        return 'Сложная';
      case Difficulty.all:
        return 'Все';
    }
  }
}
