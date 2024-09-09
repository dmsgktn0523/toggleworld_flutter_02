import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CustomWebView extends StatefulWidget {
  final String? initialSearchWord; // 초기 검색어
  final Function(String, String) onWordSelected; // 단어 선택 시 콜백 함수

  const CustomWebView({Key? key, required this.onWordSelected, this.initialSearchWord}) : super(key: key);

  @override
  _CustomWebViewState createState() => _CustomWebViewState();
}

class _CustomWebViewState extends State<CustomWebView> {
  late WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: 'https://en.dict.naver.com/#/main', // 네이버 영어 사전 URL
      javascriptMode: JavascriptMode.unrestricted, // JavaScript 허용 모드
      onWebViewCreated: (WebViewController webViewController) {
        _controller = webViewController;
        // 초기 검색어가 있을 경우, 해당 단어로 검색 수행
        if (widget.initialSearchWord != null && widget.initialSearchWord!.isNotEmpty) {
          _searchWord(widget.initialSearchWord!);
        }
      },
      onPageFinished: (String url) {
        // 페이지 로드 완료 후, 검색된 단어 가져오기
        _fetchSearchedWord();
      },
    );
  }

  // 단어를 검색창에 입력하고 검색 버튼을 누르는 함수
  void _searchWord(String word) {
    _controller.runJavascript('''
      document.querySelector('input[name="search"]').value = '$word'; // 검색창에 단어 입력
      document.querySelector('form').submit(); // 폼 제출로 검색 수행
    ''');
  }

  // 페이지에서 검색된 단어를 가져오는 함수
  void _fetchSearchedWord() {
    _controller.runJavascriptReturningResult('''
      (function() {
        var wordElement = document.querySelector('.entry_title strong.word'); // 검색된 단어 요소 찾기
        if (wordElement) {
          var word = wordElement.innerText.replace(/[^\w\s]/gi, '').trim(); // 특수 문자 제거 및 정리
          return word.length > 0 ? word : ''; // 단어가 있으면 반환, 없으면 빈 문자열 반환
        } else {
          return ''; // 단어를 찾지 못하면 빈 문자열 반환
        }
      })();
    ''').then((result) {
      print('Searched word: $result');
      if (result.isNotEmpty) {
        _fetchMeaning(result); // 검색된 단어가 있을 경우, 해당 단어의 의미 가져오기
      }
    });
  }

  // 검색된 단어의 의미를 가져오는 함수
  void _fetchMeaning(String word) {
    _controller.runJavascriptReturningResult('''
      (function() {
        var meaningElements = document.querySelectorAll('.entry_mean_item .meaning'); // 단어 의미 요소 찾기
        if (meaningElements.length > 0) {
          var meanings = Array.from(meaningElements)
            .map(function(el) { 
              return el.innerText.replace(/[^\w\s,]/gi, '').trim(); // 의미에서 특수 문자 제거
            })
            .filter(function(meaning) { return meaning.length > 0; }) // 빈 의미 필터링
            .join(', ');
          return meanings.length > 0 ? meanings : ''; // 의미가 있으면 반환, 없으면 빈 문자열 반환
        } else {
          return ''; // 의미를 찾지 못하면 빈 문자열 반환
        }
      })();
    ''').then((meaningResult) {
      print('Meaning found: $meaningResult');
      if (meaningResult.isNotEmpty) {
        widget.onWordSelected(word, meaningResult); // 단어와 의미를 콜백 함수로 전달
      }
    });
  }
}
