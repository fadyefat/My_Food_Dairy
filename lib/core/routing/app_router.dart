import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../di/service_locator.dart';
import 'routes.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/ui/login_screen.dart';
import '../../features/auth/presentation/ui/register_screen.dart';
import '../../features/home/presentation/ui/home_screen.dart';
import '../../features/meals/data/models/meal_model.dart';
import '../../features/meals/presentation/cubit/meal_cubit.dart';
import '../../features/meals/presentation/ui/meal_screen.dart';
import '../../features/daily_log/presentation/cubit/daily_log_cubit.dart';
import '../../features/daily_log/presentation/ui/daily_log_screen.dart';
import '../../features/summary/presentation/cubit/summary_cubit.dart';
import '../../features/summary/presentation/ui/daily_summary_screen.dart';
import '../../features/summary/presentation/ui/weekly_summary_screen.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.loginScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: const LoginScreen(),
          ),
        );

      case Routes.registerScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: const RegisterScreen(),
          ),
        );

      case Routes.homeScreen:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );

      case Routes.mealScreen:
        final editMeal = settings.arguments as MealModel?;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<MealCubit>(),
            child: MealScreen(editMeal: editMeal),
          ),
        );

      case Routes.dailyLogScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<DailyLogCubit>(),
            child: const DailyLogScreen(),
          ),
        );

      case Routes.dailySummaryScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<SummaryCubit>(),
            child: const DailySummaryScreen(),
          ),
        );

      case Routes.weeklySummaryScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<SummaryCubit>(),
            child: const WeeklySummaryScreen(),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
