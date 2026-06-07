import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/guess_entity.dart';
import '../repositories/game_repository.dart';

/// Parameters for ValidateGuessUseCase
class ValidateGuessParams extends Equatable {
  final String guess;
  final String targetWord;

  const ValidateGuessParams({required this.guess, required this.targetWord});

  @override
  List<Object?> get props => [guess, targetWord];
}

/// Use case that validates a guess against the target word.
///
/// Implements the exact Wordle algorithm:
/// 1. First pass: mark all CORRECT (right letter, right position) → green
/// 2. Second pass: mark PRESENT (letter exists in remaining unmatched target letters) → yellow
/// 3. Everything else → ABSENT → grey
///
/// Duplicate letters are handled correctly.
class ValidateGuessUseCase extends UseCase<GuessEntity, ValidateGuessParams> {
  final GameRepository repository;

  ValidateGuessUseCase(this.repository);

  @override
  Future<Either<Failure, GuessEntity>> call(ValidateGuessParams params) {
    return repository.validateGuess(
      guess: params.guess,
      targetWord: params.targetWord,
    );
  }
}
