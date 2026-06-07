import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/stats_entity.dart';

/// Abstract stats repository
abstract class StatsRepository {
  Future<Either<Failure, StatsEntity>> getStats();
  Future<Either<Failure, void>> saveGameResult({
    required bool won,
    required int attemptsUsed,
  });
}
