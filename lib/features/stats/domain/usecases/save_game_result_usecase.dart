import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/stats_repository.dart';

/// Parameters for SaveGameResultUseCase
class SaveGameResultParams extends Equatable {
  final bool won;
  final int attemptsUsed;

  const SaveGameResultParams({required this.won, required this.attemptsUsed});

  @override
  List<Object?> get props => [won, attemptsUsed];
}

/// Use case for saving a game result to persistent storage
class SaveGameResultUseCase extends UseCase<void, SaveGameResultParams> {
  final StatsRepository repository;

  SaveGameResultUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveGameResultParams params) {
    return repository.saveGameResult(
      won: params.won,
      attemptsUsed: params.attemptsUsed,
    );
  }
}
