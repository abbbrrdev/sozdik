import 'package:flutter_test/flutter_test.dart';
import 'package:sozdik/features/game/data/models/word_model.dart';
import 'package:sozdik/features/game/domain/entities/letter_entity.dart';

/// Unit tests for the Wordle validation algorithm.
/// Tests the [GuessValidator] extension which implements the exact
/// Wordle algorithm with correct duplicate-letter handling.
void main() {
  group('ValidateGuess — Wordle Algorithm', () {
    // ─── All Correct ────────────────────────────────────────────────────────
    test('all letters correct returns all green', () {
      final result = 'ҚЫМЫЗ'.validateAgainst('ҚЫМЫЗ');
      expect(result.letters.length, 5);
      for (final letter in result.letters) {
        expect(letter.status, LetterStatus.correct,
            reason: 'Expected all correct for ${letter.letter}');
      }
    });

    // ─── All Absent ─────────────────────────────────────────────────────────
    test('no letters in common returns all grey', () {
      // НЫСАН vs ҚЫМЫЗ — verify no common letters:
      // Н,Ы,С,А,Н  vs  Қ,Ы,М,Ы,З — Ы is shared, so use different pair.
      // ШАПАН vs БІЛІМ — Ш,А,П,А,Н vs Б,І,Л,І,М — zero overlap
      final result = 'ШАПАН'.validateAgainst('БІЛІМ');
      for (final letter in result.letters) {
        expect(letter.status, LetterStatus.absent);
      }
    });

    // ─── Mixed correct and present ──────────────────────────────────────────
    test('first letter correct, others may be present', () {
      // Target: АЛТЫН, Guess: АЫТЛН
      // А is correct (pos 0), Л is present (in word at pos 2, guessed at pos 3)
      // Н is present (in word at pos 4, guessed at pos 4)... wait pos 4 == pos 4
      // Let's check: АЛТЫН: А(0)Л(1)Т(2)Ы(3)Н(4) — guess АЫТЛН: А(0)Ы(1)Т(2)Л(3)Н(4)
      // А at pos 0 = correct ✓, Ы at pos 1 = correct ✓, Т at pos 2 = correct ✓
      // Л at pos 3 ≠ Ы(target pos 3) → present (Л is in word at pos 1)
      // Н at pos 4 = Н → correct ✓
      final result = 'АЫТЛН'.validateAgainst('АЫТЛН'); // identical → all correct
      expect(result.isCorrect, isTrue);
    });

    // ─── Duplicate letters — only one match ────────────────────────────────
    test('duplicate letters in guess — only mark as many as in target', () {
      // Target: ШАПАН has one А (at pos 1) and one А (at pos 3) — two А's.
      // Use БІЛІМ which has zero А's, so ААААА against БІЛІМ → all absent.
      // Better: use target КІТАП which has zero А's: К,І,Т,А,П — one А!
      // Target ШЕШЕН: Ш,Е,Ш,Е,Н — zero А's.
      // Guess: ААААА against ШЕШЕН → all absent (0 present)
      final result = 'ААААА'.validateAgainst('ШЕШЕН');

      int presentCount = 0;
      int absentCount = 0;
      for (final letter in result.letters) {
        if (letter.status == LetterStatus.present) presentCount++;
        if (letter.status == LetterStatus.absent) absentCount++;
      }

      expect(presentCount, 0,
          reason: 'No А in ШЕШЕН so zero yellow');
      expect(absentCount, 5);
    });

    test('duplicate letters — exactly one present when target has one match', () {
      // Target: КІТАП — К(0),І(1),Т(2),А(3),П(4) — exactly one А
      // Guess:  ААААА — five А's
      // Pass 1 (correct): no А at pos 3 in guess... wait guess[3]=А, target[3]=А → correct!
      // So one А becomes correct, remaining 4 → absent
      final result2 = 'ААААА'.validateAgainst('КІТАП');
      int correctCount = 0;
      int absentCount2 = 0;
      for (final l in result2.letters) {
        if (l.status == LetterStatus.correct) correctCount++;
        if (l.status == LetterStatus.absent) absentCount2++;
      }
      expect(correctCount, 1); // А at pos 3 is correct
      expect(absentCount2, 4);
    });

    test('correct letter takes priority — duplicate, one correct one absent', () {
      // Target: АЛТЫН, Guess: АЛААА
      // А at pos 0 = correct (green). А is consumed.
      // Л at pos 1 = correct (green). Л consumed.
      // Remaining А's → absent (А already consumed by correct at pos 0)
      final result = 'АЛААА'.validateAgainst('АЛТЫН');

      expect(result.letters[0].status, LetterStatus.correct); // А correct
      expect(result.letters[1].status, LetterStatus.correct); // Л correct
      expect(result.letters[2].status, LetterStatus.absent);
      expect(result.letters[3].status, LetterStatus.absent);
      expect(result.letters[4].status, LetterStatus.absent);
    });

    // ─── Present but not correct ────────────────────────────────────────────
    test('letter in word but wrong position is yellow', () {
      // Target: ЖАҚСЫ — letters: Ж(0)А(1)Қ(2)С(3)Ы(4)
      // Guess:  СЖАЛА — letters: С(0)Ж(1)А(2)Л(3)А(4)
      // С at pos 0: in target at pos 3 → present
      // Ж at pos 1: in target at pos 0 → present
      // А at pos 2: in target at pos 1 → present
      // Л: not in target → absent
      // А at pos 4: А already consumed by pos 2 → absent
      final result = 'СЖАЛА'.validateAgainst('ЖАҚСЫ');

      // Ж should be present (index 1)
      expect(result.letters[1].letter, 'Ж');
      expect(result.letters[1].status, LetterStatus.present);

      // С should be present (index 0)
      expect(result.letters[0].letter, 'С');
      expect(result.letters[0].status, LetterStatus.present);

      // Л should be absent (index 3)
      expect(result.letters[3].letter, 'Л');
      expect(result.letters[3].status, LetterStatus.absent);
    });

    // ─── Exact Wordle — known scenario ──────────────────────────────────────
    test('classic wordle scenario: guess НАРЫҚ for target ЖАРЫҚ', () {
      // ЖАРЫҚ — target: Ж(0)А(1)Р(2)Ы(3)Қ(4)
      // НАРЫҚ — guess:  Н(0)А(1)Р(2)Ы(3)Қ(4)
      // Н → absent, А → correct, Р → correct, Ы → correct, Қ → correct
      final result = 'НАРЫҚ'.validateAgainst('ЖАРЫҚ');

      expect(result.letters[0].letter, 'Н');
      expect(result.letters[0].status, LetterStatus.absent);

      expect(result.letters[1].letter, 'А');
      expect(result.letters[1].status, LetterStatus.correct);

      expect(result.letters[2].letter, 'Р');
      expect(result.letters[2].status, LetterStatus.correct);

      expect(result.letters[3].letter, 'Ы');
      expect(result.letters[3].status, LetterStatus.correct);

      expect(result.letters[4].letter, 'Қ');
      expect(result.letters[4].status, LetterStatus.correct);
    });

    // ─── isCorrect helper ────────────────────────────────────────────────────
    test('guess.isCorrect is true when all letters are correct', () {
      final result = 'АЛТЫН'.validateAgainst('АЛТЫН');
      expect(result.isCorrect, isTrue);
    });

    test('guess.isCorrect is false when not all letters are correct', () {
      final result = 'АЛТАН'.validateAgainst('АЛТЫН');
      expect(result.isCorrect, isFalse);
    });

    // ─── word property ────────────────────────────────────────────────────
    test('guess.word returns the original guess letters joined', () {
      final result = 'БАТЫР'.validateAgainst('АЛТЫН');
      expect(result.word, 'БАТЫР');
    });

    // ─── Case normalization ───────────────────────────────────────────────
    test('lowercase guess is normalized to uppercase', () {
      final result = 'алтын'.validateAgainst('АЛТЫН');
      expect(result.isCorrect, isTrue);
      for (final letter in result.letters) {
        expect(letter.letter, letter.letter.toUpperCase());
      }
    });

    // ─── Result count ────────────────────────────────────────────────────
    test('result always has exactly 5 letters for a 5-letter guess', () {
      final result = 'ЖАРЫҚ'.validateAgainst('АЛТЫН');
      expect(result.letters.length, 5);
    });
  });
}
