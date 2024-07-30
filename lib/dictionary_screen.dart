import 'package:flutter/material.dart';
import 'custom_web_view.dart';

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
      body: const CustomWebView(),
    );
  }
}
