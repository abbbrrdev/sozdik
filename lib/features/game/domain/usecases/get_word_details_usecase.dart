import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/word_details_entity.dart';
import '../repositories/game_repository.dart';

class GetWordDetailsUseCase extends UseCase<WordDetailsEntity, String> {
  final GameRepository repository;

  GetWordDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, WordDetailsEntity>> call(String word) {
    return repository.getWordDetails(word);
  }
}
