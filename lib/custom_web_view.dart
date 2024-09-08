import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CustomWebView extends StatefulWidget {
  final Function(String, String) onWordSelected;

  const CustomWebView({Key? key, required this.onWordSelected}) : super(key: key);

  @override
  _CustomWebViewState createState() => _CustomWebViewState();
}

class _CustomWebViewState extends State<CustomWebView> {
  late WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: 'https://en.dict.naver.com/#/main',
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) {
        _controller = webViewController;
      },
      onPageFinished: (String url) {
        _fetchSearchedWord();
      },
    );
  }

  void _fetchSearchedWord() {
    _controller.runJavascriptReturningResult('''
      (function() {
        var wordElement = document.querySelector('.entry_title strong.word');
        if (wordElement) {
          // 단어에서 특수 문자 및 불필요한 공백 제거
          var word = wordElement.innerText.replace(/[^\w\s]/gi, '').trim();
          return word.length > 0 ? word : ''; // 빈 문자열인지 확인
        } else {
          return ''; // 단어를 찾지 못하면 빈 문자열 반환
        }
      })();
    ''').then((result) {
      print('Searched word: $result');
      if (result.isNotEmpty) { // 결과가 빈 문자열이 아닌 경우에만 처리
        _fetchMeaning(result);
      }
    });
  }

  void _fetchMeaning(String word) {
    _controller.runJavascriptReturningResult('''
      (function() {
        var meaningElements = document.querySelectorAll('.entry_mean_item .meaning');
        if (meaningElements.length > 0) {
          var meanings = Array.from(meaningElements)
            .map(function(el) { 
              return el.innerText.replace(/[^\w\s,]/gi, '').trim(); // 뜻에서도 특수문자 제거
            })
            .filter(function(meaning) { return meaning.length > 0; }) // 빈 뜻 필터링
            .join(', ');
          return meanings.length > 0 ? meanings : ''; // 의미가 있으면 반환, 없으면 빈 문자열
        } else {
          return ''; // 뜻을 찾지 못하면 빈 문자열 반환
        }
      })();
    ''').then((meaningResult) {
      print('Meaning found: $meaningResult');
      if (meaningResult.isNotEmpty) { // 결과가 빈 문자열이 아닌 경우에만 처리
        widget.onWordSelected(word, meaningResult);
      }
    });
  }
}
