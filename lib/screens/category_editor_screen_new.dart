import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slova/models/category.dart';
import 'package:slova/models/word.dart';
import 'package:slova/providers/category_provider.dart';
import 'package:slova/providers/word_provider.dart';

class CategoryEditorScreen extends ConsumerWidget {
  final Category? category;

  const CategoryEditorScreen({super.key, this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final words = ref.watch(currentCategoryWordsProvider(category?.id));
    final wordsNotifier = ref.read(currentCategoryWordsProvider(category?.id).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(category == null ? 'Создать категорию' : 'Редактировать категорию'),
        actions: [
          TextButton(
            onPressed: () => _saveCategory(context, ref, words, wordsNotifier),
            child: const Text('СОХРАНИТЬ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _buildBody(context, ref, words, wordsNotifier),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, List<Word> words, WordsNotifier wordsNotifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Название категории
          TextField(
            controller: TextEditingController(text: category?.name ?? ''),
            textDirection: TextDirection.ltr,
            decoration: const InputDecoration(
              labelText: 'Название категории',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 24),

          // Заголовок слов
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Слова в категории',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              IconButton(
                onPressed: () => wordsNotifier.addWord('', Difficulty.easy),
                icon: const Icon(Icons.add),
                tooltip: 'Добавить слово',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Список слов
          if (words.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Слов пока нет\nНажмите + чтобы добавить',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...words.asMap().entries.map((entry) {
              final index = entry.key;
              final word = entry.value;
              return _buildWordEditor(context, ref, index, word, wordsNotifier);
            }),
        ],
      ),
    );
  }

  Widget _buildWordEditor(BuildContext context, WidgetRef ref, int index, Word word, WordsNotifier wordsNotifier) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: word.text),
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                      labelText: 'Слово',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => wordsNotifier.updateWord(index, value, word.difficulty),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<Difficulty>(
                  value: word.difficulty,
                  items: Difficulty.values.map((difficulty) {
                    return DropdownMenuItem(
                      value: difficulty,
                      child: Text(_getDifficultyName(difficulty)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      wordsNotifier.updateWord(index, word.text, value);
                    }
                  },
                ),
                IconButton(
                  onPressed: () => wordsNotifier.removeWord(index),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Удалить слово',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCategory(BuildContext context, WidgetRef ref, List<Word> words, WordsNotifier wordsNotifier) async {
    final nameController = TextEditingController(text: category?.name ?? '');
    final name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название категории')),
      );
      return;
    }

    try {
      final categoryId = category?.id ??
        await ref.read(categoryRepositoryProvider).insertCategory(Category(name: name));

      // Сохраняем слова через notifier
      await wordsNotifier.saveWords();

      // Обновляем список категорий
      ref.invalidate(allCategoriesProvider);

      final message = category == null
        ? 'Категория "$name" создана'
        : 'Категория "$name" обновлена';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
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
