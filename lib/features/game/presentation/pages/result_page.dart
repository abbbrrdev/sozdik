import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/guess_entity.dart';
import '../../domain/entities/letter_entity.dart';
import '../../domain/entities/word_details_entity.dart';

/// Result screen shown after the game ends (win or lose)
class ResultPage extends StatefulWidget {
  final bool won;
  final String targetWord;
  final WordDetailsEntity? wordDetails;
  final int attemptsUsed;
  final List<GuessEntity> guesses;
  final VoidCallback onPlayAgain;

  const ResultPage({
    super.key,
    required this.won,
    required this.targetWord,
    this.wordDetails,
    required this.attemptsUsed,
    required this.guesses,
    required this.onPlayAgain,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _buildShareText() {
    final header = '${AppStrings.sharePrefix} — '
        '${AppStrings.attemptsUsed(widget.attemptsUsed, 5)}';

    final grid = widget.guesses.map((guess) {
      return guess.letters.map((l) {
        switch (l.status) {
          case LetterStatus.correct:
            return '🟩';
          case LetterStatus.present:
            return '🟨';
          case LetterStatus.absent:
            return '⬜';
          case LetterStatus.initial:
            return '⬜';
        }
      }).join();
    }).join('\n');

    return '$header\n$grid';
  }

  void _share() {
    final text = _buildShareText();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Алмасу буферіне көшірілді!',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.accent,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Win/Lose headline
              ScaleTransition(
                scale: _scaleAnimation,
                child: Text(
                  widget.won ? AppStrings.youWon : AppStrings.youLost,
                  style: GoogleFonts.nunito(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: widget.won ? AppColors.correct : AppColors.absent,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Attempts
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    widget.won
                        ? '${AppStrings.attemptsUsed(widget.attemptsUsed, 5)} мүмкіндікте таптыңыз!'
                        : '',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: AppColors.absent,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              // Show target word and details if available (or just target word if won but we want to show details)
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    children: [
                      if (!widget.won) ...[
                        Text(
                          AppStrings.correctWordWas,
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            color: AppColors.absent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                      if (widget.wordDetails != null)
                        Text(
                          widget.wordDetails!.emoji,
                          style: const TextStyle(fontSize: 48),
                        ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: widget.won ? AppColors.correct : AppColors.accent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.targetWord,
                          style: GoogleFonts.nunito(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                      if (widget.wordDetails != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          widget.wordDetails!.translation,
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Emoji grid preview
              FadeTransition(
                opacity: _fadeAnimation,
                child: _EmojiGrid(guesses: widget.guesses),
              ),

              const Spacer(),

              // Action buttons
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Share button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _share,
                        icon: const Icon(Icons.share_rounded),
                        label: Text(
                          AppStrings.share,
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Play again
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: widget.onPlayAgain,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: const BorderSide(
                            color: AppColors.accent,
                            width: 2,
                          ),
                          foregroundColor: AppColors.accent,
                        ),
                        child: Text(
                          AppStrings.playAgain,
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Visual emoji grid showing the share preview
class _EmojiGrid extends StatelessWidget {
  final List<GuessEntity> guesses;

  const _EmojiGrid({required this.guesses});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: guesses.map((guess) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: guess.letters.map((letter) {
                String emoji;
                switch (letter.status) {
                  case LetterStatus.correct:
                    emoji = '🟩';
                    break;
                  case LetterStatus.present:
                    emoji = '🟨';
                    break;
                  default:
                    emoji = '⬜';
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}
