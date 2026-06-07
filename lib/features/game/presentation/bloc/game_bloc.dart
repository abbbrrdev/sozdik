import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/letter_entity.dart';
import '../../domain/usecases/check_word_exists_usecase.dart';
import '../../domain/usecases/get_daily_word_usecase.dart';
import '../../domain/usecases/get_random_word_usecase.dart';
import '../../domain/usecases/get_word_details_usecase.dart';
import '../../domain/usecases/validate_guess_usecase.dart';
import '../../../stats/domain/usecases/save_game_result_usecase.dart';
import 'game_event.dart';
import 'game_state.dart';

/// Main BLoC for the Wordle game
class GameBloc extends Bloc<GameEvent, GameState> {
  final GetDailyWordUseCase getDailyWord;
  final GetRandomWordUseCase getRandomWord;
  final ValidateGuessUseCase validateGuess;
  final CheckWordExistsUseCase checkWordExists;
  final SaveGameResultUseCase saveGameResult;
  final GetWordDetailsUseCase getWordDetails;

  GameBloc({
    required this.getDailyWord,
    required this.getRandomWord,
    required this.validateGuess,
    required this.checkWordExists,
    required this.saveGameResult,
    required this.getWordDetails,
  }) : super(const GameInitial()) {
    on<GameStarted>(_onGameStarted);
    on<LetterAdded>(_onLetterAdded);
    on<LetterDeleted>(_onLetterDeleted);
    on<GuessSubmitted>(_onGuessSubmitted);
    on<InvalidWordCleared>(_onInvalidWordCleared);
    on<GameReset>(_onGameReset);
  }

  /// Load the daily word and transition to in-progress
  Future<void> _onGameStarted(
    GameStarted event,
    Emitter<GameState> emit,
  ) async {
    emit(const GameLoading());

    final result = await getDailyWord(const NoParams());

    result.fold(
      (failure) => emit(GameError(failure.message)),
      (word) => emit(GameInProgress(
        targetWord: word,
        completedGuesses: const [],
        currentInput: const [],
        keyboardStatus: const {},
        attemptsLeft: AppConstants.maxAttempts,
      )),
    );
  }

  /// Add a letter to the current input (max wordLength)
  void _onLetterAdded(LetterAdded event, Emitter<GameState> emit) {
    final state = this.state;
    if (state is! GameInProgress) return;
    if (state.currentInput.length >= AppConstants.wordLength) return;

    emit(state.copyWith(
      currentInput: [...state.currentInput, event.letter.toUpperCase()],
      isInvalidWord: false,
      clearToast: true,
    ));
  }

  /// Remove the last typed letter
  void _onLetterDeleted(LetterDeleted event, Emitter<GameState> emit) {
    final state = this.state;
    if (state is! GameInProgress) return;
    if (state.currentInput.isEmpty) return;

    final newInput = [...state.currentInput];
    newInput.removeLast();

    emit(state.copyWith(
      currentInput: newInput,
      isInvalidWord: false,
      clearToast: true,
    ));
  }

  /// Submit the current guess
  Future<void> _onGuessSubmitted(
    GuessSubmitted event,
    Emitter<GameState> emit,
  ) async {
    final state = this.state;
    if (state is! GameInProgress) return;

    // Check minimum length
    if (state.currentInput.length < AppConstants.wordLength) {
      emit(state.copyWith(
        isInvalidWord: true,
        toastMessage: AppStrings.notEnoughLetters,
      ));
      return;
    }

    final guessWord = state.currentInput.join();

    // Validate word exists in dictionary
    final existsResult = await checkWordExists(CheckWordExistsParams(guessWord));
    final wordExists = existsResult.fold((_) => false, (exists) => exists);

    if (!wordExists) {
      emit(state.copyWith(
        isInvalidWord: true,
        toastMessage: AppStrings.wordNotFound,
        
      ));
      return;
    }

    // Validate the guess
    final validateResult = await validateGuess(
      ValidateGuessParams(guess: guessWord, targetWord: state.targetWord),
    );

    await validateResult.fold(
      (failure) async => emit(GameError(failure.message)),
      (guess) async {
        // Update keyboard status: only upgrade (absent < present < correct)
        final newKeyboardStatus = Map<String, LetterStatus>.from(state.keyboardStatus);
        for (final letter in guess.letters) {
          final current = newKeyboardStatus[letter.letter];
          if (current == null || _statusPriority(letter.status) > _statusPriority(current)) {
            newKeyboardStatus[letter.letter] = letter.status;
          }
        }

        final newGuesses = [...state.completedGuesses, guess];
        final newAttemptsLeft = state.attemptsLeft - 1;

        // Check win
        if (guess.isCorrect) {
          final attemptsUsed = AppConstants.maxAttempts - newAttemptsLeft;
          await saveGameResult(
            SaveGameResultParams(won: true, attemptsUsed: attemptsUsed),
          );
          
          final detailsResult = await getWordDetails(state.targetWord);
          final wordDetails = detailsResult.fold((_) => null, (details) => details);

          emit(GameWon(
            targetWord: state.targetWord,
            attemptsUsed: attemptsUsed,
            guesses: newGuesses,
            wordDetails: wordDetails,
          ));
          return;
        }

        // Check loss
        if (newAttemptsLeft == 0) {
          await saveGameResult(
            const SaveGameResultParams(won: false, attemptsUsed: AppConstants.maxAttempts),
          );
          
          final detailsResult = await getWordDetails(state.targetWord);
          final wordDetails = detailsResult.fold((_) => null, (details) => details);

          emit(GameLost(
            targetWord: state.targetWord,
            guesses: newGuesses,
            wordDetails: wordDetails,
          ));
          return;
        }

        // Continue game
        final toastMsg = _getWinEncouragement(newGuesses.length);
        emit(GameInProgress(
          targetWord: state.targetWord,
          completedGuesses: newGuesses,
          currentInput: const [],
          keyboardStatus: newKeyboardStatus,
          attemptsLeft: newAttemptsLeft,
          toastMessage: toastMsg,
        ));
      },
    );
  }

  /// Clear invalid word flag after animation completes
  void _onInvalidWordCleared(
    InvalidWordCleared event,
    Emitter<GameState> emit,
  ) {
    final state = this.state;
    if (state is! GameInProgress) return;
    emit(state.copyWith(isInvalidWord: false, clearToast: true));
  }

  /// Reset game — load a new random word so the player gets a different challenge
  Future<void> _onGameReset(GameReset event, Emitter<GameState> emit) async {
    emit(const GameLoading());

    final result = await getRandomWord(const NoParams());

    result.fold(
      (failure) => emit(GameError(failure.message)),
      (word) => emit(GameInProgress(
        targetWord: word,
        completedGuesses: const [],
        currentInput: const [],
        keyboardStatus: const {},
        attemptsLeft: AppConstants.maxAttempts,
      )),
    );
  }

  /// Priority order for keyboard status upgrades
  int _statusPriority(LetterStatus status) {
    switch (status) {
      case LetterStatus.initial:
        return 0;
      case LetterStatus.absent:
        return 1;
      case LetterStatus.present:
        return 2;
      case LetterStatus.correct:
        return 3;
    }
  }

  /// Returns a toast message based on how many attempts have been used
  String? _getWinEncouragement(int guessesCompleted) {
    // Only shown on the row BEFORE a win — not used here, but reserved for mid-game tips
    return null;
  }
}
