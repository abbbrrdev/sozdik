/// Base failure class for the application
abstract class Failure {
  final String message;
  const Failure(this.message);
}

/// Failure from local data source operations
class LocalDataFailure extends Failure {
  const LocalDataFailure(super.message);
}

/// Failure when a word is not found in the word list
class WordNotFoundFailure extends Failure {
  const WordNotFoundFailure() : super('Word not found in word list');
}

/// Failure for invalid word length
class InvalidWordLengthFailure extends Failure {
  const InvalidWordLengthFailure() : super('Word length is invalid');
}

/// Failure for unexpected errors
class UnexpectedFailure extends Failure {
  const UnexpectedFailure() : super('An unexpected error occurred');
}
