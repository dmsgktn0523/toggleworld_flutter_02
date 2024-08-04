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
  bool hideWord = false;

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
    final List<Map<String, dynamic>> queryResults =
    await DatabaseHelper.loadWords(widget.listId);
    setState(() {
      vocabularyList = queryResults.map((word) => Word.fromMap(word)).toList();
    });
  }

  void _addNewWord(String word, String meaning) async {
    await DatabaseHelper.addNewWord(word, meaning, widget.listId);
    await _loadWords();
  }

  void _toggleFavorite(int id) async {
    final word = vocabularyList.firstWhere((word) => word.id == id);
    int newFavorite = word.favorite == 1 ? 0 : 1;
    await DatabaseHelper.updateFavorite(id, newFavorite);

    setState(() {
      // Update local list
      word.favorite = newFavorite;
    });
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.black),
                title: const Text('편집하기'),
                onTap: () {
                  // Add edit functionality here
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.sort, color: Colors.black),
                title: const Text('정렬하기'),
                onTap: () {
                  // Add sorting functionality here
                  Navigator.pop(context);
                  _showSortMenu();
                },
              ),
              ListTile(
                leading: const Icon(Icons.visibility, color: Colors.black),
                title: const Text('보기 설정'),
                onTap: () {
                  // Add view setting functionality here
                  Navigator.pop(context);
                  _showViewSettingsDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSortMenu() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('정렬하기'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text('A-Z 순'),
                onTap: () {
                  // Sort logic for A-Z
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Z-A 순'),
                onTap: () {
                  // Sort logic for Z-A
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('즐겨찾기순'),
                onTap: () {
                  // Sort logic for favorite
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showViewSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('보기 설정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text('단어 가리기'),
                leading: Radio<bool>(
                  value: true,
                  groupValue: hideWord,
                  onChanged: (bool? value) {
                    setState(() {
                      hideWord = value!;
                      Navigator.of(context).pop();
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('뜻 가리기'),
                leading: Radio<bool>(
                  value: false,
                  groupValue: hideWord,
                  onChanged: (bool? value) {
                    setState(() {
                      hideWord = value!;
                      Navigator.of(context).pop();
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _calculateTextHeight(String text, TextStyle style, double maxWidth) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: null,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: maxWidth);
    return textPainter.size.height;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onBackPressed,
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Text(
            widget.listTitle,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Raleway',
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
              letterSpacing: 1.2,
            ),
          ),
        ),
        backgroundColor: const Color(0xFF6030DF),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: _showOptionsMenu,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF5F6FA),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            NewWordPage(onAddWord: _addNewWord),
                      ),
                    );

                    if (result != null && result is Map<String, String>) {
                      _addNewWord(result['word']!, result['meaning']!);
                    }
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    '단어 추가',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6030DF),
                  ),
                ),
                Switch(
                  value: isToggled,
                  onChanged: (value) {
                    setState(() {
                      isToggled = value;
                    });
                  },
                  activeColor: const Color(0xFF6030DF),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListView.separated(
                itemCount: vocabularyList.length,
                itemBuilder: (context, index) {
                  final word = vocabularyList[index];
                  final TextStyle textStyle =
                  const TextStyle(fontSize: 12.0, color: Colors.grey);
                  final double textWidth =
                      MediaQuery.of(context).size.width - 80;
                  final double textHeight =
                  _calculateTextHeight(word.meaning, textStyle, textWidth);

                  return ListTile(
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    leading: CircleAvatar(
                      radius: 12,
                      backgroundColor: const Color(0xFF6030DF),
                      child: Text(
                        '${index + 1}',
                        style:
                        const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Text(
                              word.word,
                              style: const TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isToggled && hideWord)
                              Container(
                                width: textWidth,
                                height: 20.0, // Consistent height for words
                                color: Colors.grey[200], // Light gray overlay
                              ),
                          ],
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: textHeight, // Keep height consistent
                          child: Stack(
                            children: [
                              Text(
                                word.meaning,
                                style: textStyle,
                              ),
                              if (isToggled && !hideWord)
                                Container(
                                  width: textWidth,
                                  height: textHeight,
                                  color: Colors.grey[200], // Light gray overlay
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.search,
                          color: Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            _toggleFavorite(word.id);
                          },
                          child: Icon(
                            word.favorite == 1 ? Icons.star : Icons.star_border,
                            color: const Color(0xFF6030DF),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Divider(
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
