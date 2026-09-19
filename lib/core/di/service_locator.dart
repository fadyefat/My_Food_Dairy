import 'package:get_it/get_it.dart';
import '../database/database_helper.dart';
import '../../features/meals/data/repos/meal_repo.dart';
import '../../features/meals/presentation/cubit/meal_cubit.dart';
import '../../features/daily_log/presentation/cubit/daily_log_cubit.dart';
import '../../features/summary/presentation/cubit/summary_cubit.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  // Database Helper
  getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());

  // Repositories
  getIt.registerLazySingleton<MealRepo>(() => MealRepo(getIt<DatabaseHelper>()));

  // Cubits / ViewModels (Factory to create fresh instances when requested)
  getIt.registerFactory<MealCubit>(() => MealCubit(getIt<MealRepo>()));
  getIt.registerFactory<DailyLogCubit>(() => DailyLogCubit(getIt<MealRepo>()));
  getIt.registerFactory<SummaryCubit>(() => SummaryCubit(getIt<MealRepo>()));
}
