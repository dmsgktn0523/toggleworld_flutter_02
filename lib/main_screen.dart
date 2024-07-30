import 'package:flutter/material.dart';
import 'vocabulary_list_screen.dart';
import 'dictionary_screen.dart';
import 'word_list_library.dart'; // Import the WordListLibrary screen

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // 리스트를 기본 선택 탭으로 설정

  static List<Widget> _widgetOptions = <Widget>[
    WordListLibrary(), // Add WordListLibrary to the list
    VocabularyListScreen(),
    DictionaryScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
    bottomNavigationBar: Container(
      height: 70.0, // 높이를 조정하는 부분
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // 그림자 색상
            spreadRadius: 5, // 그림자의 확산 반경
            blurRadius: 70, // 그림자의 흐림 반경
            offset: Offset(0, -3), // 그림자의 위치 조정
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
          selectedItemColor: Color(0xFF6030DF), // Updated purple color
          onTap: _onItemTapped,
          backgroundColor: Colors.white, // Background color for the navigation bar
        ),
      ),
    ),

    );
  }
}
