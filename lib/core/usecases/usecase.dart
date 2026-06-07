import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

/// Abstract UseCase base class
/// [T] — return type, [Params] — input parameters
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Used when a use case requires no parameters
class NoParams {
  const NoParams();
}
