import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'models/word.dart';
import 'new_word_page.dart';

class VocabularyListScreen extends StatefulWidget {
  final String listTitle;
  final int listId;
  final VoidCallback onBackPressed;

  const VocabularyListScreen({
    Key? key,
    required this.listTitle,
    required this.listId,
    required this.onBackPressed,
  }) : super(key: key);

  @override
  _VocabularyListScreenState createState() => _VocabularyListScreenState();
}

class _VocabularyListScreenState extends State<VocabularyListScreen> {
  List<Word> vocabularyList = [];
  bool isToggled = false;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  @override
  void didUpdateWidget(VocabularyListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.listId != oldWidget.listId) {
      _loadWords();
    }
  }

  Future<void> _loadWords() async {
    final List<Map<String, dynamic>> queryResults = await DatabaseHelper.loadWords(widget.listId);
    setState(() {
      vocabularyList = queryResults.map((word) => Word.fromMap(word)).toList();
    });
  }

  void _addNewWord(String word, String meaning) async {
    await DatabaseHelper.addNewWord(word, meaning, widget.listId);
    await _loadWords();
  }

  void _toggleFavorite(int id, bool isFavorite) async {
    await DatabaseHelper.updateFavorite(id, isFavorite);
    await _loadWords();
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
              color: Color(0xFFF5F6FA),
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
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6030DF),
                  ),
                ),
                Switch(
                  value: isToggled,
                  onChanged: (value) {
                    setState(() {
                      isToggled = value;
                    });
                  },
                  activeColor: Color(0xFF6030DF),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
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
                      radius: 12,
                      backgroundColor: Color(0xFF6030DF),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vocabularyList[index].word,
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          child: isToggled
                              ? Container(
                            height: 16.0,
                            color: Colors.grey[200],
                          )
                              : Text(
                            vocabularyList[index].meaning,
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.grey,
                            ),
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
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            _toggleFavorite(vocabularyList[index].id, vocabularyList[index].favorite == 0);
                          },
                          child: Icon(
                            vocabularyList[index].favorite == 1
                                ? Icons.star
                                : Icons.star_border,
                            color: Color(0xFF6030DF),
                            size: 20,
                          ),
                        ),
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
