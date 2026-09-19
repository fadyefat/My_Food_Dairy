import 'package:flutter_test/flutter_test.dart';
import 'package:my_food_diary/core/di/service_locator.dart';
import 'package:my_food_diary/core/routing/app_router.dart';
import 'package:my_food_diary/food_diary_app.dart';

void main() {
  setUp(() {
    setupServiceLocator();
  });

  tearDown(() {
    getIt.reset();
  });

  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(FoodDiaryApp(appRouter: AppRouter()));
    expect(find.text('My Food Diary'), findsOneWidget);
  });
}
