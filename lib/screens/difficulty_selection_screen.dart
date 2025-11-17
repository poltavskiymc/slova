import 'package:flutter/material.dart';
import 'package:slova/models/word.dart';

class DifficultySelectionScreen extends StatelessWidget {
  final int categoryId;
  final String categoryName;

  const DifficultySelectionScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  String _getDifficultyName(Difficulty difficulty) {
    switch (difficulty) {
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
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.hard:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      // TODO: Переход на экран игры
                      Navigator.push(
                        context,
                        MaterialPageRoute<Widget>(
                          builder: (context) => Scaffold(
                            appBar: AppBar(
                              title: Text(
                                '${categoryName} - ${_getDifficultyName(difficulty)}',
                              ),
                            ),
                            body: Center(
                              child: Text(
                                'Игра с категорией $categoryId и сложностью ${difficulty.name}',
                              ),
                            ),
                          ),
                        ),
                      );
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
}

