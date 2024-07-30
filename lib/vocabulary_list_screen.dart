import 'package:flutter/material.dart';
import 'new_word_page.dart';

class VocabularyListScreen extends StatefulWidget {
  @override
  _VocabularyListScreenState createState() => _VocabularyListScreenState();
}

class _VocabularyListScreenState extends State<VocabularyListScreen> {
  bool _switchValue = true;

  List<Map<String, String>> vocabularyList = [
    {'word': 'Useful', 'meaning': '도움이 되다'},
    {'word': 'Sometimes', 'meaning': '때때로'},
    {'word': 'Synthesize', 'meaning': '(화학 물질을) 합성하다'},
  ];

  void _addNewWord(String word, String meaning) {
    setState(() {
      vocabularyList.add({'word': word, 'meaning': meaning});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0), // Adjust top and bottom padding
          child: Text(
            'Day01',
            style: TextStyle(
              color: Colors.white, // White color for the title
              fontFamily: 'Raleway', // Example of a custom font family
              fontWeight: FontWeight.bold, // Bold font weight
              fontSize: 20.0, // Smaller font size
              letterSpacing: 1.2, // Letter spacing
            ),
          ),
        ),
        backgroundColor: Color(0xFF6030DF), // Updated purple color
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
                  value: _switchValue,
                  onChanged: (value) {
                    setState(() {
                      _switchValue = value;
                    });
                  },
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
                      backgroundColor: vocabularyList[index]['word']!.isEmpty
                          ? Colors.transparent
                          : Color(0xFF6030DF), // Updated purple color
                      child: Text(
                        vocabularyList[index]['word']!.isEmpty
                            ? ''
                            : '${index + 1}',
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
                            fontWeight: vocabularyList[index]['word']!.isEmpty
                                ? FontWeight.normal
                                : FontWeight.bold,
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
                          color: vocabularyList[index]['word']!.isEmpty
                              ? Colors.transparent
                              : Colors.grey,
                          size: 20,
                        ), // Adjusted size
                        SizedBox(width: 10),
                        Icon(
                          Icons.star_border,
                          color: vocabularyList[index]['word']!.isEmpty
                              ? Colors.transparent
                              : Color(0xFF6030DF), // Purple color for the favorite icon
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
      floatingActionButton: FloatingActionButton(
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
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF6030DF), // Updated purple color
      ),
    );
  }
}
