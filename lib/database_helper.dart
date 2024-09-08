import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'word_database.db'),
      onCreate: (db, version) async {
        // 단어 테이블 생성
        await db.execute(
          'CREATE TABLE words (id INTEGER PRIMARY KEY AUTOINCREMENT, word TEXT, meaning TEXT, list_id INTEGER, favorite INTEGER)',
        );

        // 단어장 테이블 생성
        await db.execute(
          'CREATE TABLE word_lists (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, description TEXT)',
        );
      },
      version: 1,
    );
  }

  // 단어 추가, 수정, 삭제 메서드
  static Future<void> addNewWord(String word, String meaning, int listId) async {
    try {
      final db = await initializeDB();
      await db.insert('words', {
        'word': word,
        'meaning': meaning,
        'list_id': listId,
        'favorite': 0,
      });
    } catch (e) {
      print("Error adding new word: $e");
    }
  }

  static Future<void> updateWord(int id, String newWord, String newMeaning) async {
    try {
      final db = await initializeDB();
      await db.update(
        'words',
        {'word': newWord, 'meaning': newMeaning},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("Error updating word: $e");
    }
  }

  static Future<void> updateFavorite(int id, int isFavorite) async {
    try {
      final db = await initializeDB();
      await db.update(
        'words',
        {'favorite': isFavorite},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("Error updating favorite status: $e");
    }
  }

  static Future<void> deleteWord(int id) async {
    try {
      final db = await initializeDB();
      await db.delete(
        'words',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("Error deleting word: $e");
    }
  }

  static Future<List<Map<String, dynamic>>> loadWords(int listId) async {
    final db = await initializeDB();
    try {
      return await db.query('words', where: 'list_id = ?', whereArgs: [listId]);
    } catch (e) {
      print("Error loading words: $e");
      return [];
    }
  }

  // 새로운 단어장 추가 메서드
  static Future<void> addNewWordList(String title, String description) async {
    try {
      final db = await initializeDB();
      await db.insert('word_lists', {
        'title': title,
        'description': description,
      });
    } catch (e) {
      print("Error adding new word list: $e");
    }
  }

  static Future<List<Map<String, dynamic>>> getAllWordLists() async {
    final db = await initializeDB();
    try {
      return await db.query('word_lists');
    } catch (e) {
      print("Error getting word lists: $e");
      return [];
    }
  }
}
