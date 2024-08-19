import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart'; // Import FlutterSwitch
import 'dart:math'; // For random sorting
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
  String sortOrder = 'A-Z'; // Default sort order

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
      _sortWords(); // Ensure words are sorted on load
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

  bool isEditing = false;
  Set<int> selectedWords = {}; // 선택된 단어의 ID를 저장할 Set
  bool selectAll = false; // 전체 선택 상태를 관리


  void _toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
      selectedWords.clear();
      selectAll = false; // Reset select all status
    });
  }


  Future<void> _deleteSelectedWords() async {
    for (int id in selectedWords) {
      await DatabaseHelper.deleteWord(id);
    }
    _toggleEditMode(); // 편집 모드 종료
    _loadWords(); // 단어 목록 새로고침
  }





  void _sortWords() {
    setState(() {
      switch (sortOrder) {
        case 'A-Z':
          vocabularyList.sort((a, b) => a.word.compareTo(b.word));
          break;
        case 'Z-A':
          vocabularyList.sort((a, b) => b.word.compareTo(a.word));
          break;
        case 'Recent':
          vocabularyList.sort((a, b) => b.id.compareTo(a.id));
          break;
        case 'Oldest':
          vocabularyList.sort((a, b) => a.id.compareTo(b.id));
          break;
        case 'Random':
          vocabularyList.shuffle(Random());
          break;
        case 'Favorites':
          vocabularyList.sort((a, b) {
            if (a.favorite != b.favorite) {
              return b.favorite.compareTo(a.favorite);
            } else {
              return a.word.compareTo(b.word);
            }
          });
          break;
      }
    });
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
                  sortOrder = 'A-Z';
                  Navigator.pop(context);
                  _sortWords();
                },
              ),
              ListTile(
                title: const Text('Z-A 순'),
                onTap: () {
                  sortOrder = 'Z-A';
                  Navigator.pop(context);
                  _sortWords();
                },
              ),
              ListTile(
                title: const Text('최신 저장순'),
                onTap: () {
                  sortOrder = 'Recent';
                  Navigator.pop(context);
                  _sortWords();
                },
              ),
              ListTile(
                title: const Text('오래된순'),
                onTap: () {
                  sortOrder = 'Oldest';
                  Navigator.pop(context);
                  _sortWords();
                },
              ),
              ListTile(
                title: const Text('랜덤순'),
                onTap: () {
                  sortOrder = 'Random';
                  Navigator.pop(context);
                  _sortWords();
                },
              ),
              ListTile(
                title: const Text('즐겨찾기순'),
                onTap: () {
                  sortOrder = 'Favorites';
                  Navigator.pop(context);
                  _sortWords();
                },
              ),
            ],
          ),
        );
      },
    );
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
                  Navigator.pop(context);
                  _toggleEditMode(); // 편집 모드로 전환
                },
              ),

              ListTile(
                leading: const Icon(Icons.sort, color: Colors.black),
                title: const Text('정렬하기'),
                onTap: () {
                  Navigator.pop(context);
                  _showSortMenu();
                },
              ),
              ListTile(
                leading: const Icon(Icons.visibility, color: Colors.black),
                title: const Text('보기 설정'),
                onTap: () {
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


  OverlayEntry? _overlayEntry;

  void _showCustomSnackbar(BuildContext context, String message) {
    // Hide the existing overlay entry if it exists
    _hideCustomSnackbar();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.87,
        left: 30.0,
        right: 30.0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            decoration: BoxDecoration(
              color: const Color(0xFF6030DF).withOpacity(0.8),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );


    // Insert the overlay entry into the overlay
    Overlay.of(context)?.insert(_overlayEntry!);

    // Automatically remove the overlay after 1 second
    Future.delayed(const Duration(seconds: 1), _hideCustomSnackbar);
  }

  void _hideCustomSnackbar() {
    _overlayEntry?.remove();
    _overlayEntry = null;
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
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: selectedWords.isEmpty ? null : _deleteSelectedWords,
            ),
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: _toggleEditMode, // 편집 모드 종료
            ),
          if (!isEditing)
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
                if (isEditing)
                  Checkbox(
                    value: selectAll,
                    onChanged: (bool? value) {
                      setState(() {
                        selectAll = value!;
                        if (selectAll) {
                          selectedWords.addAll(vocabularyList.map((word) => word.id));
                        } else {
                          selectedWords.clear();
                        }
                      });
                    },
                  ),

                if (!isEditing)
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
                if (isEditing)

                  const Spacer(), // CheckBox를 좌측에 위치하도록 공간을 확보
                if (!isEditing)
                  FlutterSwitch(
                    value: isToggled,
                    onToggle: (value) {
                      setState(() {
                        isToggled = value;
                      });
                    },
                    activeColor: const Color(0xFF6030DF),
                    inactiveColor: Colors.grey[300]!,
                    inactiveToggleColor: Colors.white,
                    width: 60.0,
                    height: 35.0,
                    toggleSize: 20.0,
                    borderRadius: 20.0,
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    leading: isEditing
                        ? Checkbox(
                      value: selectedWords.contains(word.id),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedWords.add(word.id);
                          } else {
                            selectedWords.remove(word.id);
                          }
                        });
                      },
                    )
                        : CircleAvatar(
                      radius: 12,
                      backgroundColor: const Color(0xFF6030DF),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
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
                          duration: const Duration(milliseconds: 100),
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
                    onTap: () {
                      if (isToggled) {
                        if (hideWord) {
                          _showCustomSnackbar(context, word.word); // 단어를 SnackBar로 보여줌
                        } else {
                          _showCustomSnackbar(context, word.meaning); // 뜻을 SnackBar로 보여줌
                        }
                      }
                    },






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
