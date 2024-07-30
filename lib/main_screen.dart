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
            onBackPressed: _onBackPressed,  // Add this line
          ),
          DictionaryScreen(),
        ],
      ),
      bottomNavigationBar: ClipRRect(
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
    );
  }
}