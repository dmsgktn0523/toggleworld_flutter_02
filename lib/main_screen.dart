import 'package:flutter/material.dart';
import 'vocabulary_list_screen.dart';
import 'dictionary_screen.dart';
import 'word_list_library.dart';

class MainScreen extends StatefulWidget {
  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String _currentListTitle = '';
  int _currentListId = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void updateVocabularyListScreen(String title, int id) {
    setState(() {
      _currentListTitle = title;
      _currentListId = id;
      _selectedIndex = 1;
    });
  }

  void _onBackPressed() {
    setState(() {
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          WordListLibrary(
            onFolderTap: updateVocabularyListScreen,
          ),
          VocabularyListScreen(
            key: ValueKey(_currentListId),
            listTitle: _currentListTitle,
            listId: _currentListId,
            onBackPressed: _onBackPressed,
          ),
          DictionaryScreen(initialSearchWord: ''), // 빈 문자열로 초기화하거나 원하는 단어를 넣습니다.
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Shadow color
              blurRadius: 15, // How blurry the shadow is
              spreadRadius: 1, // How much the shadow spreads
              offset: Offset(0, -2), // Position of the shadow
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: '리스트',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book),
                label: '단어장',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.language),
                label: '영어사전',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Color(0xFF6030DF),
            onTap: _onItemTapped,
            backgroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}