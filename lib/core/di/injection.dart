import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Data sources
import '../../features/game/data/datasources/word_local_datasource.dart';
import '../../features/stats/data/datasources/stats_local_datasource.dart';

// Repositories
import '../../features/game/data/repositories/game_repository_impl.dart';
import '../../features/game/domain/repositories/game_repository.dart';
import '../../features/stats/data/repositories/stats_repository_impl.dart';
import '../../features/stats/domain/repositories/stats_repository.dart';

// Use cases — game
import '../../features/game/domain/usecases/get_daily_word_usecase.dart';
import '../../features/game/domain/usecases/get_random_word_usecase.dart';
import '../../features/game/domain/usecases/get_word_details_usecase.dart';
import '../../features/game/domain/usecases/validate_guess_usecase.dart';
import '../../features/game/domain/usecases/check_word_exists_usecase.dart';

// Use cases — stats
import '../../features/stats/domain/usecases/get_stats_usecase.dart';
import '../../features/stats/domain/usecases/save_game_result_usecase.dart';

// BLoC
import '../../features/game/presentation/bloc/game_bloc.dart';

final GetIt getIt = GetIt.instance;

/// Registers all dependencies manually (no code generation required).
Future<void> configureDependencies() async {
  // ── External ──────────────────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // ── Data sources ──────────────────────────────────────────────────────────
  getIt.registerLazySingleton<WordLocalDatasource>(
    () => WordLocalDatasource(),
  );
  getIt.registerLazySingleton<StatsLocalDatasource>(
    () => StatsLocalDatasource(getIt<SharedPreferences>()),
  );

  // ── Repositories ──────────────────────────────────────────────────────────
  getIt.registerLazySingleton<GameRepository>(
    () => GameRepositoryImpl(getIt<WordLocalDatasource>()),
  );
  getIt.registerLazySingleton<StatsRepository>(
    () => StatsRepositoryImpl(getIt<StatsLocalDatasource>()),
  );

  // ── Use cases ─────────────────────────────────────────────────────────────
  getIt.registerFactory<GetDailyWordUseCase>(
    () => GetDailyWordUseCase(getIt<GameRepository>()),
  );
  getIt.registerFactory<GetRandomWordUseCase>(
    () => GetRandomWordUseCase(getIt<GameRepository>()),
  );
  getIt.registerFactory<ValidateGuessUseCase>(
    () => ValidateGuessUseCase(getIt<GameRepository>()),
  );
  getIt.registerFactory<CheckWordExistsUseCase>(
    () => CheckWordExistsUseCase(getIt<GameRepository>()),
  );
  getIt.registerFactory<GetWordDetailsUseCase>(
    () => GetWordDetailsUseCase(getIt<GameRepository>()),
  );
  getIt.registerFactory<GetStatsUseCase>(
    () => GetStatsUseCase(getIt<StatsRepository>()),
  );
  getIt.registerFactory<SaveGameResultUseCase>(
    () => SaveGameResultUseCase(getIt<StatsRepository>()),
  );

  // ── BLoC ──────────────────────────────────────────────────────────────────
  getIt.registerFactory<GameBloc>(
    () => GameBloc(
      getDailyWord: getIt<GetDailyWordUseCase>(),
      getRandomWord: getIt<GetRandomWordUseCase>(),
      validateGuess: getIt<ValidateGuessUseCase>(),
      checkWordExists: getIt<CheckWordExistsUseCase>(),
      saveGameResult: getIt<SaveGameResultUseCase>(),
      getWordDetails: getIt<GetWordDetailsUseCase>(),
    ),
  );
}
