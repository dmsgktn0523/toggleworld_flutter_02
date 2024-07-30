import 'package:flutter/material.dart';

class WordListPage extends StatelessWidget {
  final String listTitle;
  final int listId;
  final List<Map<String, String>> wordLists;

  WordListPage({required this.listTitle, required this.listId, required this.wordLists});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(listTitle),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Text('단어 리스트를 여기에 표시합니다.'),
      ),
    );
  }
}
