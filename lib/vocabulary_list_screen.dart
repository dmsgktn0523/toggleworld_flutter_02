import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path_utils;
import 'new_word_page.dart';

class VocabularyListScreen extends StatefulWidget {
  final String listTitle;
  final int listId;
  final VoidCallback onBackPressed;  // Add this line

  const VocabularyListScreen({
    Key? key,
    required this.listTitle,
    required this.listId,
    required this.onBackPressed,  // Add this line
  }) : super(key: key);

  @override
  _VocabularyListScreenState createState() => _VocabularyListScreenState();
}

class _VocabularyListScreenState extends State<VocabularyListScreen> {
  Database? _database;
  List<Map<String, String>> vocabularyList = [];

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  @override
  void didUpdateWidget(VocabularyListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.listId != oldWidget.listId) {
      _loadWords();
    }
  }

  Future<void> _initializeDatabase() async {
    try {
      _database = await initializeDB();
      await _loadWords();
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

  Future<void> _loadWords() async {
    if (_database != null && _database!.isOpen) {
      final List<Map<String, dynamic>> queryResults = await _database!.query(
        'words',
        where: 'list_id = ?',
        whereArgs: [widget.listId],
      );
      setState(() {
        vocabularyList = queryResults.map((word) => {
          'word': word['word'] as String,
          'meaning': word['meaning'] as String,
        }).toList();
      });
    }
  }

  void _addNewWord(String word, String meaning) async {
    if (_database != null && _database!.isOpen) {
      await _database!.insert('words', {
        'word': word,
        'meaning': meaning,
        'list_id': widget.listId, // 현재 리스트의 ID로 저장
        'favorite': 0,
      });
      await _loadWords(); // 새 단어를 추가한 후 업데이트된 단어 리스트를 로드
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onBackPressed,
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Text(
            widget.listTitle,
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
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // Edit/modify button action
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFF5F6FA), // Light grey background color
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
            ),
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewWordPage(onAddWord: _addNewWord),
                      ),
                    );

                    if (result != null && result is Map<String, String>) {
                      _addNewWord(result['word']!, result['meaning']!);
                    }
                  },
                  icon: Icon(Icons.add, color: Colors.white),
                  label: Text(
                    '단어 추가',
                    style: TextStyle(color: Colors.white), // White text color
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6030DF), // Updated purple color
                  ),
                ),
                Switch(
                  value: true, // Example value, change according to your logic
                  onChanged: (value) {},
                  activeColor: Color(0xFF6030DF), // Updated purple color
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20), // 양쪽 마진을 줄이려면 이 부분을 수정하세요
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListView.separated(
                itemCount: vocabularyList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    leading: CircleAvatar(
                      radius: 12, // Smaller size for the CircleAvatar
                      backgroundColor: Color(0xFF6030DF), // Updated purple color
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(color: Colors.white, fontSize: 10), // Smaller font size
                      ),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vocabularyList[index]['word'] ?? '',
                          style: TextStyle(
                            fontSize: 14.0, // Smaller font size for the word
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          vocabularyList[index]['meaning'] ?? '',
                          style: TextStyle(
                            fontSize: 12.0, // Smaller font size for the meaning
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search,
                          color: Colors.grey,
                          size: 20,
                        ), // Adjusted size
                        SizedBox(width: 10),
                        Icon(
                          Icons.star_border,
                          color: Color(0xFF6030DF), // Purple color for the favorite icon
                          size: 20,
                        ), // Adjusted size
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey,
                  thickness: 1,
                  indent: 10,
                  endIndent: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
