import 'package:equatable/equatable.dart';

class WordDetailsEntity extends Equatable {
  final String word;
  final String translation;
  final String emoji;
  final String imageQuery;

  const WordDetailsEntity({
    required this.word,
    required this.translation,
    required this.emoji,
    required this.imageQuery,
  });

  @override
  List<Object?> get props => [word, translation, emoji, imageQuery];
}
