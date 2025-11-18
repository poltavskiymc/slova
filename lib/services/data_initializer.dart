import 'package:slova/models/category.dart';
import 'package:slova/models/word.dart';
import 'package:slova/repositories/category_repository.dart';
import 'package:slova/repositories/word_repository.dart';
import 'dart:developer' as developer;

class DataInitializer {
  final CategoryRepository _categoryRepository = CategoryRepository();
  final WordRepository _wordRepository = WordRepository();

  Future<void> initializeData() async {
    developer.log('Starting data initialization...');
    await _initializeCategories();
    developer.log('Data initialization completed');
  }

  /// Синхронизирует данные из Supabase с локальной БД
  Future<void> syncFromSupabase(
    List<Map<String, dynamic>> categoriesData,
    List<Map<String, dynamic>> wordsData,
  ) async {
    developer.log('Starting Supabase sync...');

    // Синхронизируем категории
    await _syncCategoriesFromSupabase(categoriesData);

    // Синхронизируем слова
    await _syncWordsFromSupabase(wordsData, categoriesData);

    developer.log('Supabase sync completed');
  }

  Future<void> _syncCategoriesFromSupabase(List<Map<String, dynamic>> categoriesData) async {
    developer.log('Syncing ${categoriesData.length} categories from Supabase');

    // Получаем существующие категории для быстрого поиска
    final existingCategories = await _categoryRepository.getAllCategories();
    final existingCategoryMap = {for (final c in existingCategories) c.name: c};

    for (final categoryData in categoriesData) {
      try {
        final categoryName = categoryData['name'] as String;
        final categoryDescription = categoryData['description'] as String?;
        final existingCategory = existingCategoryMap[categoryName];

        if (existingCategory == null) {
          // Создаем новую категорию
          final newCategory = Category(
            name: categoryName,
            description: categoryDescription,
          );
          await _categoryRepository.insertCategory(newCategory);
          developer.log('Created new category: $categoryName');
        } else {
          // Обновляем существующую категорию только если описание изменилось
          if (existingCategory.description != categoryDescription) {
            final updatedCategory = Category(
              id: existingCategory.id,
              name: categoryName,
              description: categoryDescription,
            );
            await _categoryRepository.updateCategory(updatedCategory);
            developer.log('Updated category: $categoryName');
          }
        }
      } catch (e) {
        developer.log('Error syncing category ${categoryData['name']}: $e');
      }
    }
  }

  Future<void> _syncWordsFromSupabase(
    List<Map<String, dynamic>> wordsData,
    List<Map<String, dynamic>> categoriesData,
  ) async {
    developer.log('Syncing ${wordsData.length} words from Supabase');

    // Создаем карту соответствия Supabase category_id -> локальная категория
    final localCategories = await _categoryRepository.getAllCategories();
    final categoryIdToNameMap = {for (final c in categoriesData) c['id']: c['name']};
    final categoryNameToLocalMap = {for (final c in localCategories) c.name: c};

    for (final wordData in wordsData) {
      try {
        final supabaseCategoryId = wordData['category_id'] as String?;
        if (supabaseCategoryId == null) continue;

        final categoryName = categoryIdToNameMap[supabaseCategoryId] as String?;
        if (categoryName == null) continue;

        final localCategory = categoryNameToLocalMap[categoryName];
        if (localCategory == null) continue;

        final wordText = wordData['text'] as String;
        final wordDifficulty = _parseDifficulty(wordData['difficulty'] as String);

        // Преобразуем текст слова в верхний регистр для хранения
        final normalizedWordText = wordText.toUpperCase();

        final word = Word(
          text: normalizedWordText,
          difficulty: wordDifficulty,
          categoryId: localCategory.id!,
        );

        // Проверяем, существует ли уже такое слово в этой категории (сравнение в нижнем регистре)
        final existingWords = await _wordRepository.getWordsByCategory(localCategory.id!);
        final existingWord = existingWords
            .where((w) => w.text.toLowerCase() == wordText.toLowerCase())
            .firstOrNull;

        if (existingWord == null) {
          // Создаем новое слово
          await _wordRepository.insertWord(word);
          developer.log('Created new word: $normalizedWordText in category $categoryName');
        } else {
          // Обновляем существующее слово только если сложность изменилась
          if (existingWord.difficulty != word.difficulty) {
            final updatedWord = Word(
              id: existingWord.id,
              text: word.text,
              difficulty: word.difficulty,
              categoryId: word.categoryId,
            );
            await _wordRepository.updateWord(updatedWord);
            developer.log('Updated word: $normalizedWordText (difficulty changed)');
          }
        }
      } catch (e) {
        developer.log('Error syncing word ${wordData['text']}: $e');
      }
    }
  }


  Difficulty _parseDifficulty(String difficultyStr) {
    switch (difficultyStr.toLowerCase()) {
      case 'easy':
        return Difficulty.easy;
      case 'medium':
        return Difficulty.medium;
      case 'hard':
        return Difficulty.hard;
      default:
        return Difficulty.easy;
    }
  }

  Future<void> _initializeCategories() async {
    // Проверяем, есть ли уже категории
    final categories = await _categoryRepository.getAllCategories();
    developer.log('Found ${categories.length} existing categories');

    if (categories.isNotEmpty) {
      developer.log('Data already initialized, skipping...');
      return; // Данные уже инициализированы
    }

    // Создаем категории
    developer.log('Creating categories...');
    final animalsCategoryId = await _categoryRepository.insertCategory(
      Category(name: 'Животные'),
    );
    developer.log('Created animals category with ID: $animalsCategoryId');

    final objectsCategoryId = await _categoryRepository.insertCategory(
      Category(name: 'Предметы'),
    );
    developer.log('Created objects category with ID: $objectsCategoryId');

    final professionsCategoryId = await _categoryRepository.insertCategory(
      Category(name: 'Профессии'),
    );
    developer.log('Created professions category with ID: $professionsCategoryId');

    // Добавляем слова для категории "Животные"
    developer.log('Adding animal words...');
    await _addAnimalWords(animalsCategoryId);

    // Добавляем слова для категории "Предметы"
    developer.log('Adding object words...');
    await _addObjectWords(objectsCategoryId);

    // Добавляем слова для категории "Профессии"
    developer.log('Adding profession words...');
    await _addProfessionWords(professionsCategoryId);
  }

  Future<void> _addAnimalWords(int categoryId) async {
    final animalWords = [
      // Легкие (5 слов)
      Word(text: 'КОТ', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'СОБАКА', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'ЛОШАДЬ', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'КОРОВА', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'КУРИЦА', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'РЫБА', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'УТКА', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'ГУСЬ', difficulty: Difficulty.easy, categoryId: categoryId),

      // Средние (8 слов)
      Word(text: 'ЖИРАФ', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'СЛОН', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'ТИГР', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'ОБЕЗЬЯНА', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'КРОКОДИЛ', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'МЕДВЕДЬ', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'ВОЛК', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'ЛИСА', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'ЗАЯЦ', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'БЕЛКА', difficulty: Difficulty.medium, categoryId: categoryId),

      // Сложные (7 слов)
      Word(text: 'ХАМЕЛЕОН', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'КЕНГУРУ', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'ПИНГВИН', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'СТРАУС', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'КОАЛА', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'ПАНДА', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'ЛЕВ', difficulty: Difficulty.hard, categoryId: categoryId),
    ];

    for (final word in animalWords) {
      await _wordRepository.insertWord(word);
    }
    developer.log('Added ${animalWords.length} animal words');
  }

  Future<void> _addObjectWords(int categoryId) async {
    final objectWords = [
      // Легкие (8 слов)
      Word(text: 'СТОЛ', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'СТУЛ', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'ДВЕРЬ', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'ОКНО', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'КНИГА', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'КАРАНДАШ', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'БУМАГА', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'ЛАМПА', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'ЧАШКА', difficulty: Difficulty.easy, categoryId: categoryId),

      // Средние (8 слов)
      Word(text: 'КОМПЬЮТЕР', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'ТЕЛЕФОН', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'ХОЛОДИЛЬНИК', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'МИКРОВОЛНОВКА', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'ПЫЛЕСОС', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'ТЕЛЕВИЗОР', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'ПРИНТЕР', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'КЛАВИАТУРА', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'МОНИТОР', difficulty: Difficulty.medium, categoryId: categoryId),

      // Сложные (7 слов)
      Word(text: 'МИКРОСКОП', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'ТЕЛЕСКОП', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'ГЕНЕРАТОР', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'АККУМУЛЯТОР', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'КАТАЛИЗАТОР', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'ТРАНСФОРМАТОР', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'КОНДЕНСАТОР', difficulty: Difficulty.hard, categoryId: categoryId),
    ];

    for (final word in objectWords) {
      await _wordRepository.insertWord(word);
    }
    developer.log('Added ${objectWords.length} object words');
  }

  Future<void> _addProfessionWords(int categoryId) async {
    final professionWords = [
      // Легкие (8 слов)
      Word(text: 'ВРАЧ', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'УЧИТЕЛЬ', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'ПОВАР', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'ВОДИТЕЛЬ', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'ПРОДАВЕЦ', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'САНТЕХНИК', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'ЭЛЕКТРИК', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'МАЛЯР', difficulty: Difficulty.easy, categoryId: categoryId),

      // Средние (8 слов)
      Word(text: 'ПРОГРАММИСТ', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'АРХИТЕКТОР', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'ЖУРНАЛИСТ', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'ФОТОГРАФ', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'ДИЗАЙНЕР', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'БУХГАЛТЕР', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'МЕНЕДЖЕР', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'ИНЖЕНЕР', difficulty: Difficulty.medium, categoryId: categoryId),

      // Сложные (7 слов)
      Word(text: 'АНЕСТЕЗИОЛОГ', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'КОСМОНАВТ', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'АРХЕОЛОГ', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'ПАЛЕОНТОЛОГ', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'ГЕОДЕЗИСТ', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'ХИРУРГ', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'ПСИХОЛОГ', difficulty: Difficulty.hard, categoryId: categoryId),
    ];

    for (final word in professionWords) {
      await _wordRepository.insertWord(word);
    }
    developer.log('Added ${professionWords.length} profession words');
  }
}
