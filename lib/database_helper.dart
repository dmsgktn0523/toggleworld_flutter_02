import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {


  static Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'word_database.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE words (id INTEGER PRIMARY KEY AUTOINCREMENT, word TEXT, meaning TEXT, list_id INTEGER, favorite INTEGER)',
        );

        await db.execute(
          'CREATE TABLE word_lists (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, description TEXT)',
        );

        // 기본 폴더 추가
        await db.insert('word_lists', {'title': 'daily', 'description': 'Commonly used words for daily conversation.'});
        await db.insert('word_lists', {'title': 'business', 'description': 'Words commonly used in business settings.'});
        await db.insert('word_lists', {'title': 'slang', 'description': 'Vocabulary for technical and scientific terms.'});
      },
      version: 1,
    );
  }


  // 단어 추가 메서드
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

  static Future<bool> checkWordListExists(String title) async {
    final db = await initializeDB();
    final result = await db.query(
      'word_lists',
      where: 'title = ?',
      whereArgs: [title],
    );

    // 기본 폴더와 비교하여 중복 여부 확인
    bool isDefaultList = title == 'daily' || title == 'business' || title == 'slang';
    return result.isNotEmpty || isDefaultList; // 데이터베이스에 있거나 기본 폴더 이름일 경우 true 반환
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
      // 동일한 이름의 단어장이 있는지 확인
      if (await checkWordListExists(title)) {
        print("A word list with the title '$title' already exists."); // 동일한 이름의 단어장이 있을 경우 메시지 출력
        return; // 중복이 있으면 종료
      }
      await db.insert('word_lists', {
        'title': title,
        'description': description,
      });
    } catch (e) {
      print("Error adding new word list: $e");
    }
  }


  // Method to delete a word list and its associated words
  static Future<void> deleteWordList(int listId) async {
    try {
      final db = await initializeDB();

      // Delete all words associated with the word list
      await db.delete(
        'words',
        where: 'list_id = ?',
        whereArgs: [listId],
      );

      // Delete the word list itself
      await db.delete(
        'word_lists',
        where: 'id = ?',
        whereArgs: [listId],
      );
    } catch (e) {
      print("Error deleting word list: $e");
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
