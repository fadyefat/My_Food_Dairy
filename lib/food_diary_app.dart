import 'package:flutter/material.dart';
import 'core/routing/app_router.dart';
import 'core/routing/routes.dart';

class FoodDiaryApp extends StatelessWidget {
  final AppRouter appRouter;

  const FoodDiaryApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Food Diary',
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.homeScreen,
      onGenerateRoute: appRouter.generateRoute,
    );
  }
}
