import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:csv/csv.dart'; // CSV 변환 패키지
import 'package:file_picker/file_picker.dart'; // 파일 선택 패키지
import 'dart:io';
import 'dart:convert';
import 'database_helper.dart';


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

  // CSV 파일 가져오기 기능
  Future<void> _importCSV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = file.path.split('/').last.split('.').first; // 파일 이름에서 확장자 제거

      // 새 단어장 생성
      await DatabaseHelper.addNewWordList(fileName, 'Imported from CSV');

      // 방금 생성된 단어장의 ID 가져오기
      List<Map<String, dynamic>> allLists = await DatabaseHelper.getAllWordLists();
      int newListId = allLists.last['id']; // 최신 추가된 단어장의 ID를 가져옴

      // CSV 파일 읽기
      final input = file.openRead();
      final fields = await input
          .transform(utf8.decoder)
          .transform(CsvToListConverter())
          .toList();

      // 데이터베이스에 저장
      for (int i = 1; i < fields.length; i++) {
        String word = fields[i][0].toString();
        String meaning = fields[i][1].toString();

        // 단어 추가
        await DatabaseHelper.addNewWord(word, meaning, newListId);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$fileName 단어장을 성공적으로 생성하고 내용을 불러왔습니다.')),
      );

      await _loadWordLists(); // UI 업데이트를 위해 단어장 목록 새로고침
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('파일 선택을 취소하셨습니다.')),
      );
    }
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

  Future<void> _exportWordListToCSV(String listTitle, int listId) async {
    try {
      List<Map<String, dynamic>> words = await DatabaseHelper.loadWords(listId);
      List<List<String>> csvData = [['Word', 'Meaning']];

      for (var word in words) {
        csvData.add([word['word'], word['meaning']]);
      }

      String csv = const ListToCsvConverter().convert(csvData);
      final directory = await getExternalStorageDirectory();
      final documentsDir = Directory('${directory!.path}/Documents');

      if (!await documentsDir.exists()) {
        await documentsDir.create(recursive: true);
      }

      final path = '${documentsDir.path}/$listTitle.csv';
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
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: _importCSV, // CSV 가져오기 기능 연결
          ),
          IconButton(
            icon: const Icon(Icons.upload, color: Colors.white),
            onPressed: _showExportDialog, // CSV 내보내기 기능 연결
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
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('새 단어장 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: '단어장 이름',
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: '단어장 설명',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final description = descriptionController.text.trim();

                if (title.isNotEmpty) {
                  await DatabaseHelper.addNewWordList(title, description);
                  await _loadWordLists(); // 단어장 목록 새로고침
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$title 단어장이 추가되었습니다.')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('단어장 이름을 입력해주세요.')),
                  );
                }
              },
              child: const Text('추가'),
            ),
          ],
        );
      },
    );
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
