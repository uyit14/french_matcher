import 'dart:math';

import 'package:flutter/material.dart';

import '../models/word_pair.dart';
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<String> englishWords;
  late List<String> frenchWords;
  Map<String, String> selectedPairs = {};
  String? selectedEnglish;
  bool graded = false;
  double accuracy = 0;

  @override
  void initState() {
    super.initState();
    _shuffleWords();
  }

  void _shuffleWords() {
    englishWords = allPairs.map((e) => e.english).toList();
    frenchWords = allPairs.map((e) => e.french).toList();
    englishWords.shuffle(Random());
    frenchWords.shuffle(Random());
    selectedPairs.clear();
    selectedEnglish = null;
    graded = false;
    accuracy = 0;
  }

  bool isCorrectMatch(String english, String french) {
    return allPairs.any((pair) => pair.english == english && pair.french == french);
  }

  void _grade() {
    int correct = 0;
    for (var pair in selectedPairs.entries) {
      if (isCorrectMatch(pair.key, pair.value)) {
        correct++;
      }
    }
    setState(() {
      graded = true;
      accuracy = (correct / allPairs.length) * 100;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Graded! Your accuracy: ${accuracy.toStringAsFixed(2)}%'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  void _reset() {
    setState(() {
      _shuffleWords();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("French Matcher"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      backgroundColor: Colors.lightBlue[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (graded)
              Text(
                "Accuracy: ${accuracy.toStringAsFixed(2)}%",
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            const SizedBox(height: 8),

            if (selectedEnglish != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  "Step 2: Select French for \"${selectedEnglish!}\"",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),

            if (selectedPairs.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 6,
                        offset: const Offset(0, 3))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your Matches:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    for (var entry in selectedPairs.entries)
                      Row(
                        children: [
                          Text(
                            "${entry.key} → ${entry.value}",
                            style: TextStyle(
                              fontSize: 14,
                              color: graded
                                  ? (isCorrectMatch(entry.key, entry.value)
                                  ? Colors.green
                                  : Colors.red)
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      )
                  ],
                ),
              ),

            Expanded(
              child: Row(
                children: [
                  /// English Words List
                  Expanded(
                    child: ListView.builder(
                      itemCount: englishWords.length,
                      itemBuilder: (context, index) {
                        final word = englishWords[index];
                        return Card(
                          color: selectedEnglish == word ? Colors.blue[100] : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(word),
                            onTap: () {
                              setState(() {
                                selectedEnglish = word;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const VerticalDivider(width: 30),

                  /// French Words List
                  Expanded(
                    child: ListView.builder(
                      itemCount: frenchWords.length,
                      itemBuilder: (context, index) {
                        final word = frenchWords[index];

                        String? englishKey = selectedPairs.entries
                            .firstWhere(
                              (e) => e.value == word,
                          orElse: () => const MapEntry('', ''),
                        )
                            .key;

                        Color? tileColor;
                        if (graded && englishKey.isNotEmpty) {
                          tileColor = isCorrectMatch(englishKey, word)
                              ? Colors.green[100]
                              : Colors.red[100];
                        } else if (selectedPairs[selectedEnglish] == word) {
                          tileColor = Colors.green[50];
                        }

                        return Card(
                          color: tileColor ?? Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(word),
                            onTap: () {
                              if (selectedEnglish != null &&
                                  !selectedPairs.containsValue(word)) {
                                setState(() {
                                  selectedPairs[selectedEnglish!] = word;
                                  selectedEnglish = null;
                                });
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: graded ? _reset : _grade,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                backgroundColor: graded ? Colors.green : Colors.blueAccent,
              ),
              child: Text(
                graded ? "GO AGAIN!" : "GRADE",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}