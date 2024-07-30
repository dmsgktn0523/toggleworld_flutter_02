import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class NewWordPage extends StatefulWidget {
  final Function(String, String) onAddWord;

  const NewWordPage({super.key, required this.onAddWord});

  @override
  _NewWordPageState createState() => _NewWordPageState();
}

class _NewWordPageState extends State<NewWordPage> {
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _translationController = TextEditingController();
  final TextEditingController _multiWordController = TextEditingController();
  final TextEditingController _multiTranslationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('단어 추가', style: TextStyle(fontFamily: 'Raleway', color: Colors.white)),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.add), text: '간단 추가'),
              Tab(icon: Icon(Icons.list), text: '멀티 추가'),
            ],
          ),
          backgroundColor: Color(0xFF6030DF), // Updated purple color
        ),
        body: TabBarView(
          children: [
            simpleAddTab(),
            multiAddTab(),
          ],
        ),
      ),
    );
  }

  Widget simpleAddTab() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double topPadding = MediaQuery.of(context).size.height * 0.1;

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: TextField(
                    controller: _wordController,
                    decoration: InputDecoration(
                      labelText: '단어 입력',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          if (_wordController.text.isNotEmpty) {
                            translateWord(_wordController.text, _translationController);
                          }
                        },
                      ),
                      border: const UnderlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: TextField(
                    controller: _translationController,
                    decoration: const InputDecoration(
                      labelText: "단어의 뜻",
                      border: UnderlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                actionButtons(_wordController, _translationController, isMulti: false),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget multiAddTab() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double topPadding = MediaQuery.of(context).size.height * 0.1;

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: topPadding, left: 50.0, right: 50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                TextField(
                  controller: _multiWordController,
                  decoration: const InputDecoration(
                    labelText: '여러 단어 입력',
                    border: UnderlineInputBorder(),
                  ),
                  minLines: 3,
                  maxLines: 5,
                ),
                const SizedBox(height: 20),
                const Text(
                  "여러 단어를 띄어쓰기로 구분하여 입력하면 한번에 저장됩니다.",
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 40),
                actionButtons(_multiWordController, _multiTranslationController, isMulti: true)
              ],
            ),
          ),
        );
      },
    );
  }

  Widget actionButtons(TextEditingController wordController, TextEditingController translationController, {bool isMulti = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.grey),
            foregroundColor: MaterialStateProperty.all(Colors.white),
          ),
          child: const Text('돌아가기'),
        ),
        ElevatedButton(
          onPressed: () {
            final words = wordController.text.trim();
            if (words.isEmpty) {
              showSnackbar('단어를 입력해주세요! ⚠️', 500);
              return;
            }

            if (isMulti) {
              translateMultipleWords(words);
            } else {
              final meaning = translationController.text.trim();
              widget.onAddWord(words, meaning);
              showSnackbar('$words 추가 완료 ✅', 100);
            }

            wordController.clear();
            translationController.clear();
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Color(0xFF6030DF)), // Updated purple color
          ),
          child: const Text('단어 추가', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  void showSnackbar(String message, int durationMillis) {
    var keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      duration: Duration(milliseconds: durationMillis),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        bottom: keyboardHeight + 16,
        left: 16,
        right: 16,
      ),
      backgroundColor: Colors.black.withOpacity(0.8),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void translateWord(String word, TextEditingController translationController) async {
    try {
      final response = await http.get(Uri.parse("https://search.naver.com/search.naver?where=nexearch&sm=top_hty&fbm=0&ie=utf8&query=$word+%EB%9C%BB"));
      var document = parse(response.body);
      var translation = document.querySelector("p.mean.api_txt_lines")?.text;
      setState(() {
        translationController.text = translation ?? " ";
      });
    } catch (e) {
      setState(() {
        translationController.text = "Translation failed.";
      });
    }
  }

  void translateMultipleWords(String words) async {
    List<String> wordList = words.split(' ');
    for (String word in wordList) {
      if (word.isNotEmpty) {
        await translateAndAddWord(word);
      }
    }
  }

  Future<void> translateAndAddWord(String word) async {
    try {
      final response = await http.get(Uri.parse("https://search.naver.com/search.naver?where=nexearch&sm=top_hty&fbm=0&ie=utf8&query=$word+%EB%9C%BB"));
      var document = parse(response.body);
      var translation = document.querySelector("p.mean.api_txt_lines")?.text ?? " ";
      widget.onAddWord(word, translation);
      showSnackbar('$word 추가 완료 ✅', 10);
    } catch (e) {
      showSnackbar('$word 번역 실패 ⚠️', 500);
    }
  }
}
