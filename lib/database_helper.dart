// database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart'; // Import for path management
import 'models/word.dart';

class DatabaseHelper {
  static Future<Database> initializeDB() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'word_database.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE words (id INTEGER PRIMARY KEY AUTOINCREMENT, word TEXT, meaning TEXT, list_id INTEGER, favorite INTEGER)',
        );
      },
    );
  }

  static Future<void> updateWord(int id, String newWord, String newMeaning) async {
    final db = await initializeDB();
    await db.update(
      'words',
      {'word': newWord, 'meaning': newMeaning},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<List<Map<String, dynamic>>> loadWords(int listId) async {
    final db = await initializeDB();
    return await db.query('words', where: 'list_id = ?', whereArgs: [listId]);
  }

  static Future<void> addNewWord(String word, String meaning, int listId) async {
    final db = await initializeDB();
    await db.insert('words', {
      'word': word,
      'meaning': meaning,
      'list_id': listId,
      'favorite': 0,
    });
  }

  static Future<void> updateFavorite(int id, int isFavorite) async {
    final db = await initializeDB();
    await db.update(
      'words',
      {'favorite': isFavorite},
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  static Future<void> deleteWord(int id) async {
    final db = await initializeDB();  // DB 초기화
    await db.delete(
      'words',  // 테이블 이름
      where: 'id = ?',  // 삭제할 항목을 찾기 위한 조건
      whereArgs: [id],  // 조건에 해당하는 값
    );
  }


}



