import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/stats_entity.dart';

/// Local data source for game statistics using SharedPreferences
class StatsLocalDatasource {
  final SharedPreferences prefs;

  StatsLocalDatasource(this.prefs);

  /// Loads stats from SharedPreferences
  StatsEntity getStats() {
    final gamesPlayed = prefs.getInt(AppConstants.prefGamesPlayed) ?? 0;
    final gamesWon = prefs.getInt(AppConstants.prefGamesWon) ?? 0;
    final currentStreak = prefs.getInt(AppConstants.prefCurrentStreak) ?? 0;
    final bestStreak = prefs.getInt(AppConstants.prefBestStreak) ?? 0;

    final distJson = prefs.getString(AppConstants.prefGuessDistribution);
    List<int> distribution = [0, 0, 0, 0, 0];
    if (distJson != null) {
      try {
        final decoded = jsonDecode(distJson) as List;
        distribution = decoded.cast<int>();
      } catch (_) {}
    }

    return StatsEntity(
      gamesPlayed: gamesPlayed,
      gamesWon: gamesWon,
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      guessDistribution: distribution,
    );
  }

  /// Saves a game result to SharedPreferences
  Future<void> saveGameResult({required bool won, required int attemptsUsed}) async {
    final current = getStats();

    final newGamesPlayed = current.gamesPlayed + 1;
    final newGamesWon = won ? current.gamesWon + 1 : current.gamesWon;
    final newCurrentStreak = won ? current.currentStreak + 1 : 0;
    final newBestStreak = newCurrentStreak > current.bestStreak
        ? newCurrentStreak
        : current.bestStreak;

    final newDistribution = List<int>.from(current.guessDistribution);
    if (won && attemptsUsed >= 1 && attemptsUsed <= 5) {
      newDistribution[attemptsUsed - 1]++;
    }

    await prefs.setInt(AppConstants.prefGamesPlayed, newGamesPlayed);
    await prefs.setInt(AppConstants.prefGamesWon, newGamesWon);
    await prefs.setInt(AppConstants.prefCurrentStreak, newCurrentStreak);
    await prefs.setInt(AppConstants.prefBestStreak, newBestStreak);
    await prefs.setString(
      AppConstants.prefGuessDistribution,
      jsonEncode(newDistribution),
    );
  }
}
