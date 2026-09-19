import 'package:my_food_diary/features/meals/data/models/meal_model.dart';

abstract class DailyLogState {}

class DailyLogInitial extends DailyLogState {}

class DailyLogLoading extends DailyLogState {}

class DailyLogLoaded extends DailyLogState {
  final List<MealModel> meals;
  final DateTime selectedDate;

  DailyLogLoaded({required this.meals, required this.selectedDate});
}

class DailyLogError extends DailyLogState {
  final String message;
  DailyLogError(this.message);
}

class MealDeletedSuccess extends DailyLogState {
  final String message;
  MealDeletedSuccess(this.message);
}
