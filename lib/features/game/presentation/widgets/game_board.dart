import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/guess_entity.dart';
import '../../domain/entities/letter_entity.dart';
import 'letter_tile.dart';
import 'shake_animation.dart';

/// The 5×5 game board showing all rows (completed guesses + current input + empty rows)
class GameBoard extends StatelessWidget {
  final List<GuessEntity> completedGuesses;
  final List<String> currentInput;
  final bool shakeCurrentRow;
  final VoidCallback? onShakeComplete;

  const GameBoard({
    super.key,
    required this.completedGuesses,
    required this.currentInput,
    this.shakeCurrentRow = false,
    this.onShakeComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(AppConstants.maxAttempts, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: _buildRow(rowIndex),
        );
      }),
    );
  }

  Widget _buildRow(int rowIndex) {
    final isCompleted = rowIndex < completedGuesses.length;
    final isCurrentRow = rowIndex == completedGuesses.length;

    if (isCompleted) {
      return _CompletedRow(guess: completedGuesses[rowIndex], rowIndex: rowIndex);
    }

    if (isCurrentRow) {
      return ShakeAnimation(
        shake: shakeCurrentRow,
        onShakeComplete: onShakeComplete,
        child: _CurrentRow(input: currentInput),
      );
    }

    return const _EmptyRow();
  }
}

/// A completed (submitted) row with flip animations
class _CompletedRow extends StatelessWidget {
  final GuessEntity guess;
  final int rowIndex;

  const _CompletedRow({required this.guess, required this.rowIndex});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(AppConstants.wordLength, (colIndex) {
          final letter = guess.letters[colIndex];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: SizedBox(
              width: 58,
              height: 58,
              child: LetterTile(
                key: ValueKey('tile_${rowIndex}_$colIndex'),
                letter: letter.letter,
                status: letter.status,
                flipDelay: colIndex * 150, // staggered flip
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// The current active row being typed
class _CurrentRow extends StatelessWidget {
  final List<String> input;

  const _CurrentRow({required this.input});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(AppConstants.wordLength, (colIndex) {
          final letter = colIndex < input.length ? input[colIndex] : '';
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: SizedBox(
              width: 58,
              height: 58,
              child: LetterTile(
                key: ValueKey('current_$colIndex'),
                letter: letter,
                status: LetterStatus.initial,
                isFilled: letter.isNotEmpty,
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// An empty row (future attempts)
class _EmptyRow extends StatelessWidget {
  const _EmptyRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(AppConstants.wordLength, (colIndex) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 3),
            child: SizedBox(
              width: 58,
              height: 58,
              child: LetterTile(
                letter: '',
                status: LetterStatus.initial,
              ),
            ),
          );
        }),
      ),
    );
  }
}
