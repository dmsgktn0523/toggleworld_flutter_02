import 'package:flutter/material.dart';
import 'custom_web_view.dart';
import 'new_word_page.dart'; // 단어 추가 페이지 임포트

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  _DictionaryScreenState createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('영어사전', style: TextStyle(fontFamily: 'Raleway', color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF6030DF), // Updated purple color
      ),
      body: CustomWebView(
        onWordSelected: (word, meaning) {
          // 단어 선택 기능을 비활성화
          print("단어 선택 기능 비활성화 중...");
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 기존 단어 추가 페이지로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewWordPage(
                onAddWord: (word, meaning) {
                  // 단어 추가 페이지에서 단어 추가 후 처리 로직
                  print("새로운 단어 추가: $word - $meaning");
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Color(0xFF6030DF), // Updated purple color
      ),
    );
  }
}
