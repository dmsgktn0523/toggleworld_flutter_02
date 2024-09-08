import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart'; // SQLite 데이터베이스 패키지
import 'package:path_provider/path_provider.dart'; // 파일 저장 경로
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences
import 'dart:io'; // 파일 입출력
import 'dart:convert'; // utf8 인코딩
import 'database_helper.dart'; // DatabaseHelper 클래스 가져오기
import 'package:csv/csv.dart'; // CSV 변환 패키지

class WordListLibrary extends StatefulWidget {
  final Function(String, int) onFolderTap;

  const WordListLibrary({super.key, required this.onFolderTap});

  @override
  _WordListLibraryState createState() => _WordListLibraryState();
}

class _WordListLibraryState extends State<WordListLibrary> {
  List<Map<String, String>> wordLists = [];
  Database? _database;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      _database = await DatabaseHelper.initializeDB();
      await _loadWordLists();
    } catch (e) {
      print('데이터베이스 초기화 오류: $e');
    }
  }

  Future<void> _loadWordLists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? wordListsString = prefs.getString('wordLists');

    if (wordListsString != null) {
      List<dynamic> jsonList = jsonDecode(wordListsString);
      List<Map<String, String>> loadedWordLists = jsonList.map((item) => Map<String, String>.from(item)).toList();

      setState(() {
        wordLists = loadedWordLists;
      });
    } else {
      setState(() {
        wordLists = [
          {'id': '1', 'title': 'day01', 'description': 'Commonly used words for daily conversation.'},
          {'id': '2', 'title': '업무', 'description': 'Words commonly used in business settings.'},
          {'id': '3', 'title': '유행어', 'description': 'Vocabulary for technical and scientific terms.'},
        ];
      });
      _saveWordLists();
    }
  }

  Future<void> _saveWordLists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(wordLists);
    await prefs.setString('wordLists', jsonString);
  }

  // CSV 내보내기 기능 구현
  Future<void> _exportWordListToCSV(String listTitle, int listId) async {
    try {
      // 선택된 단어장의 단어들 가져오기
      List<Map<String, dynamic>> words = await DatabaseHelper.loadWords(listId);

      // CSV로 변환할 데이터 준비
      List<List<String>> csvData = [
        ['Word', 'Meaning'] // CSV 파일 헤더
      ];

      for (var word in words) {
        csvData.add([word['word'], word['meaning']]);
      }

      // CSV 문자열 생성
      String csv = const ListToCsvConverter().convert(csvData);

      // 기본 저장소 디렉토리의 Documents 폴더 경로 가져오기
      final directory = await getExternalStorageDirectory();
      final documentsDir = Directory('${directory!.path}/Documents');

      // Documents 폴더가 없으면 생성
      if (!await documentsDir.exists()) {
        await documentsDir.create(recursive: true);
      }

      final path = '${documentsDir.path}/$listTitle.csv';



      // 파일 저장
      final file = File(path);
      await file.writeAsString(csv, encoding: utf8);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$listTitle 단어장을 CSV로 내보냈습니다: $path'),
      ));
    } catch (e) {
      print('CSV 내보내기 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('CSV 내보내기 중 오류가 발생했습니다.'),
      ));
    }
  }

  void _showExportDialog() {
    if (wordLists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('단어장이 없습니다.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String selectedListTitle = wordLists.first['title']!;
        int selectedListId = int.parse(wordLists.first['id']!);

        return AlertDialog(
          title: const Text('단어장 내보내기'),
          content: DropdownButtonFormField<String>(
            value: selectedListTitle,
            items: wordLists.map((list) {
              return DropdownMenuItem<String>(
                value: list['title'],
                child: Text(list['title']!),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedListTitle = value!;
                selectedListId = int.parse(wordLists.firstWhere((list) => list['title'] == value)['id']!);
              });
            },
            decoration: const InputDecoration(
              labelText: '내보낼 단어장 선택',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                _exportWordListToCSV(selectedListTitle, selectedListId);
                Navigator.pop(context);
              },
              child: const Text('내보내기'),
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
        title: const Text('단어장 홈', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF6030DF),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload, color: Colors.white), // 내보내기 아이콘으로 수정
            onPressed: _showExportDialog,
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white), // 가져오기 아이콘으로 수정
            onPressed: () {
              // 가져오기 기능 추가 예정
            },
          ),
        ],

      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showAddWordListDialog(),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    '단어장 추가',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6030DF),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListView.builder(
                itemCount: wordLists.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      leading: CircleAvatar(
                        radius: 12,
                        backgroundColor: const Color(0xFF6030DF),
                        child: const Icon(Icons.folder, color: Colors.white, size: 16),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            wordLists[index]['title']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                            ),
                          ),
                          Text(
                            wordLists[index]['description']!,
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
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

  void _showAddWordListDialog() {
    // Add word list dialog implementation here
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
              color: Color(0xFF6030DF),
            ),
          ),
          content: const Text(
            '이 폴더를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.',
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
                backgroundColor: const Color(0xFF6030DF),
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

  void _deleteFolder(int index) {
    setState(() {
      wordLists.removeAt(index);
    });
    _saveWordLists();
  }
}
