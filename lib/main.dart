import 'package:flutter/material.dart';
import 'main_screen.dart'; // MainScreen import 추가

void main() {
  runApp(VocabularyApp());
}

class VocabularyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainScreen(), // MainScreen을 올바르게 참조
    );
  }
}
