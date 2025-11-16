import 'dart:convert';

import 'package:codealpha_flashcardquizapp/model/flash_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _flashCardskey = 'FlashCard';

  //Save flashCrads to local storage
  Future<bool> saveFlashcards(List<FlashCard> flashcards) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Convert flashcards to JSON
      final List<Map<String, dynamic>> jsonList = flashcards
          .map((card) => card.toJson())
          .toList();

      // Save as JSON string
      final String jsonString = jsonEncode(jsonList);
      return await prefs.setString(_flashCardskey, jsonString);
    } catch (e) {
      print('Error saving flashcards: $e');
      return false;
    }
  }

  Future<List<FlashCard>> loadFlashCards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_flashCardskey);
      if (jsonString == null) {
        return _getDefaultFlashcards();
      }
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => FlashCard.fromJson(json)).toList();
    } catch (e) {
      print('Error saving flashcards: $e');
      return _getDefaultFlashcards();
    }
  }

  Future<bool> clearFlashcards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_flashCardskey);
    } catch (e) {
      print('Error clearing flashcards: $e');
      return false;
    }
  }

  Future<bool> hasSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_flashCardskey);
    } catch (e) {
      print('Error checking saved data: $e');
      return false;
    }
  }

  List<FlashCard> _getDefaultFlashcards() {
    return [
      FlashCard(
        id: '1',
        question: 'Which city is the capital of France?',
        answer: 'Paris',
      ),
      FlashCard(
        id: '2',
        question: 'Which city is the capital of Germany?',
        answer: 'Berlin',
      ),
      FlashCard(
        id: '3',
        question: 'Which city is the capital of Spain?',
        answer: 'Madrid',
      ),
    ];
  }
}
