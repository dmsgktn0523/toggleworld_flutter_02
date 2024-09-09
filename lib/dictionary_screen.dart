import 'package:flutter/material.dart';
import 'custom_web_view.dart';
import 'new_word_page.dart'; // Import the word addition page

class DictionaryScreen extends StatefulWidget {
  final String initialSearchWord; // Add this parameter

  const DictionaryScreen({Key? key, required this.initialSearchWord}) : super(key: key);

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
        backgroundColor: const Color(0xFF6030DF),
      ),
      body: CustomWebView(
        initialSearchWord: widget.initialSearchWord, // Pass the initial search word to the WebView
        onWordSelected: (word, meaning) {
          print("Word selection functionality is disabled...");
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewWordPage(
                onAddWord: (word, meaning) {
                  print("새로운 단어 추가: $word - $meaning");
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFF6030DF),
      ),
    );
  }
}
