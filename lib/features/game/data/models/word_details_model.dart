import '../../domain/entities/word_details_entity.dart';

class WordDetailsModel extends WordDetailsEntity {
  const WordDetailsModel({
    required super.word,
    required super.translation,
    required super.emoji,
    required super.imageQuery,
  });

  factory WordDetailsModel.fromJson(Map<String, dynamic> json) {
    return WordDetailsModel(
      word: json['word'] as String,
      translation: json['translation'] as String,
      emoji: json['emoji'] as String,
      imageQuery: json['imageQuery'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'translation': translation,
      'emoji': emoji,
      'imageQuery': imageQuery,
    };
  }
}
