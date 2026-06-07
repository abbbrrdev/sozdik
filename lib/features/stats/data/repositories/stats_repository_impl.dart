import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/stats_entity.dart';
import '../../domain/repositories/stats_repository.dart';
import '../datasources/stats_local_datasource.dart';

/// Implementation of [StatsRepository]
class StatsRepositoryImpl implements StatsRepository {
  final StatsLocalDatasource datasource;

  StatsRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, StatsEntity>> getStats() async {
    try {
      final stats = datasource.getStats();
      return Right(stats);
    } catch (e) {
      return const Left(LocalDataFailure('Failed to load stats'));
    }
  }

  @override
  Future<Either<Failure, void>> saveGameResult({
    required bool won,
    required int attemptsUsed,
  }) async {
    try {
      await datasource.saveGameResult(won: won, attemptsUsed: attemptsUsed);
      return const Right(null);
    } catch (e) {
      return const Left(LocalDataFailure('Failed to save game result'));
    }
  }
}
