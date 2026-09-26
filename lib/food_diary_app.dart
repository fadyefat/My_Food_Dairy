import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/service_locator.dart';
import 'core/routing/app_router.dart';
import 'core/routing/routes.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/theme_cubit.dart';

class FoodDiaryApp extends StatelessWidget {
  final AppRouter appRouter;

  const FoodDiaryApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeCubit>.value(
      value: getIt<ThemeCubit>(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'My Food Diary',
            debugShowCheckedModeBanner: false,
            theme: AppColors.lightTheme,
            darkTheme: AppColors.darkTheme,
            themeMode: themeMode,
            initialRoute: Routes.homeScreen,
            onGenerateRoute: appRouter.generateRoute,
          );
        },
      ),
    );
  }
}
