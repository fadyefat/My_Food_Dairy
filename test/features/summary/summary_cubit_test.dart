import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_food_diary/features/meals/data/repos/meal_repo.dart';
import 'package:my_food_diary/features/summary/presentation/cubit/summary_cubit.dart';
import 'package:my_food_diary/features/summary/presentation/cubit/summary_state.dart';

class MockMealRepo extends Mock implements MealRepo {}

void main() {
  late MockMealRepo mockMealRepo;
  late SummaryCubit summaryCubit;

  setUp(() {
    mockMealRepo = MockMealRepo();
    summaryCubit = SummaryCubit(mockMealRepo);
  });

  tearDown(() {
    summaryCubit.close();
  });

  test('initial state is SummaryInitial', () {
    expect(summaryCubit.state, isA<SummaryInitial>());
  });

  blocTest<SummaryCubit, SummaryState>(
    'loadTodayStatistics emits [SummaryLoading, DailySummaryLoaded]',
    build: () {
      when(() => mockMealRepo.getTodayStatistics()).thenAnswer(
        (_) async => {
          'totalMeals': 3,
          'mealTypes': 2,
          'mealTypeCounts': {'Breakfast': 1, 'Lunch': 2, 'Dinner': 0, 'Snack': 0},
          'meals': <Map<String, dynamic>>[],
        },
      );
      return summaryCubit;
    },
    act: (cubit) => cubit.loadTodayStatistics(),
    expect: () => [
      isA<SummaryLoading>(),
      isA<DailySummaryLoaded>()
          .having((s) => s.totalMeals, 'totalMeals', 3)
          .having((s) => s.mealTypes, 'mealTypes', 2)
          .having((s) => s.mealTypeCounts['Breakfast'], 'breakfast count', 1),
    ],
  );

  blocTest<SummaryCubit, SummaryState>(
    'loadWeeklyStatistics emits [SummaryLoading, WeeklySummaryLoaded]',
    build: () {
      when(() => mockMealRepo.getWeeklyStatistics()).thenAnswer(
        (_) async => {
          'totalMeals': 14,
          'avgMealsPerDay': 2.0,
          'mostCommonMeal': 'Breakfast',
          'mealTypeCounts': {'Breakfast': 7, 'Lunch': 5, 'Dinner': 2, 'Snack': 0},
          'dailyMealCounts': {'Mon': 2, 'Tue': 2, 'Wed': 2, 'Thu': 2, 'Fri': 2, 'Sat': 2, 'Sun': 2},
          'meals': <Map<String, dynamic>>[],
        },
      );
      return summaryCubit;
    },
    act: (cubit) => cubit.loadWeeklyStatistics(),
    expect: () => [
      isA<SummaryLoading>(),
      isA<WeeklySummaryLoaded>()
          .having((s) => s.totalMeals, 'totalMeals', 14)
          .having((s) => s.avgMealsPerDay, 'avgMealsPerDay', 2.0)
          .having((s) => s.mostCommonMeal, 'mostCommonMeal', 'Breakfast')
          .having((s) => s.dailyMealCounts['Mon'], 'Mon count', 2),
    ],
  );

  blocTest<SummaryCubit, SummaryState>(
    'emits [SummaryLoading, SummaryError] on repository failure',
    build: () {
      when(() => mockMealRepo.getTodayStatistics()).thenThrow(Exception('DB error'));
      return summaryCubit;
    },
    act: (cubit) => cubit.loadTodayStatistics(),
    expect: () => [
      isA<SummaryLoading>(),
      isA<SummaryError>(),
    ],
  );
}
