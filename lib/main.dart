import 'package:flutter/material.dart';
import 'main_screen.dart';

void main() {
  runApp(VocabularyApp());
}

class VocabularyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainScreen(),
    );
  }
}
