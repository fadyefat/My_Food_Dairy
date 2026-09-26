import 'package:flutter/material.dart';
import 'core/di/service_locator.dart';
import 'core/routing/app_router.dart';
import 'core/services/firebase_service.dart';
import 'food_diary_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  await setupServiceLocator();
  runApp(FoodDiaryApp(appRouter: AppRouter()));
}
