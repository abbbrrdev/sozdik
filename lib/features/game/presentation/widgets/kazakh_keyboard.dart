import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/letter_entity.dart';

/// Full on-screen Kazakh Cyrillic keyboard.
/// Colors each key based on the best letter status achieved so far.
class KazakhKeyboard extends StatelessWidget {
  final Map<String, LetterStatus> keyboardStatus;
  final ValueChanged<String> onLetterTap;
  final VoidCallback onDelete;
  final VoidCallback onEnter;

  const KazakhKeyboard({
    super.key,
    required this.keyboardStatus,
    required this.onLetterTap,
    required this.onDelete,
    required this.onEnter,
  });

  // Kazakh Cyrillic keyboard layout rows
  static const List<List<String>> _rows = [
    ['Қ', 'Ү', 'Ұ', 'Ң', 'Ғ', 'Ә', 'І', 'Ө', 'Һ'],
    ['А', 'Б', 'В', 'Г', 'Д', 'Е', 'Ж', 'З', 'И'],
    ['Й', 'К', 'Л', 'М', 'Н', 'О', 'П', 'Р', 'С'],
    ['Т', 'У', 'Ф', 'Х', 'Ш', 'Ы', 'Э', 'Ю', 'Я'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ..._rows.map((row) => _buildLetterRow(row)),
        const SizedBox(height: 6),
        _buildActionRow(),
      ],
    );
  }

  Widget _buildLetterRow(List<String> letters) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: letters.map((letter) => _buildKey(letter)).toList(),
      ),
    );
  }

  Widget _buildActionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildWideActionKey(
          label: '⌫',
          onTap: onDelete,
          backgroundColor: AppColors.keyDefault,
          textColor: AppColors.keyText,
        ),
        const SizedBox(width: 6),
        _buildWideActionKey(
          label: 'ЕНГІЗ',
          onTap: onEnter,
          backgroundColor: AppColors.accent,
          textColor: Colors.white,
          fontSize: 12,
        ),
      ],
    );
  }

  Widget _buildKey(String letter) {
    final status = keyboardStatus[letter];
    final bg = _keyBackground(status);
    final textColor = _keyTextColor(status);

    return GestureDetector(
      onTap: () => onLetterTap(letter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        width: 32,
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          letter,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildWideActionKey({
    required String label,
    required VoidCallback onTap,
    required Color backgroundColor,
    required Color textColor,
    double fontSize = 18,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        height: 44,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Color _keyBackground(LetterStatus? status) {
    if (status == null) return AppColors.keyDefault;
    switch (status) {
      case LetterStatus.correct:
        return AppColors.correct;
      case LetterStatus.present:
        return AppColors.present;
      case LetterStatus.absent:
        return AppColors.absent;
      case LetterStatus.initial:
        return AppColors.keyDefault;
    }
  }

  Color _keyTextColor(LetterStatus? status) {
    if (status == null || status == LetterStatus.initial) {
      return AppColors.keyText;
    }
    return AppColors.keyTextLight;
  }
}
