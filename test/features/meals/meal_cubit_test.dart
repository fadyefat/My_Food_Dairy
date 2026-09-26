import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_food_diary/features/meals/data/models/meal_model.dart';
import 'package:my_food_diary/features/meals/data/repos/meal_repo.dart';
import 'package:my_food_diary/features/meals/presentation/cubit/meal_cubit.dart';
import 'package:my_food_diary/features/meals/presentation/cubit/meal_state.dart';

class MockMealRepo extends Mock implements MealRepo {}

class FakeMealModel extends Fake implements MealModel {}

void main() {
  late MockMealRepo mockMealRepo;
  late MealCubit mealCubit;

  setUpAll(() {
    registerFallbackValue(FakeMealModel());
  });

  setUp(() {
    mockMealRepo = MockMealRepo();
    mealCubit = MealCubit(mockMealRepo);
  });

  tearDown(() {
    mealCubit.close();
  });

  test('initial state is MealInitial', () {
    expect(mealCubit.state, isA<MealInitial>());
  });

  blocTest<MealCubit, MealState>(
    'emits [MealSaveError] when meal details are empty',
    build: () => mealCubit,
    act: (cubit) => cubit.saveMeal(
      mealType: 'Breakfast',
      mealDetails: '   ',
      date: '26/09/2026',
      time: '08:00 AM',
    ),
    expect: () => [
      isA<MealSaveError>().having(
        (s) => s.error,
        'error',
        'Please enter meal details',
      ),
    ],
  );

  blocTest<MealCubit, MealState>(
    'emits [MealLoading, MealSaveSuccess] when insertMeal succeeds',
    build: () {
      when(() => mockMealRepo.insertMeal(any())).thenAnswer((_) async => 1);
      return mealCubit;
    },
    act: (cubit) => cubit.saveMeal(
      mealType: 'Breakfast',
      mealDetails: 'Oatmeal with berries',
      date: '26/09/2026',
      time: '08:30 AM',
    ),
    expect: () => [
      isA<MealLoading>(),
      isA<MealSaveSuccess>().having(
        (s) => s.message,
        'message',
        'Meal saved successfully!',
      ),
    ],
    verify: (_) {
      verify(() => mockMealRepo.insertMeal(any())).called(1);
    },
  );

  blocTest<MealCubit, MealState>(
    'emits [MealLoading, MealSaveSuccess] when updateMeal succeeds',
    build: () {
      when(() => mockMealRepo.updateMeal(any())).thenAnswer((_) async => 1);
      return mealCubit;
    },
    act: (cubit) => cubit.saveMeal(
      id: 5,
      mealType: 'Lunch',
      mealDetails: 'Grilled chicken salad',
      date: '26/09/2026',
      time: '01:00 PM',
    ),
    expect: () => [
      isA<MealLoading>(),
      isA<MealSaveSuccess>().having(
        (s) => s.message,
        'message',
        'Meal updated successfully!',
      ),
    ],
    verify: (_) {
      verify(() => mockMealRepo.updateMeal(any())).called(1);
    },
  );

  blocTest<MealCubit, MealState>(
    'emits [MealLoading, MealSaveError] when database throws exception',
    build: () {
      when(() => mockMealRepo.insertMeal(any())).thenThrow(Exception('DB error'));
      return mealCubit;
    },
    act: (cubit) => cubit.saveMeal(
      mealType: 'Dinner',
      mealDetails: 'Salmon and asparagus',
      date: '26/09/2026',
      time: '07:30 PM',
    ),
    expect: () => [
      isA<MealLoading>(),
      isA<MealSaveError>(),
    ],
  );
}
