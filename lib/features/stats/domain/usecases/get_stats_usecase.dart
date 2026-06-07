import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/stats_entity.dart';
import '../repositories/stats_repository.dart';

/// Use case for retrieving game statistics
class GetStatsUseCase extends UseCase<StatsEntity, NoParams> {
  final StatsRepository repository;

  GetStatsUseCase(this.repository);

  @override
  Future<Either<Failure, StatsEntity>> call(NoParams params) {
    return repository.getStats();
  }
}
