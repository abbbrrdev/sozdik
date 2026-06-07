// lib/features/home/presentation/pages/home_page.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:sozdik/core/constants/app_colors.dart';
import 'package:sozdik/features/game/presentation/pages/game_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: -12).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Stack(
          children: [
            // Звёздный фон
            const _StarField(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // ── Топ бар ──────────────────────────────
                  const _TopBar(),

                  const Spacer(),

                  // ── Сова + приветствие ───────────────────
                  Column(
                    children: [
                      SizedBox(
                        width: 220,
                        height: 140, 
                        child: ClipRect(
                          child: Align(
                            alignment: Alignment.topCenter,
                            heightFactor:
                                0.5,
                            child: Lottie.asset(
                              'assets/owl.json',
                              width: 280,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // const SizedBox(height: 20),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.nunito(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                          children: const[
                            TextSpan(text: 'Сәлем, '),
                            TextSpan(
                              text: 'ойыншы!',
                              style: TextStyle(color: AppColors.correct),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Бүгінгі сөзді таба аласың ба?\n5 әрекетің бар!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.5),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Плашки SOZDIK
                      const _WordTilesRow(),
                    ],
                  ),

                  const Spacer(),

                  // ── Кнопка играть ────────────────────────
                  _PlayButton(
                    onTap: () => Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (_, anim, __) => const GamePage(),
                        transitionsBuilder: (_, anim, __, child) =>
                            FadeTransition(opacity: anim, child: child),
                        transitionDuration: const Duration(milliseconds: 400),
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
    );
  }
}

// ── Звёздный фон ─────────────────────────────────────────────────────────────

class _StarField extends StatelessWidget {
  const _StarField();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StarPainter(),
      size: Size.infinite,
    );
  }
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42);
    final paint = Paint();
    for (int i = 0; i < 80; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = rng.nextDouble() * 1.5 + 0.3;
      paint.color = Colors.white.withOpacity(rng.nextDouble() * 0.5 + 0.2);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Топ бар ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Кнопки
        Row(
          children: [
            _IconBtn(icon: Icons.bar_chart_rounded, onTap: () {}),
            const SizedBox(width: 8),
            _IconBtn(icon: Icons.settings_rounded, onTap: () {}),
          ],
        ),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ── Плашки ────────────────────────────────────────────────────────────────────

class _WordTilesRow extends StatelessWidget {
  const _WordTilesRow();

  @override
  Widget build(BuildContext context) {
    const tiles = [
      ('С', Color(0xFF6AAA64)),
      ('Ө', Color(0xFFC9B458)),
      ('З', Color(0xFF787C7E)),
      ('Д', Color(0xFF6AAA64)),
      ('І', Color(0xFFC9B458)),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: tiles.map((t) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: t.$2,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            t.$1,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Карточка дневного слова ───────────────────────────────────────────────────

class _DailyWordCard extends StatelessWidget {
  final Duration timeLeft;
  const _DailyWordCard({required this.timeLeft});

  String _formatTime(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return '$h сағ $m мин';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.correct.withOpacity(0.12),
        border: Border.all(color: AppColors.correct.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'КҮНДЕЛІКТІ СӨЗ',
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.correct,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Бүгінгі ойын',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '⏰ ${_formatTime(timeLeft)} қалды',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.correct,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Text('📅', style: TextStyle(fontSize: 24)),
          ),
        ],
      ),
    );
  }
}

// ── Кнопка играть ─────────────────────────────────────────────────────────────

class _PlayButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PlayButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.correct,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          'Ойнау бастау',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
