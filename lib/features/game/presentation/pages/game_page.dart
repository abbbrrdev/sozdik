import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../widgets/game_board.dart';
import '../widgets/kazakh_keyboard.dart';
import 'result_page.dart';
import '../../domain/entities/letter_entity.dart';
import '../../../stats/presentation/pages/stats_page.dart';

/// Main game screen — hosts the board, keyboard, and toast messages
class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<GameBloc>()..add(const GameStarted()),
      child: const _GamePageBody(),
    );
  }
}

class _GamePageBody extends StatefulWidget {
  const _GamePageBody();

  @override
  State<_GamePageBody> createState() => _GamePageBodyState();
}

class _GamePageBodyState extends State<_GamePageBody> {
  OverlayEntry? _toastOverlay;
  bool _isSoundEnabled = true;
  bool _isVibrationEnabled = true;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('is_first_launch') ?? true;

    if (isFirstLaunch) {
      await prefs.setBool('is_first_launch', false);
      // Ждём пока виджет полностью построится
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showHowToPlay(context);
        });
      }
    }
  }

  void _showToast(String message) {
    _toastOverlay?.remove();
    _toastOverlay = null;

    final overlay = Overlay.of(context);
    _toastOverlay = OverlayEntry(
      builder: (_) => _ToastWidget(message: message),
    );
    overlay.insert(_toastOverlay!);

    Future.delayed(const Duration(milliseconds: 1500), () {
      _toastOverlay?.remove();
      _toastOverlay = null;
    });
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Шапка ──────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    color: AppColors.correct,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SOZDIK',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.8),
                            letterSpacing: 2.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Баптаулар',
                          style: GoogleFonts.nunito(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Тело ───────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Column(
                      children: [
                        // Переключатели
                        _SettingsToggle(
                          icon: Icons.volume_up_rounded,
                          label: 'Дыбыс',
                          value: _isSoundEnabled,
                          onChanged: (val) {
                            setStateDialog(() => _isSoundEnabled = val);
                            setState(() {});
                          },
                        ),
                        const Divider(height: 1),
                        _SettingsToggle(
                          icon: Icons.vibration_rounded,
                          label: 'Діріл',
                          value: _isVibrationEnabled,
                          onChanged: (val) {
                            setStateDialog(() => _isVibrationEnabled = val);
                            setState(() {});
                          },
                        ),

                        // Заголовок секции
                        Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 4),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'МӘЗІР',
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[400],
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),

                        // Пункты меню
                        _SettingsMenuItem(
                          icon: Icons.home_rounded,
                          label: 'Басты бет',
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        const Divider(height: 1),
                        _SettingsMenuItem(
                          icon: Icons.refresh_rounded,
                          label: 'Қайта бастау',
                          onTap: () {
                            Navigator.of(context).pop();
                            context.read<GameBloc>().add(const GameReset());
                          },
                        ),
                        const Divider(height: 1),
                        _SettingsMenuItem(
                          icon: Icons.info_outline_rounded,
                          label: 'Ақпарат',
                          onTap: () {
                            Navigator.of(context).pop();
                            _showHowToPlay(context);
                          },
                        ),

                        const SizedBox(height: 8),
                        const Divider(height: 1),
                        const SizedBox(height: 8),

                        // Кнопка закрыть
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: AppColors.correct,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              'Жабу',
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showHowToPlay(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Шапка ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              color: AppColors.correct, // #6AAA64
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SOZDIK',
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.8),
                      letterSpacing: 2.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.howToPlayTitle, // 'Қалай ойнау керек?'
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // ── Тело ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '6 әрекетте 5 әріптен тұратын сөзді тап. '
                    'Әр болжамнан кейін тақталардың түсі өзгереді.',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Примеры строк
                  const _HowToPlayRow(
                    highlightIndex: 0,
                    highlightColor: AppColors.correct,
                    letters: ['Қ', 'Ы', 'М', 'Ы', 'З'],
                    hint: 'Әріп дұрыс орында',
                    hintColor: AppColors.correct,
                  ),
                  const SizedBox(height: 12),
                  const _HowToPlayRow(
                    highlightIndex: 1,
                    highlightColor: AppColors.present,
                    letters: ['С', 'Ө', 'З', 'Д', 'І'],
                    hint: 'Әріп бар, бірақ басқа орында',
                    hintColor: AppColors.present,
                  ),
                  const SizedBox(height: 12),
                  const _HowToPlayRow(
                    highlightIndex: 2,
                    highlightColor: AppColors.absent,
                    letters: ['А', 'Л', 'Т', 'Ы', 'Н'],
                    hint: 'Әріп сөзде жоқ',
                    hintColor: AppColors.absent,
                  ),

                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // ── Кнопка ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.correct,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Түсіндім!',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _toastOverlay?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameState>(
      listenWhen: (prev, current) {
        if (current is GameInProgress && current.toastMessage != null) {
          return true;
        }
        if (current is GameWon || current is GameLost) return true;
        return false;
      },
      listener: (context, state) {
        if (state is GameInProgress && state.toastMessage != null) {
          _showToast(state.toastMessage!);
          if (_isVibrationEnabled && state.isInvalidWord) {
            HapticFeedback.heavyImpact();
          }
        }
        if (state is GameWon) {
          if (_isVibrationEnabled) HapticFeedback.heavyImpact();

          _toastOverlay?.remove();
          _toastOverlay = null;
          // Capture navigator and bloc before async gap
          final nav = Navigator.of(context);
          final bloc = context.read<GameBloc>();
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              nav.push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => ResultPage(
                    won: true,
                    targetWord: state.targetWord,
                    wordDetails: state.wordDetails,
                    attemptsUsed: state.attemptsUsed,
                    guesses: state.guesses,
                    onPlayAgain: () {
                      nav.pop(); // close ResultPage
                      bloc.add(const GameReset()); // start fresh game
                    },
                  ),
                  transitionsBuilder: (_, animation, __, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              );
            }
          });
        }
        if (state is GameLost) {
          if (_isVibrationEnabled) HapticFeedback.heavyImpact();

          _toastOverlay?.remove();
          _toastOverlay = null;
          // Capture navigator and bloc before async gap
          final nav = Navigator.of(context);
          final bloc = context.read<GameBloc>();
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              nav.push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => ResultPage(
                    won: false,
                    targetWord: state.targetWord,
                    wordDetails: state.wordDetails,
                    attemptsUsed: 5,
                    guesses: state.guesses,
                    onPlayAgain: () {
                      nav.pop(); // close ResultPage
                      bloc.add(const GameReset()); // start fresh game
                    },
                  ),
                  transitionsBuilder: (_, animation, __, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              );
            }
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                _Header(
                  onStats: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const StatsPage()),
                  ),
                  onHelp: () => _showHowToPlay(context),
                  onSettings: () => _showSettings(context),
                ),
                const Divider(height: 1, color: AppColors.headerBorder),
                Expanded(child: _buildContent(context, state)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, GameState state) {
    if (state is GameLoading || state is GameInitial) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (state is GameError) {
      return Center(
        child: Text(
          state.message,
          style: GoogleFonts.nunito(color: Colors.red),
        ),
      );
    }

    // Show board for in-progress, won, or lost (brief flash before navigation)
    List<dynamic> completedGuesses = [];
    List<String> currentInput = [];
    Map<String, LetterStatus> keyboardStatus = {};
    bool isInvalidWord = false;

    if (state is GameInProgress) {
      completedGuesses = state.completedGuesses;
      currentInput = state.currentInput;
      keyboardStatus = state.keyboardStatus;
      isInvalidWord = state.isInvalidWord;
    } else if (state is GameWon) {
      completedGuesses = state.guesses;
    } else if (state is GameLost) {
      completedGuesses = state.guesses;
    }

    final bloc = context.read<GameBloc>();

    return Column(
      children: [
        const SizedBox(height: 16),
        // Game board
        Expanded(
          child: Center(
            child: GameBoard(
              completedGuesses: List.from(completedGuesses),
              currentInput: currentInput,
              shakeCurrentRow: isInvalidWord,
              onShakeComplete: () => bloc.add(const InvalidWordCleared()),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // On-screen keyboard
        if (state is GameInProgress)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: KazakhKeyboard(
              keyboardStatus: keyboardStatus,
              onLetterTap: (letter) {
                if (_isVibrationEnabled) HapticFeedback.lightImpact();
                bloc.add(LetterAdded(letter));
              },
              onDelete: () {
                if (_isVibrationEnabled) HapticFeedback.lightImpact();
                bloc.add(const LetterDeleted());
              },
              onEnter: () {
                if (_isVibrationEnabled) HapticFeedback.mediumImpact();
                bloc.add(const GuessSubmitted());
              },
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _SettingsToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggle({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.correct),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: AppColors.correct,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SettingsMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFEAF3DE),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: AppColors.correct),
      ),
      title: Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }
}

class _HowToPlayRow extends StatelessWidget {
  final int highlightIndex;
  final Color highlightColor;
  final List<String> letters;
  final String hint;
  final Color hintColor;

  const _HowToPlayRow({
    required this.highlightIndex,
    required this.highlightColor,
    required this.letters,
    required this.hint,
    required this.hintColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(letters.length, (i) {
            final isHighlighted = i == highlightIndex;
            return Container(
              margin: const EdgeInsets.only(right: 6),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isHighlighted ? highlightColor : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border:
                    isHighlighted ? null : Border.all(color: Colors.grey[300]!),
              ),
              alignment: Alignment.center,
              child: Text(
                letters[i],
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isHighlighted ? Colors.white : Colors.grey[800],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hintColor,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              hint,
              style: GoogleFonts.nunito(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// App header with title and icon buttons
class _Header extends StatelessWidget {
  final VoidCallback onStats;
  final VoidCallback onHelp;
  final VoidCallback onSettings;

  const _Header({
    required this.onStats,
    required this.onHelp,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Левая иконка (статистика)
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.bar_chart_rounded),
              color: AppColors.textPrimary,
              tooltip: AppStrings.statistics,
              onPressed: onStats,
            ),
          ),
          // Заголовок (строго по центру)
          Text(
            AppStrings.headerTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: 3,
            ),
          ),
          // Правые иконки
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.help_outline_rounded),
                  color: AppColors.textPrimary,
                  tooltip: AppStrings.howToPlay,
                  onPressed: onHelp,
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  color: AppColors.textPrimary,
                  tooltip: 'Баптаулар',
                  onPressed: onSettings,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Floating toast message widget
class _ToastWidget extends StatefulWidget {
  final String message;

  const _ToastWidget({required this.message});

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 120,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _opacity,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.toastBackground,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Text(
                widget.message,
                style: GoogleFonts.nunito(
                  color: AppColors.toastText,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  decoration:
                      TextDecoration.none, // ← вот это убирает подчёркивание
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
