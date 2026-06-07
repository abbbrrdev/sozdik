/// Core game constants for Сөзді тап
class AppConstants {
  AppConstants._();

  /// Number of letters in each word
  static const int wordLength = 5;

  /// Maximum number of guess attempts
  static const int maxAttempts = 5;

  /// SharedPreferences keys
  static const String prefGamesPlayed = 'games_played';
  static const String prefGamesWon = 'games_won';
  static const String prefCurrentStreak = 'current_streak';
  static const String prefBestStreak = 'best_streak';
  static const String prefGuessDistribution = 'guess_distribution';
  static const String prefLastPlayedDay = 'last_played_day';
  static const String prefLastResult = 'last_result';
}
