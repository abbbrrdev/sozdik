import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/guess_entity.dart';
import '../../domain/entities/word_details_entity.dart';
import '../../domain/repositories/game_repository.dart';
import '../datasources/word_local_datasource.dart';
import '../models/word_model.dart';

/// Implementation of [GameRepository] using the local word data source.
class GameRepositoryImpl implements GameRepository {
  final WordLocalDatasource datasource;

  GameRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, String>> getDailyWord() async {
    try {
      final word = await datasource.getDailyWord();
      return Right(word);
    } catch (e) {
      return const Left(LocalDataFailure('Failed to load daily word'));
    }
  }

  @override
  Future<Either<Failure, String>> getRandomWord() async {
    try {
      final word = await datasource.getRandomWord();
      return Right(word);
    } catch (e) {
      return const Left(LocalDataFailure('Failed to load random word'));
    }
  }

  @override
  Future<Either<Failure, bool>> checkWordExists(String word) async {
    try {
      final exists = await datasource.wordExists(word);
      return Right(exists);
    } catch (e) {
      return const Left(LocalDataFailure('Failed to check word'));
    }
  }

  @override
  Future<Either<Failure, WordDetailsEntity>> getWordDetails(String word) async {
    try {
      final details = await datasource.getWordDetails(word);
      return Right(details);
    } catch (e) {
      return const Left(LocalDataFailure('Failed to fetch word details'));
    }
  }

  @override
  Future<Either<Failure, GuessEntity>> validateGuess({
    required String guess,
    required String targetWord,
  }) async {
    try {
      // NOTE: validateAgainst is extension on String from word_model.dart, so we need to import it
      final result = guess.validateAgainst(targetWord);
      return Right(result);
    } catch (e) {
      return const Left(LocalDataFailure('Failed to validate guess'));
    }
  }
}
