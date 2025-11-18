import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slova/models/category.dart';
import 'package:slova/models/word.dart';
import 'package:slova/providers/category_provider.dart';
import 'package:slova/providers/word_provider.dart';

class CategoryEditorScreen extends ConsumerStatefulWidget {
  final Category? category;

  const CategoryEditorScreen({super.key, this.category});

  @override
  ConsumerState<CategoryEditorScreen> createState() =>
      _CategoryEditorScreenState();
}

class _CategoryEditorScreenState extends ConsumerState<CategoryEditorScreen> {
  final Map<int, TextEditingController> _controllers = {}; // key: index
  final Map<int, FocusNode> _focusNodes = {}; // key: index

  // Для формы добавления слова
  final TextEditingController _newWordController = TextEditingController();
  Difficulty _selectedDifficulty = Difficulty.easy;
  String _searchQuery = '';

  // Состояние видимости
  bool _showAddForm = false;
  bool _showSearch = false;

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    _focusNodes.values.forEach((node) => node.dispose());
    _newWordController.dispose();
    super.dispose();
  }

  void _toggleAddForm() {
    setState(() {
      _showAddForm = !_showAddForm;
      if (_showAddForm) {
        _showSearch = false; // Закрываем поиск при открытии формы
      }
    });
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (_showSearch) {
        _showAddForm = false; // Закрываем форму при открытии поиска
      }
    });
  }

  TextEditingController _getController(int index, String initialText) {
    return _controllers.putIfAbsent(
      index,
      () => TextEditingController(text: initialText),
    );
  }

  FocusNode _getFocusNode(int index) {
    return _focusNodes.putIfAbsent(
      index,
      () => FocusNode(),
    );
  }

  void _syncControllers(List<Word> words) {
    // Простая логика: очищаем все контроллеры при изменении списка
    // и создаем их заново при следующем обращении
    _controllers.values.forEach((controller) => controller.dispose());
    _focusNodes.values.forEach((node) => node.dispose());
    _controllers.clear();
    _focusNodes.clear();
  }

  List<Word> _filterWords(List<Word> words) {
    if (_searchQuery.isEmpty) {
      return words;
    }
    return words
        .where((word) =>
            word.text.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _addNewWord(WordsNotifier wordsNotifier) {
    final text = _newWordController.text.trim();
    if (text.isNotEmpty) {
      wordsNotifier.addWord(text, _selectedDifficulty);
      _newWordController.clear();
    }
  }

  String _getDifficultyText(Difficulty difficulty) {
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

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    print('category id: ${widget.category?.id}');
    final words = ref.watch(currentCategoryWordsProvider(widget.category?.id));
    print('words id: ${words}');

    // Синхронизируем контроллеры с данными
    _syncControllers(words);

    final wordsNotifier =
        ref.read(currentCategoryWordsProvider(widget.category?.id).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null
            ? 'Создать категорию'
            : 'Редактировать категорию'),
        actions: [
          IconButton(
            onPressed: _toggleSearch,
            icon: Icon(_showSearch ? Icons.search_off : Icons.search),
            tooltip: _showSearch ? 'Скрыть поиск' : 'Показать поиск',
          ),
          IconButton(
            onPressed: _toggleAddForm,
            icon: Icon(_showAddForm ? Icons.close : Icons.add),
            tooltip: _showAddForm ? 'Скрыть форму' : 'Добавить слово',
          ),
          TextButton(
            onPressed: () => _saveCategory(context, ref, words, wordsNotifier),
            child:
                const Text('СОХРАНИТЬ', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: _buildBody(context, ref, words, wordsNotifier),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, List<Word> words,
      WordsNotifier wordsNotifier) {
    final filteredWords = _filterWords(words);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Название категории
          TextField(
            controller:
                TextEditingController(text: widget.category?.name ?? ''),
            textDirection: TextDirection.ltr,
            decoration: const InputDecoration(
              labelText: 'Название категории',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 24),

          // Форма добавления нового слова (показывается при нажатии на +)
          if (_showAddForm)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Добавить новое слово',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        ElevatedButton(
                          onPressed: () => _addNewWord(wordsNotifier),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                          child: const Icon(Icons.add, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _newWordController,
                            textDirection: TextDirection.ltr,
                            decoration: const InputDecoration(
                              labelText: 'Слово',
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _addNewWord(wordsNotifier),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<Difficulty>(
                            isExpanded: true,
                            value: _selectedDifficulty,
                            decoration: const InputDecoration(
                              labelText: 'Сложность',
                              border: OutlineInputBorder(),
                            ),
                            items: Difficulty.values.map((difficulty) {
                              return DropdownMenuItem(
                                value: difficulty,
                                child: Text(
                                  _getDifficultyText(difficulty),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedDifficulty = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Поиск (показывается при нажатии на поиск)
          if (_showSearch) ...[
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Поиск слов',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Поиск слов...',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${filteredWords.length} слов',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Заголовок слов
          const Text(
            'Слова в категории',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 16),

          // Список слов
          if (filteredWords.isEmpty && _searchQuery.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Слов пока нет\nДобавьте первое слово выше',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else if (filteredWords.isEmpty && _searchQuery.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'По запросу "$_searchQuery" ничего не найдено',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...filteredWords.map((word) {
              final realIndex = words.indexOf(word);
              return _buildWordEditor(
                  context, ref, realIndex, word, wordsNotifier);
            }),
        ],
      ),
    );
  }

  Widget _buildWordEditor(BuildContext context, WidgetRef ref, int index,
      Word word, WordsNotifier wordsNotifier) {
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
                    controller: _getController(index, word.text),
                    focusNode: _getFocusNode(index),
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                      labelText: 'Слово',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) =>
                        wordsNotifier.updateWord(index, value, word.difficulty),
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

  Future<void> _saveCategory(BuildContext context, WidgetRef ref,
      List<Word> words, WordsNotifier wordsNotifier) async {
    final nameController =
        TextEditingController(text: widget.category?.name ?? '');
    final name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название категории')),
      );
      return;
    }

    try {
      widget.category?.id ??
          await ref
              .read(categoryRepositoryProvider)
              .insertCategory(Category(name: name));

      // Сохраняем слова через notifier
      await wordsNotifier.saveWords();

      // Обновляем список категорий
      ref.invalidate(allCategoriesProvider);

      final message = widget.category == null
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
