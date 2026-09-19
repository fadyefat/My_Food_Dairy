abstract class SummaryState {}

class SummaryInitial extends SummaryState {}

class SummaryLoading extends SummaryState {}

class DailySummaryLoaded extends SummaryState {
  final int totalMeals;
  final int mealTypes;

  DailySummaryLoaded({required this.totalMeals, required this.mealTypes});
}

class WeeklySummaryLoaded extends SummaryState {
  final int totalMeals;
  final double avgMealsPerDay;
  final String mostCommonMeal;

  WeeklySummaryLoaded({
    required this.totalMeals,
    required this.avgMealsPerDay,
    required this.mostCommonMeal,
  });
}

class SummaryError extends SummaryState {
  final String message;
  SummaryError(this.message);
}
