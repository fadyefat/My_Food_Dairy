import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../theme/theme_cubit.dart';
import '../../features/meals/data/repos/meal_repo.dart';
import '../../features/meals/presentation/cubit/meal_cubit.dart';
import '../../features/daily_log/presentation/cubit/daily_log_cubit.dart';
import '../../features/summary/presentation/cubit/summary_cubit.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator({SharedPreferences? preferences}) async {
  // Database Helper
  if (!getIt.isRegistered<DatabaseHelper>()) {
    getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());
  }

  // SharedPreferences & Theme
  if (!getIt.isRegistered<SharedPreferences>()) {
    final prefs = preferences ?? await SharedPreferences.getInstance();
    getIt.registerSingleton<SharedPreferences>(prefs);
  }
  if (!getIt.isRegistered<ThemeCubit>()) {
    getIt.registerLazySingleton<ThemeCubit>(() => ThemeCubit(getIt<SharedPreferences>()));
  }

  // Repositories
  if (!getIt.isRegistered<MealRepo>()) {
    getIt.registerLazySingleton<MealRepo>(() => MealRepo(getIt<DatabaseHelper>()));
  }

  // Cubits / ViewModels (Factory to create fresh instances when requested)
  if (!getIt.isRegistered<MealCubit>()) {
    getIt.registerFactory<MealCubit>(() => MealCubit(getIt<MealRepo>()));
  }
  if (!getIt.isRegistered<DailyLogCubit>()) {
    getIt.registerFactory<DailyLogCubit>(() => DailyLogCubit(getIt<MealRepo>()));
  }
  if (!getIt.isRegistered<SummaryCubit>()) {
    getIt.registerFactory<SummaryCubit>(() => SummaryCubit(getIt<MealRepo>()));
  }
}
