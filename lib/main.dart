import 'package:flutter/material.dart';
import 'package:french_matcher/screens/welcome_screen.dart';

void main() => runApp(const WordMemoryApp());

class WordMemoryApp extends StatelessWidget {
  const WordMemoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}
