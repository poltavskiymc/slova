import 'package:slova/models/word.dart';
import 'package:slova/services/database_service.dart';

class WordRepository {
  Future<List<Word>> getWordsByCategory(int categoryId) async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
    );

    return List.generate(maps.length, (i) {
      return Word.fromMap(maps[i]);
    });
  }

  Future<List<Word>> getWordsByCategoryAndDifficulty(int categoryId, Difficulty difficulty) async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'categoryId = ? AND difficulty = ?',
      whereArgs: [categoryId, difficulty.name],
    );

    return List.generate(maps.length, (i) {
      return Word.fromMap(maps[i]);
    });
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
