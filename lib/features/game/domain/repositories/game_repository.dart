import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/guess_entity.dart';
import '../entities/word_details_entity.dart';

/// Abstract game repository
abstract class GameRepository {
  /// Returns the daily word based on the current date
  Future<Either<Failure, String>> getDailyWord();

  /// Returns a random word (used when restarting the game)
  Future<Either<Failure, String>> getRandomWord();

  /// Checks if a word exists in the valid words list
  Future<Either<Failure, bool>> checkWordExists(String word);

  /// Retrieves extra details for a given word
  Future<Either<Failure, WordDetailsEntity>> getWordDetails(String word);

  /// Validates a guess against the target word and returns evaluated letters
  Future<Either<Failure, GuessEntity>> validateGuess({
    required String guess,
    required String targetWord,
  });
}
