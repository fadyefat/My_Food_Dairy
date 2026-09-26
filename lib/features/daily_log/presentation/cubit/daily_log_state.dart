import 'package:my_food_diary/features/meals/data/models/meal_model.dart';

abstract class DailyLogState {}

class DailyLogInitial extends DailyLogState {}

class DailyLogLoading extends DailyLogState {}

class DailyLogLoaded extends DailyLogState {
  final List<MealModel> allMeals;
  final List<MealModel> meals;
  final DateTime selectedDate;
  final String searchQuery;
  final String selectedCategory;

  DailyLogLoaded({
    required this.allMeals,
    required this.meals,
    required this.selectedDate,
    this.searchQuery = '',
    this.selectedCategory = 'All',
  });
}

class DailyLogError extends DailyLogState {
  final String message;
  DailyLogError(this.message);
}

class MealDeletedSuccess extends DailyLogState {
  final String message;
  MealDeletedSuccess(this.message);
}
