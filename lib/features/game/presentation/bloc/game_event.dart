import 'package:equatable/equatable.dart';

/// All events that the GameBloc can handle
abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

/// Start or initialize the game (loads daily word)
class GameStarted extends GameEvent {
  const GameStarted();
}

/// A letter was tapped on the on-screen keyboard
class LetterAdded extends GameEvent {
  final String letter;

  const LetterAdded(this.letter);

  @override
  List<Object?> get props => [letter];
}

/// Delete / backspace was pressed
class LetterDeleted extends GameEvent {
  const LetterDeleted();
}

/// Enter / submit button was pressed
class GuessSubmitted extends GameEvent {
  const GuessSubmitted();
}

/// Clear invalid word shake animation flag
class InvalidWordCleared extends GameEvent {
  const InvalidWordCleared();
}

/// Reset to start a new game
class GameReset extends GameEvent {
  const GameReset();
}
