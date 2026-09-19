import 'package:flutter/material.dart';
import 'core/di/service_locator.dart';
import 'core/routing/app_router.dart';
import 'food_diary_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  runApp(FoodDiaryApp(appRouter: AppRouter()));
}
