/// All Kazakh UI strings for Сөзді тап
class AppStrings {
  AppStrings._();

  // App title
  static const String appTitle = 'Сөзді тап';
  static const String appSubtitle = 'Казақша Wordle';

  // Game header
  static const String headerTitle = 'СӨЗДІ ТАП';

  // Game messages
  static const String notEnoughLetters = 'Аз әріп!';
  static const String wordNotFound = 'Сөз жоқ!';
  static const String excellentFirstTry = 'Керемет! 🔥';
  static const String greatSecondTry = 'Жақсы!';
  static const String goodThirdTry = 'Тамаша!';
  static const String niceFourthTry = 'Дұрыс!';
  static const String closeFifthTry = 'Жақын болды!';

  // Win / Lose
  static const String youWon = 'Сіз ұттыңыз! 🎉';
  static const String youLost = 'Жеңілдіңіз 😔';
  static const String correctWordWas = 'Дұрыс жауап:';

  // Buttons
  static const String playAgain = 'Қайта ойна';
  static const String share = 'Бөлісу';
  static const String statistics = 'Статистика';
  static const String close = 'Жабу';
  static const String howToPlay = 'Ойын ережесі';

  // Statistics
  static const String statsTitle = 'Статистика';
  static const String gamesPlayed = 'Ойналды';
  static const String winRate = 'Жеңіс %';
  static const String currentStreak = 'Ағымдағы серия';
  static const String bestStreak = 'Ең жақсы серия';
  static const String guessDistribution = 'Болжамдар бөлінісі';

  // How to play
  static const String howToPlayTitle = 'Ойын ережесі';
  static const String howToPlayBody =
      '5 әріпті сөзді 5 мүмкіндікте табыңыз.\n\n'
      '🟩 Жасыл — дұрыс орын\n'
      '🟨 Сары — сөзде бар, орны бұрыс\n'
      '⬜ Сұр — сөзде жоқ';

  // Share
  static const String sharePrefix = 'Сөзді тап';

  // Result attempt text
  static String attemptsUsed(int used, int max) => '$used/$max';
}
