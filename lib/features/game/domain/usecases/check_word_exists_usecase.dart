import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/game_repository.dart';

/// Params for CheckWordExistsUseCase
class CheckWordExistsParams {
  final String word;
  const CheckWordExistsParams(this.word);
}

/// Use case that checks if a word exists in the valid words list
class CheckWordExistsUseCase extends UseCase<bool, CheckWordExistsParams> {
  final GameRepository repository;

  CheckWordExistsUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(CheckWordExistsParams params) {
    return repository.checkWordExists(params.word);
  }
}
