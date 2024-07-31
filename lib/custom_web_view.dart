//page3

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CustomWebView extends StatefulWidget {
  const CustomWebView({super.key});

  @override
  _CustomWebViewState createState() => _CustomWebViewState();
}

class _CustomWebViewState extends State<CustomWebView> {
  late WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: 'https://en.dict.naver.com/#/main', // Updated URL
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) {
        _controller = webViewController;
      },
    );
  }
}
