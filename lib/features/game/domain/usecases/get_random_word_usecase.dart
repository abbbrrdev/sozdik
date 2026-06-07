import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/game_repository.dart';

/// Use case for getting a random word (used on game reset / play again)
class GetRandomWordUseCase extends UseCase<String, NoParams> {
  final GameRepository repository;

  GetRandomWordUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(NoParams params) {
    return repository.getRandomWord();
  }
}
