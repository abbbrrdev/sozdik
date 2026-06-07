import 'package:equatable/equatable.dart';

/// Entity holding all game statistics
class StatsEntity extends Equatable {
  final int gamesPlayed;
  final int gamesWon;
  final int currentStreak;
  final int bestStreak;

  /// Distribution of wins by attempt count (index 0 = won on 1st try, etc.)
  final List<int> guessDistribution;

  const StatsEntity({
    required this.gamesPlayed,
    required this.gamesWon,
    required this.currentStreak,
    required this.bestStreak,
    required this.guessDistribution,
  });

  /// Win percentage (0–100)
  double get winPercentage =>
      gamesPlayed == 0 ? 0 : (gamesWon / gamesPlayed) * 100;

  StatsEntity copyWith({
    int? gamesPlayed,
    int? gamesWon,
    int? currentStreak,
    int? bestStreak,
    List<int>? guessDistribution,
  }) {
    return StatsEntity(
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      guessDistribution: guessDistribution ?? this.guessDistribution,
    );
  }

  static StatsEntity empty() => const StatsEntity(
        gamesPlayed: 0,
        gamesWon: 0,
        currentStreak: 0,
        bestStreak: 0,
        guessDistribution: [0, 0, 0, 0, 0],
      );

  @override
  List<Object?> get props => [
        gamesPlayed,
        gamesWon,
        currentStreak,
        bestStreak,
        guessDistribution,
      ];
}
