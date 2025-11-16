// provider/flash_card_provider.dart
import 'package:codealpha_flashcardquizapp/storage/storage.dart';
import 'package:flutter/material.dart';
import '../model/flash_card.dart';

class FlashCardProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<FlashCard> _flashCards = [];
  int _currentIndex = 0;
  bool _showAnswer = false;
  bool _isLoading = true;

  // Getters
  List<FlashCard> get flashcards => _flashCards;
  int get currentIndex => _currentIndex;
  bool get showAnswer => _showAnswer;
  bool get isLoading => _isLoading;

  FlashCard? get currentCard {
    if (_flashCards.isEmpty) return null;
    return _flashCards[_currentIndex];
  }

  int get totalCard => _flashCards.length;

  bool get goToNext {
    return _currentIndex < _flashCards.length - 1;
  }

  bool get goToPrevious {
    return _currentIndex > 0;
  }

  // Initialize and load data
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _flashCards = await _storageService.loadFlashCards();
      _currentIndex = 0;
      _showAnswer = false;
    } catch (e) {
      print('Error initializing flashcards: $e');
      // Use default cards if loading fails
      _flashCards = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Save data after any change
  Future<void> _saveData() async {
    try {
      await _storageService.saveFlashcards(_flashCards);
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  void toggleAnswer() {
    _showAnswer = !_showAnswer;
    notifyListeners();
  }

  void nextCard() {
    if (goToNext) {
      _currentIndex++;
      _showAnswer = false;
      notifyListeners();
    }
  }

  void previousCard() {
    if (goToPrevious) {
      _currentIndex--;
      _showAnswer = false;
      notifyListeners();
    }
  }

  Future<void> addFlashCard(String question, String answer) async {
    final newCard = FlashCard(
      question: question,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      answer: answer,
    );
    _flashCards.add(newCard);
    _currentIndex = _flashCards.length - 1;
    _showAnswer = false;
    notifyListeners();

    // Save to storage
    await _saveData();
  }

  Future<void> editFlashCard(String id, String question, String answer) async {
    final index = _flashCards.indexWhere((card) => card.id == id);
    if (index != -1) {
      _flashCards[index] = FlashCard(
        id: id,
        question: question,
        answer: answer,
      );
      _showAnswer = false;
      notifyListeners();

      // Save to storage
      await _saveData();
    }
  }

  Future<void> deleteFlashCard(String id) async {
    final index = _flashCards.indexWhere((card) => card.id == id);
    if (index != -1) {
      _flashCards.removeAt(index);

      // Handle edge cases after deletion
      if (_flashCards.isEmpty) {
        _currentIndex = 0;
      } else if (_currentIndex >= _flashCards.length) {
        _currentIndex = _flashCards.length - 1;
      }

      _showAnswer = false;
      notifyListeners();

      // Save to storage
      await _saveData();
    }
  }

  // Reset to first card
  void reset() {
    _currentIndex = 0;
    _showAnswer = false;
    notifyListeners();
  }

  // Clear all flashcards
  Future<void> clearAllFlashcards() async {
    _flashCards.clear();
    _currentIndex = 0;
    _showAnswer = false;
    notifyListeners();

    await _storageService.clearFlashcards();
  }

  // Reset to default flashcards
  Future<void> resetToDefault() async {
    await _storageService.clearFlashcards();
    await initialize();
  }
}
