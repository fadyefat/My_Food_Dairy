import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_food_diary/features/meals/data/repos/meal_repo.dart';
import 'daily_log_state.dart';

class DailyLogCubit extends Cubit<DailyLogState> {
  final MealRepo _mealRepo;
  DateTime _currentDate = DateTime.now();

  DailyLogCubit(this._mealRepo) : super(DailyLogInitial());

  DateTime get currentDate => _currentDate;

  Future<void> loadMealsForDate(DateTime date) async {
    _currentDate = date;
    emit(DailyLogLoading());
    try {
      final dateString = DateFormat('dd/MM/yyyy').format(date);
      final meals = await _mealRepo.getMealsByDate(dateString);
      emit(DailyLogLoaded(meals: meals, selectedDate: date));
    } catch (e) {
      emit(DailyLogError('Error loading meals: $e'));
    }
  }

  Future<void> deleteMeal(int id) async {
    try {
      await _mealRepo.deleteMeal(id);
      emit(MealDeletedSuccess('Meal deleted successfully'));
      loadMealsForDate(_currentDate);
    } catch (e) {
      emit(DailyLogError('Error deleting meal: $e'));
    }
  }

  void refreshCurrentDate() {
    loadMealsForDate(_currentDate);
  }
}
