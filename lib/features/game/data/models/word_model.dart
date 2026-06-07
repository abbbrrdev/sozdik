import '../../domain/entities/letter_entity.dart';
import '../../domain/entities/guess_entity.dart';

/// Data model for a word — wraps domain entities for data layer
class WordModel {
  final String word;

  const WordModel({required this.word});

  factory WordModel.fromString(String word) => WordModel(word: word.toUpperCase());

  String get normalized => word.toUpperCase();
}

/// Extension to convert a raw guess string + target into a GuessEntity
/// using the exact Wordle validation algorithm.
extension GuessValidator on String {
  GuessEntity validateAgainst(String target) {
    final guess = toUpperCase();
    final targetUpper = target.toUpperCase();

    // Initialize all letters as absent
    final statuses = List<LetterStatus>.filled(
      guess.length,
      LetterStatus.absent,
    );

    // Track which target positions are still "unmatched"
    final targetUnmatched = targetUpper.split('');

    // === PASS 1: Mark CORRECT (green) ===
    for (int i = 0; i < guess.length; i++) {
      if (i < targetUpper.length && guess[i] == targetUpper[i]) {
        statuses[i] = LetterStatus.correct;
        targetUnmatched[i] = ''; // consume this target position
      }
    }

    // === PASS 2: Mark PRESENT (yellow) ===
    for (int i = 0; i < guess.length; i++) {
      if (statuses[i] == LetterStatus.correct) continue;

      final idx = targetUnmatched.indexOf(guess[i]);
      if (idx != -1) {
        statuses[i] = LetterStatus.present;
        targetUnmatched[idx] = ''; // consume so duplicates aren't double-counted
      }
    }

    // Build result
    final letters = <LetterEntity>[];
    for (int i = 0; i < guess.length; i++) {
      letters.add(LetterEntity(letter: guess[i], status: statuses[i]));
    }

    return GuessEntity(letters: letters);
  }
}
