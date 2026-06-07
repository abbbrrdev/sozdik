import 'package:equatable/equatable.dart';
import 'letter_entity.dart';

/// Represents a complete submitted guess (a row on the board)
class GuessEntity extends Equatable {
  final List<LetterEntity> letters;

  const GuessEntity({required this.letters});

  /// Whether this guess is entirely correct (all green)
  bool get isCorrect => letters.every((l) => l.status == LetterStatus.correct);

  /// The word formed by this guess
  String get word => letters.map((l) => l.letter).join();

  @override
  List<Object?> get props => [letters];
}
