import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_food_diary/features/meals/data/repos/meal_repo.dart';
import 'summary_state.dart';

class SummaryCubit extends Cubit<SummaryState> {
  final MealRepo _mealRepo;

  SummaryCubit(this._mealRepo) : super(SummaryInitial());

  Future<void> loadTodayStatistics() async {
    emit(SummaryLoading());
    try {
      final statistics = await _mealRepo.getTodayStatistics();
      emit(DailySummaryLoaded(
        totalMeals: statistics['totalMeals'] ?? 0,
        mealTypes: statistics['mealTypes'] ?? 0,
      ));
    } catch (e) {
      emit(SummaryError('Error loading today statistics: $e'));
    }
  }

  Future<void> loadWeeklyStatistics() async {
    emit(SummaryLoading());
    try {
      final statistics = await _mealRepo.getWeeklyStatistics();
      emit(WeeklySummaryLoaded(
        totalMeals: statistics['totalMeals'] ?? 0,
        avgMealsPerDay: (statistics['avgMealsPerDay'] as num?)?.toDouble() ?? 0.0,
        mostCommonMeal: statistics['mostCommonMeal'] ?? 'None',
      ));
    } catch (e) {
      emit(SummaryError('Error loading weekly statistics: $e'));
    }
  }
}
