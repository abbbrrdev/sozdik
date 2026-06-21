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

  // Kazakh Cyrillic standard keyboard layout rows
  static const List<List<String>> _rows = [
    ['Ә', 'І', 'Ң', 'Ғ', 'Ү', 'Ұ', 'Қ', 'Ө', 'Һ'],
    ['Й', 'Ц', 'У', 'К', 'Е', 'Н', 'Г', 'Ш', 'Щ', 'З', 'Х', 'Ъ'],
    ['Ф', 'Ы', 'В', 'А', 'П', 'Р', 'О', 'Л', 'Д', 'Ж', 'Э'],
    ['ENTER', 'Я', 'Ч', 'С', 'М', 'И', 'Т', 'Ь', 'Б', 'Ю', 'DELETE'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < _rows.length; i++)
          _buildLetterRow(_rows[i], i),
      ],
    );
  }

  Widget _buildLetterRow(List<String> letters, int rowIndex) {
    int totalFlex = 24;
    int keysFlex = 0;
    
    List<Widget> children = [];
    for (var letter in letters) {
      if (letter == 'ENTER' || letter == 'DELETE') {
        keysFlex += 3;
        children.add(
          Expanded(
            flex: 3,
            child: _buildWideActionKey(
              label: letter == 'ENTER' ? 'ЕНГІЗ' : '⌫',
              onTap: letter == 'ENTER' ? onEnter : onDelete,
              backgroundColor: letter == 'ENTER' ? AppColors.accent : AppColors.keyDefault,
              textColor: letter == 'ENTER' ? Colors.white : AppColors.keyText,
              fontSize: letter == 'ENTER' ? 12 : 18,
            ),
          ),
        );
      } else {
        keysFlex += 2;
        children.add(
          Expanded(
            flex: 2,
            child: _buildKey(letter),
          ),
        );
      }
    }
    
    int remainingFlex = totalFlex - keysFlex;
    if (remainingFlex > 0) {
      int spaceFlex = remainingFlex ~/ 2;
      if (spaceFlex > 0) {
        children.insert(0, Spacer(flex: spaceFlex));
        children.add(Spacer(flex: spaceFlex));
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
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
        margin: const EdgeInsets.symmetric(horizontal: 2),
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
        margin: const EdgeInsets.symmetric(horizontal: 2),
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
