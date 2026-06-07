import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/game_repository.dart';

/// Use case for getting the daily word
class GetDailyWordUseCase extends UseCase<String, NoParams> {
  final GameRepository repository;

  GetDailyWordUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(NoParams params) {
    return repository.getDailyWord();
  }
}
