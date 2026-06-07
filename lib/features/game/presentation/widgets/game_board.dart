import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/guess_entity.dart';
import '../../domain/entities/letter_entity.dart';
import 'letter_tile.dart';
import 'shake_animation.dart';

class GameBoard extends StatelessWidget {
  final List<GuessEntity> completedGuesses;
  final List<String> currentInput;
  final bool shakeCurrentRow;
  final VoidCallback? onShakeComplete;
  final int wordLength; // ← добавляем

  const GameBoard({
    super.key,
    required this.completedGuesses,
    required this.currentInput,
    required this.wordLength, // ← добавляем
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
      return _CompletedRow(
        guess: completedGuesses[rowIndex],
        rowIndex: rowIndex,
        wordLength: wordLength, // ← передаём
      );
    }
    if (isCurrentRow) {
      return ShakeAnimation(
        shake: shakeCurrentRow,
        onShakeComplete: onShakeComplete,
        child: _CurrentRow(
            input: currentInput, wordLength: wordLength), // ← передаём
      );
    }
    return _EmptyRow(wordLength: wordLength); // ← передаём
  }
}

class _CompletedRow extends StatelessWidget {
  final GuessEntity guess;
  final int rowIndex;
  final int wordLength; // ← добавляем

  const _CompletedRow({
    required this.guess,
    required this.rowIndex,
    required this.wordLength, // ← добавляем
  });

  @override
  Widget build(BuildContext context) {
    final tileSize = getTileSize(context, wordLength);
    
    return SizedBox(
      height: tileSize,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(wordLength, (colIndex) {
          // ← было AppConstants.wordLength
          final letter = guess.letters[colIndex];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: SizedBox(
              width: tileSize,
              height: tileSize,
              child: LetterTile(
                key: ValueKey('tile_${rowIndex}_$colIndex'),
                letter: letter.letter,
                status: letter.status,
                flipDelay: colIndex * 150,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _CurrentRow extends StatelessWidget {
  final List<String> input;
  final int wordLength; // ← добавляем

  const _CurrentRow({
    required this.input,
    required this.wordLength, // ← добавляем
  });

  @override
  Widget build(BuildContext context) {
    final tileSize = getTileSize(context, wordLength);

    return SizedBox(
      height: tileSize,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(wordLength, (colIndex) {
          final letter = colIndex < input.length ? input[colIndex] : '';

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: SizedBox(
              width: tileSize,
              height: tileSize,
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

class _EmptyRow extends StatelessWidget {
  final int wordLength; // ← добавляем

  const _EmptyRow({required this.wordLength}); // ← добавляем

  @override
  Widget build(BuildContext context) {
    final tileSize = getTileSize(context, wordLength);

    return SizedBox(
      height: tileSize,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(wordLength, (colIndex) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: SizedBox(
              width: tileSize,
              height: tileSize,
              child: const LetterTile(
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

double getTileSize(BuildContext context, int wordLength) {
  final screenWidth = MediaQuery.of(context).size.width;

  const horizontalPadding = 6.0;
  const boardHorizontalPadding = 16.0;

  return math.min(
    58.0,
    (screenWidth - boardHorizontalPadding - wordLength * horizontalPadding) /
        wordLength,
  );
}
