import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

/*
  Note: the tiles will bug out if you tap numbers too fast or too slow sometimes
*/

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CardProvider(), // Provider to change states
      child: MaterialApp(
        title: 'Card Matching Game',
        home: GridApp(),
      ),
    );
  }
}

// Card Object to store states/values
class CardValues {
  final int value;
  bool faceUp = false;
  bool matched = false;
  CardValues(this.value);
}

class GridApp extends StatelessWidget {
  const GridApp({super.key});

  @override
  Widget build(BuildContext context) {
    final cardProvider = Provider.of<CardProvider>(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Card Matching Game')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, // 4 columns
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: cardProvider.cards.length,
        itemBuilder: (context, index) {
          return DispCards(card: cardProvider.cards[index]); // Display each card
        },
      ),
    );
  }
}

// Displays cards
class DispCards extends StatelessWidget {
  final CardValues card;
  
  const DispCards({required this.card});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Provider.of<CardProvider>(context, listen: false).flipCard(card),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: card.faceUp ? const Color.fromARGB(178, 89, 16, 184) : Colors.grey, // Change color when flipped
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: card.faceUp ? Text(
            '${card.value}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ) : Container(),
        ),
      ),
    );
  }
}

class CardProvider extends ChangeNotifier {
  List<CardValues> cards = [];
  CardValues? firstSelected;

  CardProvider() {
    _startGame();
  }

  // creates cards
  void _startGame() {
    List<int> values = List.generate(8, (index) => index);
    values.addAll(List.from(values));
    values.shuffle(Random());
    cards = values.map((value) => CardValues(value)).toList();
    notifyListeners();
  }

  void flipCard(CardValues card) {
    if (card.matched || card.faceUp) return; // Ignore already matched or flipped cards

    card.faceUp = true;
    notifyListeners();

    if (firstSelected == null) {
      firstSelected = card; // Store first card
    } else {
      Future.delayed(const Duration(seconds: 1), () {
        if (firstSelected!.value == card.value) {
          card.matched = true;
          firstSelected!.matched = true;
        } else {
          card.faceUp = false;
          firstSelected!.faceUp = false;
        }
        firstSelected = null; // Reset selected
        notifyListeners();
      });
    }
  }
}