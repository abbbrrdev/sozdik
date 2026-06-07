import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/word_details_model.dart';

/// Local data source containing the Kazakh word database from JSON.
class WordLocalDatasource {
  List<WordDetailsModel>? _cachedWords;

  /// Loads words from assets if not already cached
  Future<List<WordDetailsModel>> _getWords() async {
    if (_cachedWords != null) return _cachedWords!;
    final jsonStr = await rootBundle.loadString('assets/words.json');
    final List<dynamic> jsonList = jsonDecode(jsonStr);
    _cachedWords = jsonList.map((e) => WordDetailsModel.fromJson(e)).toList();
    return _cachedWords!;
  }

  /// Returns the complete list of valid 5-letter Kazakh words
  Future<List<String>> getWordList() async {
    final words = await _getWords();
    return words.map((w) => w.word).toList();
  }

  /// Returns a daily word based on the day of the year.
  /// Everyone on the same day sees the same word.
  Future<String> getDailyWord() async {
    final words = await _getWords();
    final now = DateTime.now();
    final dayOfYear = _getDayOfYear(now);
    final index = dayOfYear % words.length;
    return words[index].word;
  }

  /// Returns a pseudo-random word using current milliseconds as seed.
  /// Used when the player restarts the game.
  Future<String> getRandomWord() async {
    final words = await _getWords();
    final seed = DateTime.now().millisecondsSinceEpoch;
    final index = seed % words.length;
    return words[index].word;
  }

  /// Checks if a word exists in the valid word list
  Future<bool> wordExists(String word) async {
    final words = await _getWords();
    return words.any((w) => w.word.toUpperCase() == word.toUpperCase());
  }

  /// Retrieves details for a specific word
  Future<WordDetailsModel> getWordDetails(String word) async {
    final words = await _getWords();
    return words.firstWhere(
      (w) => w.word.toUpperCase() == word.toUpperCase(),
      orElse: () => WordDetailsModel(
        word: word,
        translation: '',
        emoji: '❓',
        imageQuery: '',
      ),
    );
  }

  int _getDayOfYear(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    return date.difference(startOfYear).inDays;
  }
}
