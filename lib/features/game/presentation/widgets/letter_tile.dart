import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/letter_entity.dart';

/// A single letter tile on the game board.
/// Supports three visual states: empty, filled (typed), submitted (colored).
/// Includes a bounce animation on letter entry and a flip animation on submission.
class LetterTile extends StatefulWidget {
  final String letter;
  final LetterStatus status;
  final bool isFilled; // True when letter typed but not yet submitted
  final int flipDelay; // Delay in milliseconds before flip starts

  const LetterTile({
    super.key,
    required this.letter,
    required this.status,
    this.isFilled = false,
    this.flipDelay = 0,
  });

  @override
  State<LetterTile> createState() => _LetterTileState();
}

class _LetterTileState extends State<LetterTile>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _flipController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _flipAnimation;

  bool _isFlipped = false;
  LetterStatus _displayedStatus = LetterStatus.initial;

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeOut),
    );

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    _flipAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isFlipped = true;
          _displayedStatus = widget.status;
        });
      }
    });

    _triggerFlipIfNeeded();
  }

  @override
  void didUpdateWidget(LetterTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Bounce when a letter is newly added
    if (widget.letter.isNotEmpty && oldWidget.letter.isEmpty) {
      _bounceController.forward().then((_) => _bounceController.reverse());
    }

    // Flip when status changes from initial to something else (row submitted)
    if (widget.status != LetterStatus.initial &&
        oldWidget.status == LetterStatus.initial) {
      _triggerFlipIfNeeded();
    }
  }

  void _triggerFlipIfNeeded() {
    if (widget.status != LetterStatus.initial) {
      Future.delayed(Duration(milliseconds: widget.flipDelay), () {
        if (mounted) {
          _flipController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  Color get _backgroundColor {
    if (!_isFlipped) return AppColors.empty;
    switch (_displayedStatus) {
      case LetterStatus.correct:
        return AppColors.correct;
      case LetterStatus.present:
        return AppColors.present;
      case LetterStatus.absent:
        return AppColors.absent;
      case LetterStatus.initial:
        return AppColors.empty;
    }
  }

  Color get _borderColor {
    if (_isFlipped && _displayedStatus != LetterStatus.initial) {
      return Colors.transparent;
    }
    if (widget.isFilled || widget.letter.isNotEmpty) {
      return AppColors.borderFilled;
    }
    return AppColors.borderEmpty;
  }

  Color get _textColor {
    if (_isFlipped && _displayedStatus != LetterStatus.initial) {
      return AppColors.textOnTile;
    }
    return AppColors.textOnEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_bounceController, _flipController]),
      builder: (context, child) {
        // Flip: first half hides the tile, second half reveals colored tile
        final flipValue = _flipAnimation.value;
        final angle = flipValue * 3.14159;
        final showBack = flipValue > 0.5;

        return Transform.scale(
          scale: _bounceAnimation.value,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(showBack ? angle - 3.14159 : angle),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 50),
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: _backgroundColor,
                border: Border.all(
                  color: _borderColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: Text(
                widget.letter,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _textColor,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
