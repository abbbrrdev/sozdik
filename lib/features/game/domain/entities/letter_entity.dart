import 'package:equatable/equatable.dart';

/// Represents the status of a single letter after evaluation
enum LetterStatus {
  /// Not guessed yet — empty tile
  initial,

  /// Letter is not in the target word — grey
  absent,

  /// Letter is in the word but in the wrong position — yellow
  present,

  /// Letter is in the correct position — green
  correct,
}

/// A single letter with its evaluated status
class LetterEntity extends Equatable {
  final String letter;
  final LetterStatus status;

  const LetterEntity({
    required this.letter,
    required this.status,
  });

  LetterEntity copyWith({String? letter, LetterStatus? status}) {
    return LetterEntity(
      letter: letter ?? this.letter,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [letter, status];
}
