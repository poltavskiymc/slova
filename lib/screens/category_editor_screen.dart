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
  ConsumerState<CategoryEditorScreen> createState() => _CategoryEditorScreenState();
}

class _CategoryEditorScreenState extends ConsumerState<CategoryEditorScreen> {
  late TextEditingController _nameController;
  late List<Word> _words;
  bool _isLoading = false;
  final Map<int, TextEditingController> _wordControllers = {};

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _words = [];
    _isLoading = widget.category != null && widget.category!.id != null; // Загружаем если редактируем существующую категорию
    print('CategoryEditor: initState - category: ${widget.category}, categoryId: ${widget.category?.id}');
    if (widget.category != null && widget.category!.id != null) {
      _loadWords();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final controller in _wordControllers.values) {
      controller.dispose();
    }
    _wordControllers.clear();
    super.dispose();
  }

  Future<void> _loadWords() async {
    if (widget.category?.id == null) return;

    try {
      final wordsAsync = ref.read(wordsByCategoryProvider(widget.category!.id!));
      final words = await wordsAsync.when(
        data: (data) {
          print('CategoryEditor: Loaded ${data.length} words for category ${widget.category!.id}');
          return data;
        },
        loading: () {
          print('CategoryEditor: Words are loading...');
          return <Word>[];
        },
        error: (error, stack) {
          print('CategoryEditor: Error loading words: $error');
          return <Word>[];
        },
      );

      if (mounted) {
        print('CategoryEditor: Setting state with ${words.length} words, isLoading = false');
        setState(() {
          _words = List.from(words);
          _isLoading = false;
        });
        print('CategoryEditor: State updated - _words.length: ${_words.length}, _isLoading: $_isLoading');
        // Инициализируем контроллеры для загруженных слов
        for (int i = 0; i < _words.length; i++) {
          _getWordController(i);
        }
        print('CategoryEditor: Controllers initialized for ${_words.length} words');
      }
    } catch (e) {
      print('CategoryEditor: Exception loading words: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveCategory() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название категории')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final categoryId = widget.category?.id ??
        await ref.read(categoryRepositoryProvider).insertCategory(Category(name: name));

      // Сохраняем слова
      await _saveWords(categoryId);

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
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addWord() {
    setState(() {
      _words.add(Word(text: '', difficulty: Difficulty.easy, categoryId: widget.category?.id ?? 0));
    });
    // Инициализируем контроллер для нового слова
    _getWordController(_words.length - 1);
  }

  void _removeWord(int index) {
    setState(() {
      _words.removeAt(index);
      // Удаляем контроллер для этого индекса
      final controller = _wordControllers.remove(index);
      controller?.dispose();

      // Обновляем индексы оставшихся контроллеров
      final updatedControllers = <int, TextEditingController>{};
      _wordControllers.forEach((oldIndex, controller) {
        if (oldIndex > index) {
          updatedControllers[oldIndex - 1] = controller;
        } else {
          updatedControllers[oldIndex] = controller;
        }
      });
      _wordControllers.clear();
      _wordControllers.addAll(updatedControllers);
    });
  }

  Future<void> _saveWords(int categoryId) async {
    final wordRepo = ref.read(wordRepositoryProvider);

    for (final word in _words) {
      if (word.text.trim().isEmpty) continue; // Пропускаем пустые слова

      final wordToSave = Word(
        id: word.id,
        text: word.text.trim(),
        difficulty: word.difficulty,
        categoryId: categoryId,
      );

      if (word.id == null) {
        // Создаем новое слово
        await wordRepo.insertWord(wordToSave);
      } else {
        // Обновляем существующее слово
        await wordRepo.updateWord(wordToSave);
      }
    }

    // Обновляем провайдер слов для этой категории
    ref.invalidate(wordsByCategoryProvider(categoryId));
  }

  TextEditingController _getWordController(int index) {
    return _wordControllers.putIfAbsent(index, () => TextEditingController(text: _words[index].text));
  }

  void _updateWord(int index, String text, Difficulty difficulty) {
    setState(() {
      _words[index] = Word(
        id: _words[index].id,
        text: text,
        difficulty: difficulty,
        categoryId: _words[index].categoryId,
      );
    });
    // Обновляем текст в контроллере, если он существует
    final controller = _wordControllers[index];
    if (controller != null && controller.text != text) {
      controller.text = text;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('CategoryEditor: Building UI - _isLoading: $_isLoading, _words.length: ${_words.length}');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? 'Создать категорию' : 'Редактировать категорию'),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _saveCategory,
              child: const Text('СОХРАНИТЬ', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Название категории
                  TextField(
                    controller: _nameController,
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
                        onPressed: _addWord,
                        icon: const Icon(Icons.add),
                        tooltip: 'Добавить слово',
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Список слов
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_words.isEmpty)
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
                    ..._words.asMap().entries.map((entry) {
                      final index = entry.key;
                      final word = entry.value;
                      return _buildWordEditor(index, word);
                    }),
                ],
              ),
            ),
    );
  }

  Widget _buildWordEditor(int index, Word word) {
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
                    controller: _getWordController(index),
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                      labelText: 'Слово',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _updateWord(index, value, word.difficulty),
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
                      _updateWord(index, word.text, value);
                    }
                  },
                ),
                IconButton(
                  onPressed: () => _removeWord(index),
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
