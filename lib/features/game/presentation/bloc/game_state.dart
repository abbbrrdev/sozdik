import 'package:equatable/equatable.dart';
import '../../domain/entities/guess_entity.dart';
import '../../domain/entities/letter_entity.dart';
import '../../domain/entities/word_details_entity.dart';

/// All possible states of the game
abstract class GameState extends Equatable {
  const GameState();

  @override
  List<Object?> get props => [];
}

/// Before the game has loaded
class GameInitial extends GameState {
  const GameInitial();
}

/// Loading the daily word
class GameLoading extends GameState {
  const GameLoading();
}

/// Active game in progress
class GameInProgress extends GameState {
  final String targetWord;

  /// All completed (submitted) rows
  final List<GuessEntity> completedGuesses;

  /// Letters typed in the current row (not yet submitted)
  final List<String> currentInput;

  /// Keyboard key → best status achieved for that letter
  final Map<String, LetterStatus> keyboardStatus;

  /// Number of attempts remaining (starts at maxAttempts, decrements each turn)
  final int attemptsLeft;

  /// Whether the current input is an invalid word (triggers shake)
  final bool isInvalidWord;

  /// Toast message to briefly display (null if none)
  final String? toastMessage;

  const GameInProgress({
    required this.targetWord,
    required this.completedGuesses,
    required this.currentInput,
    required this.keyboardStatus,
    required this.attemptsLeft,
    this.isInvalidWord = false,
    this.toastMessage,
  });

  GameInProgress copyWith({
    String? targetWord,
    List<GuessEntity>? completedGuesses,
    List<String>? currentInput,
    Map<String, LetterStatus>? keyboardStatus,
    int? attemptsLeft,
    bool? isInvalidWord,
    String? toastMessage,
    bool clearToast = false,
  }) {
    return GameInProgress(
      targetWord: targetWord ?? this.targetWord,
      completedGuesses: completedGuesses ?? this.completedGuesses,
      currentInput: currentInput ?? this.currentInput,
      keyboardStatus: keyboardStatus ?? this.keyboardStatus,
      attemptsLeft: attemptsLeft ?? this.attemptsLeft,
      isInvalidWord: isInvalidWord ?? this.isInvalidWord,
      toastMessage: clearToast ? null : toastMessage ?? this.toastMessage,
    );
  }

  @override
  List<Object?> get props => [
        targetWord,
        completedGuesses,
        currentInput,
        keyboardStatus,
        attemptsLeft,
        isInvalidWord,
        toastMessage,
      ];
}

/// Player guessed the word correctly
class GameWon extends GameState {
  final String targetWord;
  final int attemptsUsed;
  final List<GuessEntity> guesses;
  final WordDetailsEntity? wordDetails;

  const GameWon({
    required this.targetWord,
    required this.attemptsUsed,
    required this.guesses,
    this.wordDetails,
  });

  @override
  List<Object?> get props => [targetWord, attemptsUsed, guesses, wordDetails];
}

/// Player used all attempts without guessing correctly
class GameLost extends GameState {
  final String targetWord;
  final List<GuessEntity> guesses;
  final WordDetailsEntity? wordDetails;

  const GameLost({
    required this.targetWord,
    required this.guesses,
    this.wordDetails,
  });

  @override
  List<Object?> get props => [targetWord, guesses, wordDetails];
}

/// An error occurred
class GameError extends GameState {
  final String message;

  const GameError(this.message);

  @override
  List<Object?> get props => [message];
}
