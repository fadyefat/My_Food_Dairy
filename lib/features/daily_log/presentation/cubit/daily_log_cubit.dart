import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_food_diary/features/meals/data/models/meal_model.dart';
import 'package:my_food_diary/features/meals/data/repos/meal_repo.dart';
import 'daily_log_state.dart';

class DailyLogCubit extends Cubit<DailyLogState> {
  final MealRepo _mealRepo;
  DateTime _currentDate = DateTime.now();
  List<MealModel> _allMeals = [];
  String _currentQuery = '';
  String _currentCategory = 'All';

  DailyLogCubit(this._mealRepo) : super(DailyLogInitial());

  DateTime get currentDate => _currentDate;
  String get currentQuery => _currentQuery;
  String get currentCategory => _currentCategory;

  Future<void> loadMealsForDate(DateTime date) async {
    _currentDate = date;
    emit(DailyLogLoading());
    try {
      final dateString = DateFormat('dd/MM/yyyy').format(date);
      final meals = await _mealRepo.getMealsByDate(dateString);
      _allMeals = meals;
      _applyFilter();
    } catch (e) {
      emit(DailyLogError('Error loading meals: $e'));
    }
  }

  void filterMeals({String? query, String? category}) {
    if (query != null) _currentQuery = query;
    if (category != null) _currentCategory = category;
    _applyFilter();
  }

  void _applyFilter() {
    List<MealModel> filtered = List.from(_allMeals);

    // Filter by Category
    if (_currentCategory != 'All') {
      filtered = filtered
          .where((m) => m.mealType.toLowerCase() == _currentCategory.toLowerCase())
          .toList();
    }

    // Filter by Search Query
    if (_currentQuery.trim().isNotEmpty) {
      final q = _currentQuery.trim().toLowerCase();
      filtered = filtered.where((m) {
        final matchesDetails = m.mealDetails.toLowerCase().contains(q);
        final matchesType = m.mealType.toLowerCase().contains(q);
        return matchesDetails || matchesType;
      }).toList();
    }

    emit(DailyLogLoaded(
      allMeals: _allMeals,
      meals: filtered,
      selectedDate: _currentDate,
      searchQuery: _currentQuery,
      selectedCategory: _currentCategory,
    ));
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
