import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_food_diary/features/daily_log/presentation/cubit/daily_log_cubit.dart';
import 'package:my_food_diary/features/daily_log/presentation/cubit/daily_log_state.dart';
import 'package:my_food_diary/features/meals/data/models/meal_model.dart';
import 'package:my_food_diary/features/meals/data/repos/meal_repo.dart';

class MockMealRepo extends Mock implements MealRepo {}

void main() {
  late MockMealRepo mockMealRepo;
  late DailyLogCubit dailyLogCubit;

  final sampleMeals = [
    MealModel(
      id: 1,
      mealType: 'Breakfast',
      mealDetails: 'Scrambled eggs with toast',
      date: '26/09/2026',
      time: '08:00 AM',
      createdAt: '2026-09-26T08:00:00Z',
    ),
    MealModel(
      id: 2,
      mealType: 'Lunch',
      mealDetails: 'Caesar Salad with chicken',
      date: '26/09/2026',
      time: '01:00 PM',
      createdAt: '2026-09-26T13:00:00Z',
    ),
    MealModel(
      id: 3,
      mealType: 'Dinner',
      mealDetails: 'Grilled Salmon with rice',
      date: '26/09/2026',
      time: '07:30 PM',
      createdAt: '2026-09-26T19:30:00Z',
    ),
  ];

  setUp(() {
    mockMealRepo = MockMealRepo();
    dailyLogCubit = DailyLogCubit(mockMealRepo);
  });

  tearDown(() {
    dailyLogCubit.close();
  });

  test('initial state is DailyLogInitial', () {
    expect(dailyLogCubit.state, isA<DailyLogInitial>());
  });

  blocTest<DailyLogCubit, DailyLogState>(
    'loadMealsForDate emits [DailyLogLoading, DailyLogLoaded]',
    build: () {
      when(() => mockMealRepo.getMealsByDate(any())).thenAnswer((_) async => sampleMeals);
      return dailyLogCubit;
    },
    act: (cubit) => cubit.loadMealsForDate(DateTime(2026, 9, 26)),
    expect: () => [
      isA<DailyLogLoading>(),
      isA<DailyLogLoaded>().having(
        (s) => s.meals.length,
        'meals length',
        3,
      ),
    ],
  );

  blocTest<DailyLogCubit, DailyLogState>(
    'filterMeals by query correctly filters meals list',
    build: () {
      when(() => mockMealRepo.getMealsByDate(any())).thenAnswer((_) async => sampleMeals);
      return dailyLogCubit;
    },
    act: (cubit) async {
      await cubit.loadMealsForDate(DateTime(2026, 9, 26));
      cubit.filterMeals(query: 'salad');
    },
    skip: 2, // Skip initial loading & loaded states
    expect: () => [
      isA<DailyLogLoaded>().having(
        (s) => s.meals.length,
        'filtered length',
        1,
      ).having(
        (s) => s.meals.first.mealType,
        'meal type',
        'Lunch',
      ),
    ],
  );

  blocTest<DailyLogCubit, DailyLogState>(
    'filterMeals by category correctly filters meals by type',
    build: () {
      when(() => mockMealRepo.getMealsByDate(any())).thenAnswer((_) async => sampleMeals);
      return dailyLogCubit;
    },
    act: (cubit) async {
      await cubit.loadMealsForDate(DateTime(2026, 9, 26));
      cubit.filterMeals(category: 'Dinner');
    },
    skip: 2,
    expect: () => [
      isA<DailyLogLoaded>().having(
        (s) => s.meals.length,
        'filtered length',
        1,
      ).having(
        (s) => s.meals.first.mealDetails,
        'meal details',
        'Grilled Salmon with rice',
      ),
    ],
  );

  blocTest<DailyLogCubit, DailyLogState>(
    'deleteMeal calls repo and refreshes date',
    build: () {
      when(() => mockMealRepo.deleteMeal(1)).thenAnswer((_) async => 1);
      when(() => mockMealRepo.getMealsByDate(any())).thenAnswer((_) async => []);
      return dailyLogCubit;
    },
    act: (cubit) => cubit.deleteMeal(1),
    expect: () => [
      isA<MealDeletedSuccess>(),
      isA<DailyLogLoading>(),
      isA<DailyLogLoaded>(),
    ],
  );
}
