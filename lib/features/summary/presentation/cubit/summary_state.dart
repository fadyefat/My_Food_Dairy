abstract class SummaryState {}

class SummaryInitial extends SummaryState {}

class SummaryLoading extends SummaryState {}

class DailySummaryLoaded extends SummaryState {
  final int totalMeals;
  final int mealTypes;
  final Map<String, int> mealTypeCounts;
  final List<Map<String, dynamic>> meals;

  DailySummaryLoaded({
    required this.totalMeals,
    required this.mealTypes,
    required this.mealTypeCounts,
    required this.meals,
  });
}

class WeeklySummaryLoaded extends SummaryState {
  final int totalMeals;
  final double avgMealsPerDay;
  final String mostCommonMeal;
  final Map<String, int> mealTypeCounts;
  final Map<String, int> dailyMealCounts;
  final List<Map<String, dynamic>> meals;

  WeeklySummaryLoaded({
    required this.totalMeals,
    required this.avgMealsPerDay,
    required this.mostCommonMeal,
    required this.mealTypeCounts,
    required this.dailyMealCounts,
    required this.meals,
  });
}

class SummaryError extends SummaryState {
  final String message;
  SummaryError(this.message);
}
