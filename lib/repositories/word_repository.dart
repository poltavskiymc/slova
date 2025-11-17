import 'package:slova/models/word.dart';
import 'package:slova/services/database_service.dart';
import 'dart:developer' as developer;

class WordRepository {
  Future<List<Word>> getWordsByCategory(int categoryId) async {
    developer.log('WordRepository: Getting words for category $categoryId');
    final db = await DatabaseService.database;
    developer.log('WordRepository: Database connected');

    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
    );

    developer.log('WordRepository: Found ${maps.length} raw records');

    final words = List.generate(maps.length, (i) {
      try {
        final word = Word.fromMap(maps[i]);
        developer.log('WordRepository: Parsed word: ${word.text} (${word.difficulty})');
        return word;
      } catch (e) {
        developer.log('WordRepository: Error parsing word at index $i: $e');
        rethrow;
      }
    });

    developer.log('WordRepository: Returning ${words.length} words');
    return words;
  }

  Future<List<Word>> getWordsByCategoryAndDifficulty(int categoryId, Difficulty difficulty) async {
    developer.log('WordRepository: Getting words for category $categoryId and difficulty $difficulty');
    final db = await DatabaseService.database;
    developer.log('WordRepository: Database connected');

    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'categoryId = ? AND difficulty = ?',
      whereArgs: [categoryId, difficulty.name],
    );

    developer.log('WordRepository: Found ${maps.length} raw records for difficulty $difficulty');

    final words = List.generate(maps.length, (i) {
      try {
        final word = Word.fromMap(maps[i]);
        developer.log('WordRepository: Parsed word: ${word.text} (${word.difficulty})');
        return word;
      } catch (e) {
        developer.log('WordRepository: Error parsing word at index $i: $e');
        rethrow;
      }
    });

    developer.log('WordRepository: Returning ${words.length} words for difficulty $difficulty');
    return words;
  }

  Future<int> insertWord(Word word) async {
    final db = await DatabaseService.database;
    return await db.insert('words', word.toMap());
  }

  Future<int> updateWord(Word word) async {
    final db = await DatabaseService.database;
    return await db.update(
      'words',
      word.toMap(),
      where: 'id = ?',
      whereArgs: [word.id],
    );
  }

  Future<int> deleteWord(int id) async {
    final db = await DatabaseService.database;
    return await db.delete(
      'words',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
