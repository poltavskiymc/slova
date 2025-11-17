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
      Word(text: 'Кот', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'Собака', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'Лошадь', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'Корова', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'Курица', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'Рыба', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'Утка', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'Гусь', difficulty: Difficulty.easy, categoryId: categoryId),

      // Средние (8 слов)
      Word(text: 'Жираф', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Слон', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Тигр', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Обезьяна', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Крокодил', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Медведь', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Волк', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Лиса', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Заяц', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Белка', difficulty: Difficulty.medium, categoryId: categoryId),

      // Сложные (7 слов)
      Word(text: 'Хамелеон', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'Кенгуру', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'Пингвин', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'Страус', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'Коала', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'Панда', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'Лев', difficulty: Difficulty.hard, categoryId: categoryId),
    ];

    for (final word in animalWords) {
      await _wordRepository.insertWord(word);
    }
    developer.log('Added ${animalWords.length} animal words');
  }

  Future<void> _addObjectWords(int categoryId) async {
    final objectWords = [
      // Легкие (8 слов)
      Word(text: 'Стол', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'Стул', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'Дверь', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'Окно', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'Книга', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'Карандаш', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'Бумага', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'Лампа', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'Чашка', difficulty: Difficulty.easy, categoryId: categoryId),

      // Средние (8 слов)
      Word(text: 'Компьютер', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Телефон', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Холодильник', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Микроволновка', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Пылесос', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Телевизор', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Принтер', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Клавиатура', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Монитор', difficulty: Difficulty.medium, categoryId: categoryId),

      // Сложные (7 слов)
      Word(text: 'Микроскоп', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'Телескоп', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'Генератор', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'Аккумулятор', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'Катализатор', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'Трансформатор', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'Конденсатор', difficulty: Difficulty.hard, categoryId: categoryId),
    ];

    for (final word in objectWords) {
      await _wordRepository.insertWord(word);
    }
    developer.log('Added ${objectWords.length} object words');
  }

  Future<void> _addProfessionWords(int categoryId) async {
    final professionWords = [
      // Легкие (8 слов)
      Word(text: 'Врач', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'Учитель', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'Повар', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'Водитель', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'Продавец', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'Сантехник', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'Электрик', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'Маляр', difficulty: Difficulty.easy, categoryId: categoryId),

      // Средние (8 слов)
      Word(text: 'Программист', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Архитектор', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Журналист', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Фотограф', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Дизайнер', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Бухгалтер', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Менеджер', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Инженер', difficulty: Difficulty.medium, categoryId: categoryId),

      // Сложные (7 слов)
      Word(text: 'Анестезиолог', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'Космонавт', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'Археолог', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'Палеонтолог', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'Геодезист', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'Хирург', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'Психолог', difficulty: Difficulty.hard, categoryId: categoryId),
    ];

    for (final word in professionWords) {
      await _wordRepository.insertWord(word);
    }
    developer.log('Added ${professionWords.length} profession words');
  }
}
