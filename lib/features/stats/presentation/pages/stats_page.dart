import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_stats_usecase.dart';
import '../../domain/entities/stats_entity.dart';

/// Statistics screen showing win rate, streaks, and guess distribution
class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  StatsEntity? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final useCase = getIt<GetStatsUseCase>();
    final result = await useCase(const NoParams());
    result.fold(
      (_) => setState(() => _loading = false),
      (stats) => setState(() {
        _stats = stats;
        _loading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppStrings.statsTitle,
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: AppColors.textPrimary,
            letterSpacing: 2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent))
          : _stats == null
              ? Center(
                  child: Text(
                    'Деректер жоқ',
                    style: GoogleFonts.nunito(color: AppColors.absent),
                  ),
                )
              : _StatsBody(stats: _stats!),
    );
  }
}

class _StatsBody extends StatelessWidget {
  final StatsEntity stats;

  const _StatsBody({required this.stats});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Stat number cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatCard(
                value: stats.gamesPlayed.toString(),
                label: AppStrings.gamesPlayed,
              ),
              _StatCard(
                value: '${stats.winPercentage.round()}%',
                label: AppStrings.winRate,
              ),
              _StatCard(
                value: stats.currentStreak.toString(),
                label: AppStrings.currentStreak,
              ),
              _StatCard(
                value: stats.bestStreak.toString(),
                label: AppStrings.bestStreak,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Distribution title
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              AppStrings.guessDistribution,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _GuessDistribution(distribution: stats.guessDistribution),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

/// Single stat number + label
class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.nunito(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.absent,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

/// Animated bar chart showing distribution per attempt count
class _GuessDistribution extends StatelessWidget {
  final List<int> distribution;

  const _GuessDistribution({required this.distribution});

  @override
  Widget build(BuildContext context) {
    final maxValue = distribution.isEmpty
        ? 1
        : distribution.reduce((a, b) => a > b ? a : b);

    return Column(
      children: List.generate(distribution.length, (i) {
        final count = distribution[i];
        final fraction = maxValue == 0 ? 0.0 : count / maxValue;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                child: Text(
                  '${i + 1}',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final barWidth = count == 0
                        ? 28.0
                        : constraints.maxWidth * fraction.clamp(0.08, 1.0);

                    return AnimatedContainer(
                      duration: Duration(milliseconds: 400 + i * 80),
                      curve: Curves.easeOut,
                      width: barWidth,
                      height: 28,
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                        color: count > 0
                            ? AppColors.correct
                            : AppColors.keyDefault,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        count.toString(),
                        style: GoogleFonts.nunito(
                          color: count > 0
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
