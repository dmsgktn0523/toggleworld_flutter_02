//page2

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path_utils;

class WordListLibrary extends StatefulWidget {
  final Function(String, int) onFolderTap;

  const WordListLibrary({super.key, required this.onFolderTap});

  @override
  _WordListLibraryState createState() => _WordListLibraryState();
}

class _WordListLibraryState extends State<WordListLibrary> {
  List<Map<String, String>> wordLists = [];
  Database? _database;

  Future<void> _ensureDatabaseConnected() async {
    if (_database == null || !_database!.isOpen) {
      print('데이터베이스 재연결 시도');
      _database = await initializeDB();
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      _database = await initializeDB();
      await _loadWordLists();
    } catch (e) {
      print('데이터베이스 초기화 오류: $e');
    }
  }

  Future<Database> initializeDB() async {
    String databasesPath = await getDatabasesPath();
    String path = path_utils.join(databasesPath, 'word_database.db');
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

  Future<void> _loadWordLists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? wordListsString = prefs.getString('wordLists');

    if (wordListsString != null) {
      List<dynamic> jsonList = jsonDecode(wordListsString);
      List<Map<String, String>> loadedWordLists = jsonList.map((item) => Map<String, String>.from(item)).toList();

      // Ensure each word list has a unique `list_id`
      for (int i = 0; i < loadedWordLists.length; i++) {
        if (!loadedWordLists[i].containsKey('id')) {
          loadedWordLists[i]['id'] = (i + 1).toString();
        }
      }

      setState(() {
        wordLists = loadedWordLists;
      });
    } else {
      // Initialize with default word lists
      setState(() {
        wordLists = [
          {'id': '1', 'title': 'day01', 'description': 'Commonly used words for daily conversation.'},
          {'id': '2', 'title': '업무', 'description': 'Words commonly used in business settings.'},
          {'id': '3', 'title': '유행어', 'description': 'Vocabulary for technical and scientific terms.'},
        ];
      });
      _saveWordLists(); // Save the default word lists with `id`
    }
  }

  Future<void> _saveWordLists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(wordLists);
    await prefs.setString('wordLists', jsonString);
  }

  void _showAddWordListDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            '새 단어장 추가',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
              color: Color(0xFF6030DF), // Updated purple color
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: '단어장 제목',
                  hintStyle: TextStyle(
                    fontFamily: 'Raleway',
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Color(0xFF6030DF), // Updated purple color
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Color(0xFF6030DF), // Updated purple color
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: '단어장 설명',
                  hintStyle: TextStyle(
                    fontFamily: 'Raleway',
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Color(0xFF6030DF), // Updated purple color
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Color(0xFF6030DF), // Updated purple color
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                '취소',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text;
                final description = descriptionController.text.isNotEmpty ? descriptionController.text : ' ';

                bool isDuplicate = wordLists.any((element) => element['title'] == title);

                if (title.isNotEmpty && !isDuplicate) {
                  setState(() {
                    int newId = wordLists.length + 1;
                    wordLists.add({
                      'id': newId.toString(),
                      'title': title,
                      'description': description,
                    });
                  });
                  _saveWordLists();
                  Navigator.pop(context);
                } else if (isDuplicate) {
                  Navigator.pop(context);
                  _showWarningDialog('동일한 제목의 단어장이 이미 존재합니다.');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6030DF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                '추가',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showWarningDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            '경고',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
              color: Color(0xFF6030DF), // Updated purple color
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 16.0,
              color: Colors.black,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                '확인',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: const Text(
            '단어장 홈',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Raleway',
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
              letterSpacing: 1.2,
            ),
          ),
        ),
        backgroundColor: Color(0xFF6030DF),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFF5F6FA),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
            ),
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  onPressed: _showAddWordListDialog,
                  icon: Icon(Icons.add, color: Colors.white),
                  label: Text(
                    '단어장 추가',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6030DF),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListView.builder(
                itemCount: wordLists.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      leading: CircleAvatar(
                        radius: 12,
                        backgroundColor: Color(0xFF6030DF),
                        child: Icon(Icons.folder, color: Colors.white, size: 16),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            wordLists[index]['title']!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                            ),
                          ),
                          Text(
                            wordLists[index]['description']!,
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      onTap: () {
                        widget.onFolderTap(wordLists[index]['title']!, int.parse(wordLists[index]['id']!));
                      },
                      onLongPress: () {
                        _showDeleteDialog(index);
                      },

                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }


  void _deleteFolder(int index) async {
    int listId = int.parse(wordLists[index]['id']!);

    await _deleteWordsByListId(listId);

    setState(() {
      wordLists.removeAt(index);
    });

    await _saveWordLists();

    // 1초 후 다시 로드
    Future.delayed(Duration(seconds: 1), () async {
      await _loadWordLists();
    });
  }



// 특정 list_id와 연결된 모든 단어를 데이터베이스에서 삭제
  Future<void> _deleteWordsByListId(int listId) async {
    await _ensureDatabaseConnected();
    await _database?.delete(
      'words',
      where: 'list_id = ?',
      whereArgs: [listId],
    );

    // 삭제 후 쿼리로 데이터베이스 확인
    final List<Map<String, dynamic>> remainingWords = await _database?.query(
      'words',
      where: 'list_id = ?',
      whereArgs: [listId],
    ) ?? [];

    if (remainingWords.isEmpty) {
      print('모든 단어가 삭제되었습니다.');
    } else {
      print('삭제되지 않은 단어가 있습니다: $remainingWords');
    }
  }


  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            '폴더 삭제',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
              color: Color(0xFF6030DF), // Updated purple color
            ),
          ),
          content: const Text(
            '이 폴더와 해당 폴더의 모든 단어를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 16.0,
              color: Colors.black,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                '취소',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteFolder(index);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6030DF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                '삭제',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

}

