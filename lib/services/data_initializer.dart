import 'package:slova/models/category.dart';
import 'package:slova/models/word.dart';
import 'package:slova/repositories/category_repository.dart';
import 'package:slova/repositories/word_repository.dart';

class DataInitializer {
  final CategoryRepository _categoryRepository = CategoryRepository();
  final WordRepository _wordRepository = WordRepository();

  Future<void> initializeData() async {
    await _initializeCategories();
  }

  Future<void> _initializeCategories() async {
    // Проверяем, есть ли уже категории
    final categories = await _categoryRepository.getAllCategories();
    if (categories.isNotEmpty) {
      return; // Данные уже инициализированы
    }

    // Создаем категории
    final animalsCategoryId = await _categoryRepository.insertCategory(
      Category(name: 'Животные'),
    );
    final objectsCategoryId = await _categoryRepository.insertCategory(
      Category(name: 'Предметы'),
    );
    final professionsCategoryId = await _categoryRepository.insertCategory(
      Category(name: 'Профессии'),
    );

    // Добавляем слова для категории "Животные"
    await _addAnimalWords(animalsCategoryId);

    // Добавляем слова для категории "Предметы"
    await _addObjectWords(objectsCategoryId);

    // Добавляем слова для категории "Профессии"
    await _addProfessionWords(professionsCategoryId);
  }

  Future<void> _addAnimalWords(int categoryId) async {
    final animalWords = [
      // Легкие
      Word(text: 'Кот', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'Собака', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'Лошадь', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'Корова', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'Курица', difficulty: Difficulty.easy, categoryId: categoryId),

      // Средние
      Word(text: 'Жираф', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Слон', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Тигр', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Обезьяна', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Крокодил', difficulty: Difficulty.medium, categoryId: categoryId),

      // Сложные
      Word(text: 'Хамелеон', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'Кенгуру', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'Пингвин', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'Страус', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'Коала', difficulty: Difficulty.hard, categoryId: categoryId),
    ];

    for (final word in animalWords) {
      await _wordRepository.insertWord(word);
    }
  }

  Future<void> _addObjectWords(int categoryId) async {
    final objectWords = [
      // Легкие
      Word(text: 'Стол', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'Стул', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'Дверь', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'Окно', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'Книга', difficulty: Difficulty.easy, categoryId: categoryId),

      // Средние
      Word(text: 'Компьютер', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Телефон', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Холодильник', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Микроволновка', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Пылесос', difficulty: Difficulty.medium, categoryId: categoryId),

      // Сложные
      Word(text: 'Микроскоп', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'Телескоп', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'Генератор', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'Аккумулятор', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'Катализатор', difficulty: Difficulty.hard, categoryId: categoryId),
    ];

    for (final word in objectWords) {
      await _wordRepository.insertWord(word);
    }
  }

  Future<void> _addProfessionWords(int categoryId) async {
    final professionWords = [
      // Легкие
      Word(text: 'Врач', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'Учитель', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'Повар', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'Водитель', difficulty: Difficulty.easy, categoryId: categoryId),
      Word(text: 'Продавец', difficulty: Difficulty.easy, categoryId: categoryId),

      // Средние
      Word(text: 'Программист', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Архитектор', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Журналист', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Фотограф', difficulty: Difficulty.medium, categoryId: categoryId),
      Word(text: 'Дизайнер', difficulty: Difficulty.medium, categoryId: categoryId),

      // Сложные
      Word(text: 'Анестезиолог', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'Космонавт', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'Археолог', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'Палеонтолог', difficulty: Difficulty.hard, categoryId: categoryId),
      Word(text: 'Геодезист', difficulty: Difficulty.hard, categoryId: categoryId),
    ];

    for (final word in professionWords) {
      await _wordRepository.insertWord(word);
    }
  }
}
